##################################################################

# Load the required libraries

##################################################################
library('dplyr')
library('data.table')
library("lubridate")

##################################################################

# Cleaning up environment variables if any

##################################################################
rm(list=ls())

##################################################################

# Loading the csv data file into the memory

##################################################################
csvFile <- "../data/20150325.csv"
data <- tbl_df(fread(csvFile))


##################################################################

# EXPLORATORY ANALYSIS

##################################################################

# FOR EVERY HOUR FIND THE AVERAGE TIPPING IN NYC 

data <- data %>% 
        mutate(pickup_time=ymd_hms(pickup_time), 
               dropoff_time=ymd_hms(dropoff_time),
               pickup_hour = hour(pickup_time),
               pickup_minutes = minute(pickup_time),
               pickup_seconds = seconds(pickup_time),
               dropoff_hour = hour(dropoff_time),
               dropoff_minutes = minute(dropoff_time),
               dropoff_seconds = second(dropoff_time)
               
        ) %>%
        arrange(pickup_hour, pickup_minutes, pickup_seconds) 

groupedByHour <- data %>%
                group_by(pickup_hour, pickup_minutes) %>%
                summarise(averageTip=mean(tip), 
                          averageTotal= mean(total))

#####################################################################
                
            #getting all the data in the blast hour


#####################################################################
aroundTheBlast <- data %>%
                  filter(pickup_hour==15)

        
write.csv(aroundTheBlast, '../data/aroundTheBlast.csv')


        







