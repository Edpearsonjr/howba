 ###########################################################

# Loading the libraries 

###########################################################

library("dplyr") # This helps in manipulating the data 
library("data.table") # This helps to read the files faster
library("lubridate") # This helps in manipulating the dates and times 



#########################################################

# Pre amble - if you want to remove the environment 
#              variables and other things 

#########################################################
rm(list=ls())



#########################################################

#loading the data into a tbl_df

#########################################################
data2015MarchFile <- "../data/yellow_tripdata_2015-03.csv"
data2015March <- tbl_df(read.csv(data2015MarchFile))

#########################################################

# Pre processing the data to include 
# 25th of march 2015 15:17 data 
# and also include credit card transactions only 

#########################################################
data25thMarch <- data2015March %>% 
    mutate(tpep_pickup_datetime = ymd_hms(tpep_pickup_datetime), tpep_dropoff_datetime = ymd_hms(tpep_dropoff_datetime)) %>%
    filter(payment_type== 1) %>%
    filter(pickup_longitude!=0, pickup_latitude!=0, dropoff_latitude!=0, dropoff_longitude!=0) %>%
    filter(pickup_datetime > ymd('2015-03-25'), pickup_datetime < ymd('2015-02-26')) %>%
    select(-c(payment_type, store_and_fwd_flag, mta_tax,improvement_surcharge)) %>%
    rename(long = pickup_longitude, # renaming variables
           lat  = pickup_latitude,
           passengers = passenger_count,
           distance = trip_distance,
           pickup_time  = tpep_pickup_datetime, 
           dropoff_time = tpep_dropoff_datetime,
           fare = fare_amount,
           tip = tip_amount,
           tolls = tolls_amount,
           total = total_amount)
    
write.csv(data25thMarch, "../data/20150325.csv")

    







