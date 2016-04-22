################################################################################
# Preamble - Load all the libraries here
#library(\'libraryName\') # The purpose of the library
################################################################################

library('dplyr')                    # Operations on frames
library('RMySQL')                   # For connecting with the mysql package
library('lubridate')
library('sp')
library('geojsonio')  # helps in reading the geojson files
library('howbaUtils')
library('parallel')

################################################################################
# Clearing the environment variables
################################################################################
rm(list=ls())

################################################################################
# A few constants that are needed
################################################################################
DB_HOST = 'localhost'
DB_PORT = '3306'
DB_USER = 'root'
DB_PASSWORD = '#Ab1992#'
DB_NAME = 'howba'
BOROUGH_GEOJSON <- "~/Abhinav/howba/app/src/project/data/misc/boroughs.json"
NO_CLUSTER <- detectCores()

################################################################################
# Connecting to the database
################################################################################
print("Connecting to the database")
connection <- dbConnect(RMySQL::MySQL(), user=DB_USER, password=DB_PASSWORD, host=DB_HOST, dbname=DB_NAME)

################################################################################
# Getting the November 24th 2013 data - 30-Nov 2013
################################################################################
queryNovemberSunday <-"SELECT * FROM NOV2013 WHERE DATE(pickup_time)>='2013-11-24' AND DATE(pickup_time) <= '2013-11-30'"
nmd2013120107 <- tbl_df(dbGetQuery(connection, queryNovemberSunday))


################################################################################

# Performing regression

################################################################################
nmd2013120107 <- nmd2013120107 %>%
                    mutate(weekday = as.factor(weekday),
                           vendor_id = as.factor(vendor_id),
                           rate_code_id = as.factor(rate_code_id),
                           tip_amount = scale(tip_amount),
                           trip_distance = scale(trip_distance),
                           passenger_count = scale(passenger_count),
                           surcharge = scale(surcharge),
                           toll_amount = scale(toll_amount),
                           duration = scale(duration),
                           fare_amount = scale(fare_amount),
                           pickup_time = ymd_hms(pickup_time),
                           dropoff_time = ymd_hms(dropoff_time),
                           pickup_geom = paste(pickup_latitude, pickup_longitude, sep=","))

reg <- step(lm(tip_amount ~ weekday+vendor_id+trip_distance+passenger_count+surcharge+toll_amount+duration+ratio_tip_total+fare_amount+rate_code_id, data=nmd2013120107), direction = "both")
summary(reg) #this also gave 79.8% accuracy


##############################################################################

 #  ADD THE BOROUGH OF THE PICKUP AS IT MIGHT HAVE AN IMPACT ON THE TIPS
 #  ADD THE TIME OF THE PICKUP (MORNING GOERS MIGHT PAY LESS)
 #  WE ARE PARALLELISING THE CODE LIKE COOL DUDES

##############################################################################
boroughsData <- getBoroughsData(BOROUGH_GEOJSON)
boroughs_names <- names(boroughsData)
unique_names <- unique(sapply(strsplit(boroughs_names,"_"), function(x){x[[1]]}))

pickupTimeOfTheDay <- lapply(nmd2013120107$pickup_time, function(x){groupIntoTimeOfTheDay(x)})
dropoffTimeOfTheDay <- lapply(nmd2013120107$dropoff_time, function(x){groupIntoTimeOfTheDay(x)})

################################################################################

    # THE DATA RAN FASTER ON ANUSHAS MACHINE - PICKING IT FROM THERE 

################################################################################
anushasDataWithBoroughInfo <- "~/Abhinav/howba/app/src/project/data/misc/finalnov24to302013.RData"
load(anushasDataWithBoroughInfo)


regressionData <- nmd2013120107 %>%
                 select(-c(cab_type, pickup_geom)) %>%
                       mutate(pickupTimeOfTheDay = unlist(pickupTimeOfTheDay),
                       dropoffTimeOfTheDay = unlist(dropoffTimeOfTheDay),
                       pickup_borough= unlist(final$PUborough),
                       dropoff_borough=unlist(final$DOborough))

write.csv(regressionData, file="regression.csv")







