###########################################################

        # LOADING THE LIBRARY 

###########################################################
library(dplyr)       # To help us manipulate the data 
library(MatchIt)     # To match people in the treatment group to the control group 


######################################################################


#  GET THE DATA FOR THE 24TH OF NOVEMBER 2013 FOR BOTH THE REGIONS 
#  COMBINE IT IN ONE DATA FRAME INDICATING WHICH IS TREATMENT AND WHICH   
#  IS THE CONTROL GROUP 
#  PASS THE SIGNIFICANT CHARACTERISTICS TO BE USED TO CALCULATE THE PROPENSITY
#  SCORE USING THE PROBIT MODEL 

#######################################################################

PICKUP_DISASTER_FILE <- "aroundTheDerailmentPickup20131124.RData"
DROPOFF_DISASTER_FILE <- "aroundTheDerailmentDropoff20131124.RData"
PICKUP_QUEENS_STATION_FILE <- "aroundTheQueensStationPickup20131124.RData"
DROPOFF_QUEENS_STATION_FILE <- "aroundTheQueensStationDropoffTwoW.RData"

load(PICKUP_DISASTER_FILE)
load(DROPOFF_DISASTER_FILE)
load(PICKUP_QUEENS_STATION_FILE)
load(DROPOFF_QUEENS_STATION_FILE)
pickup_disaster <- tbl_df(aroundTheDerailmentPickup)
dropoff_disaster <- tbl_df(aroundTheDerailmentDropoff)
pickup_queens <- tbl_df(aroundTheQueensStationPickup)
dropoff_queens <- tbl_df(aroundTheQueensStationtDropoff)

dropoff_disaster <- dropoff_disaster %>%
    mutate(pickup_time = ymd_hms(pickup_time), 
           dropoff_time = ymd_hms(dropoff_time),
           dropoff_day = day(dropoff_time),
           dropoff_hour = hour(dropoff_time),
           area = 'around the blast',
           disaster=1)


dropoff_queens <- dropoff_queens %>%
    mutate(pickup_time = ymd_hms(pickup_time), 
           dropoff_time = ymd_hms(dropoff_time),
           dropoff_day = day(dropoff_time),
           dropoff_hour = hour(dropoff_time),
           area= 'similar place',
           disaster=0)


same_drivers <- intersect(dropoff_disaster$hack_license, dropoff_queens$hack_license)

matchItDataFrame <- rbind(dropoff_disaster, dropoff_queens)
matchItDataFrame <- matchItDataFrame %>%
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
                           noon = ifelse(dropoff_hour>=9 & dropoff_hour<16, yes=1, no=0),
                           veryEarlyMorning = ifelse(dropoff_hour>=0 & dropoff_hour < 6, yes=1, no=0),
                           dropoffBrooklyn = 0,
                           dropoffManhattan = 0,
                           dropoffQueens = ifelse(disaster==0, yes=1, no=0),
                           dropoffStatenIsland = 0
                     ) %>%
                     filter(!hack_license %in% same_drivers)


matchObj <- matchit(disaster ~  trip_distance + surcharge  + total_amount + duration + ratio_tip_total +
                        toll_amount , data=matchItDataFrame, 
                        method = "nearest"
                    )
summary(matchObj)



