
###############################################################################

    #LOAD THE LIBRARIES

###############################################################################
library(dplyr)
library(lubridate)


###############################################################################

# CONSTANTS

###############################################################################
rm(list=ls())
MATCHED_DATA_FROM_MATCHIT <- "matchedData.RData"
PICKUP_DISASTER_DECEMBER <- "aroundTheDerailmentPickup20131201.RData"
DROPOFF_DISASTER_DECEMBER <- "aroundTheDerailmentDropoff20131201.RData"
PICKUP_QUEENS_DECEMBER <- "aroundTheQueensStationPickup20131201.RData"
DROPOFF_QUEENS_DECEMBER <- "aroundTheQueensStationDropoff20131201.RData"

load(MATCHED_DATA_FROM_MATCHIT)
load(PICKUP_DISASTER_DECEMBER)
load(DROPOFF_DISASTER_DECEMBER)
load(PICKUP_QUEENS_DECEMBER)
load(DROPOFF_QUEENS_DECEMBER)

dropoff_disaster <- tbl_df(aroundTheDerailmentDropoff) %>%
                    mutate(pickup_time=ymd_hms(pickup_time),
                           dropoff_time=ymd_hms(dropoff_time),
                           dropoff_day = day(dropoff_time),
                           dropoff_hour = hour(dropoff_time)) 
dropoff_queens <- tbl_df(aroundTheQueensStationtDropoff) %>%
                    mutate(pickup_time=ymd_hms(pickup_time),
                           dropoff_time=ymd_hms(dropoff_time),
                           dropoff_day = day(dropoff_time),
                           dropoff_hour = hour(dropoff_time)) 
matchedData <- tbl_df(matchedData)

##########################################################

        # ON THE DISASTER DAY SEE WHETHER YOU CAN 
        # FIND THE SAME DRIVERS WHO DROVE INTO THE
        # RESPECTIVE REGIONS ON THE PREVIOUS SUNDAY

##########################################################

disaster_guys <- matchedData %>%
                 select(-c(distance, weights)) %>%
                 filter(disaster == 1) 
                    
                    
                    

non_disaster_guys <- matchedData %>%
                     filter(disaster == 0)  %>%
                     select(-c(distance, weights))

treatment_group <- intersect(dropoff_disaster$hack_license, disaster_guys$hack_license)
control_group <- intersect(dropoff_queens$hack_license, non_disaster_guys$hack_license)


disaster_guys <- disaster_guys %>%
                 filter(hack_license %in% treatment_group) %>%
                 mutate(disaster=1,
                        time=0)

non_disaster_guys <- non_disaster_guys %>%
                 filter(hack_license %in% control_group) %>%
                 mutate(disaster=0,
                        time=0)


dropoff_disaster <- dropoff_disaster %>%
                    filter(hack_license %in% treatment_group) %>%
                    mutate(disaster=1,
                           time=1)

dropoff_queens <- dropoff_queens %>%
                  filter(hack_license %in% treatment_group) %>%
                  mutate(disaster = 0,
                         time = 1)


#normalise all the columns in the four datasets 
beforeGroup <- rbind(disaster_guys, non_disaster_guys)
afterGroup <- rbind(dropoff_disaster, dropoff_queens) %>%
              mutate(weekDayMonday = ifelse( (tolower(weekday)=="monday") == 1, yes = 1, no=0),
                       weekDaySunday = ifelse( (tolower(weekday)=="sunday") == 1, yes = 1, no=0),
                       weekDayThursday = ifelse( (tolower(weekday)=="thursday") == 1, yes = 1, no=0),
                       weekDayTuesday = ifelse( (tolower(weekday)=="tuesday") == 1, yes = 1, no=0),
                       weekDayWednesday = ifelse( (tolower(weekday)=="wednesday") == 1, yes = 1, no=0),
                       vts = ifelse(tolower(vendor_id) == "vts", yes=1, no=0),
                       rateCodeId = ifelse(rate_code_id == 5, yes=1, no = 0),
                       earlyMorning = ifelse(dropoff_hour>=3 & dropoff_hour<6, yes=1, no=0),
                       lateNight = ifelse(dropoff_hour>=21 & dropoff_hour<=23, yes=1, no=0),
                       morning = ifelse(dropoff_hour>=6 & dropoff_hour<9, yes=1, no=0),
                       non = ifelse(dropoff_hour>=9 & dropoff_hour<16, yes=1, no=0),
                       veryEarlyMorning = ifelse(dropoff_hour>=0 & dropoff_hour < 6, yes=1, no=0),
                       dropoffBrooklyn = 0,
                       dropoffManhattan = 0,
                       dropoffQueens = ifelse(disaster==0, yes=1, no=0),
                       dropoffStatenIsland = 0)

beforeGroup <- beforeGroup %>%
                select(-c(row_number, weekday, vendor_id, pickup_time, dropoff_time, 
                          rate_code_id, pickup_latitude, pickup_longitude,
                          dropoff_longitude, dropoff_latitude, passenger_count,fare_amount,
                          trip_type, cab_type, year, month, medallion, hack_license,
                          ratio_tip_distance, ratio_tip_duration, dropoff_geom, within, dropoff_day, dropoff_hour, area))
    
    
afterGroup <- afterGroup %>%
              select(-c(row_number,weekday, vendor_id, pickup_time, dropoff_time, 
                        rate_code_id, pickup_latitude, pickup_longitude,
                        dropoff_longitude, dropoff_latitude, passenger_count, fare_amount,
                        trip_type, cab_type, year, month, medallion, hack_license,
                        ratio_tip_distance, ratio_tip_duration, dropoff_geom, within, dropoff_day, dropoff_hour )) %>%
             rename(noon=non)


diffInDiffData <- rbind(beforeGroup, afterGroup)

############################################################


    # This is now difference in difference modelling 


############################################################
covariates <- diffInDiffData%>%select(-c(disaster,time,tip_amount))
X <- cbind(covariates$trip_distance, covariates$surcharge, covariates$toll_amount, covariates$total_amount,
           covariates$duration, covariates$ratio_tip_total,covariates$vts, 
           covariates$rateCodeId, covariates$earlyMorning, covariates$lateNight, covariates$morning,
           covariates$noon, covariates$veryEarlyMorning,covariates$dropoffQueens)
treated <- diffInDiffData$disaster
time <- diffInDiffData$time
treated_time <- treated*time 
    
diffInDiffRegression <- step(lm(tip_amount ~   X   + treated_time + treated + time, data = diffInDiffData), direction = "both")

