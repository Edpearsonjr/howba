################################################################################
# Preamble - Load all the libraries here 
#library(\'libraryName\') # The purpose of the library 
################################################################################

library('dplyr')                    # Operations on frames 
library('RMySQL')                   # For connecting with the mysql package
library('lubridate')                # For manipulating the dates in R
library('sp')

################################################################################
# Clearing the environment variables 
################################################################################
rm(list=ls())

################################################################################
# R is not allowing me to source the file in utils.R
################################################################################
isInsidePolygon <- function(latitude, longitude, polygonx, polygony){
    # @params: latitude -> float 
    #          longitude -> float
    #          polygonx -> list of x coordinates for the borough to check in 
    #          ploygony -> list of x coordinates for the borough to check in 
    value <- point.in.polygon(latitude, longitude, pol.x = polygonx, pol.y = polygony)
    isInside <- FALSE
    if(value == 1 | value == 3){
        isInside <- TRUE
    }
    else{
        isInside <- FALSE
    }
    isInside
    
}
isInsideDerailmentArea <- function(x, polygonx, polygony){
    splitString <- strsplit(x,",")[[1]]
    lat <- as.numeric(splitString[1])
    long <- as.numeric(splitString[2])
    isInside <- isInsidePolygon(lat, long, polygonx, polygony)
    isInside 
}

################################################################################
# A few constants that are needed
################################################################################
DB_HOST = 'localhost'
DB_PORT = '3306'
DB_USER = 'root'
DB_PASSWORD = '#Ab1992#'
DB_NAME = 'howba'

################################################################################
# Connecting to the database
################################################################################
print("Connecting to the database")
connection <- dbConnect(RMySQL::MySQL(), user=DB_USER, password=DB_PASSWORD, host=DB_HOST, dbname=DB_NAME)


################################################################################
# Getting the November 24th 2013 data 
################################################################################
queryNovemberSunday <-"SELECT * FROM DEC2013 WHERE DATE(pickup_time)='2013-12-01'"
data <- tbl_df(dbGetQuery(connection, queryNovemberSunday))


################################################################################
# Getting the cab rides for 24th November in and around the area where the disaster happend
################################################################################
# Get the whole days data at the two locations 
# One around the disaster location 
# One around the other location where the disaster didnt happen 


# bounding box around the derailment 
lat_min_around_the_derailment <- 40.8435392765
lat_max_around_the_derailment <- 40.915905168
lon_min_around_the_derailment <- -73.9706334275
lon_max_around_the_derailment  <- -73.8749221281
bounding_box_derailment_x_coordinates <- c(lat_max_around_the_derailment, lat_max_around_the_derailment, lat_min_around_the_derailment, lat_min_around_the_derailment) 
bounding_box_derailment_y_coordinates <- c(lon_min_around_the_derailment, lon_max_around_the_derailment, lon_max_around_the_derailment, lon_min_around_the_derailment)

# Remove bad data
cleanData <- data %>%
               mutate(pickup_time=ymd_hms(pickup_time)) %>%     # Converting into lubridate date 
               mutate(dropoff_time=ymd_hms(dropoff_time)) %>%   # Converting the drop of time into lubridate
               filter(pickup_latitude > 0, pickup_longitude < 0) %>%
               filter(dropoff_latitude > 0,dropoff_longitude < 0)




#take only those data for which the pickup is within the bounding box of the derailment
aroundTheDerailmentPickup <- cleanData %>%
                                mutate(pickup_geom =paste(pickup_latitude, pickup_longitude, sep=","))
isInside <- lapply(aroundTheDerailmentPickup$pickup_geom, function(x){isInsideDerailmentArea(x, bounding_box_derailment_x_coordinates, bounding_box_derailment_y_coordinates)})
aroundTheDerailmentPickup <- aroundTheDerailmentPickup %>%
                             mutate(within=isInside) %>%
                             filter(within==TRUE)


aroundTheDerailmentDropoff <- cleanData %>%
                                mutate(dropoff_geom =paste(dropoff_latitude, dropoff_longitude, sep=","))
isInside <- lapply(aroundTheDerailmentDropoff$dropoff_geom, function(x){isInsideDerailmentArea(x, bounding_box_derailment_x_coordinates, bounding_box_derailment_y_coordinates)})
aroundTheDerailmentDropoff <- aroundTheDerailmentDropoff %>%
                                mutate(within=isInside) %>%
                                filter(within==TRUE)


##############################################################################################################################################################################################################################################



################################################################################
# Getting the cab rides for 24th November in and around the area which is similar
################################################################################


# bounding box around the queens station 
lat_min_around_the_queens_station <- 40.6734170542
lat_max_around_the_queens_station <- 40.7457829458
lon_min_around_the_queens_station <- -73.8783931785
lon_max_around_the_queens_station  <- -73.7829268215
bounding_box_around_queens_station_x_coordinates <- c(lat_max_around_the_queens_station, lat_max_around_the_queens_station, lat_min_around_the_queens_station, lat_min_around_the_queens_station) 
bounding_box_around_queens_station_y_coorindates <- c(lon_min_around_the_queens_station, lon_max_around_the_queens_station, lon_max_around_the_queens_station, lon_min_around_the_queens_station)


#take only those data for which the pickup is within the bounding box of the queen station
aroundTheQueensStationPickup <- cleanData %>%
    mutate(pickup_geom =paste(pickup_latitude, pickup_longitude, sep=","))
isInside <- lapply(aroundTheQueensStationPickup$pickup_geom, function(x){isInsideDerailmentArea(x, bounding_box_around_queens_station_x_coordinates, bounding_box_around_queens_station_y_coorindates)})
aroundTheQueensStationPickup <- aroundTheQueensStationPickup %>%
    mutate(within=isInside) %>%
    filter(within==TRUE)


aroundTheQueensStationtDropoff <- cleanData %>%
    mutate(dropoff_geom =paste(dropoff_latitude, dropoff_longitude, sep=","))
isInside <- lapply(aroundTheQueensStationtDropoff$dropoff_geom, function(x){isInsideDerailmentArea(x, bounding_box_around_queens_station_x_coordinates, bounding_box_around_queens_station_y_coorindates)})
aroundTheQueensStationtDropoff <- aroundTheQueensStationtDropoff %>%
    mutate(within=isInside) %>%
    filter(within==TRUE)












    
               
                   











