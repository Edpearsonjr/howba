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
dataMarchYellowFile <- "~/Abhinav/howba/app/src/project/data/2015-03/yellow_tripdata_2015-03.csv"
dataMarchGreenFile <- "~/Abhinav/howba/app/src/project/data/2015-03/green_tripdata_2015-03.csv"
dataMarchYellow <- tbl_df(fread(dataMarchYellowFile))
dataMarchGreen  <- tbl_df(fread(dataMarchGreenFile))
colnames(dataMarchGreen) <- c("vendor_id", "pickup_time", "dropoff_time", "store_and_forward_flag", "rate_code_id", "pickup_longitude", "pickup_latitude",
                              "dropoff_longitude", "dropoff_latitude", "passenger_count", "trip_distance", "fare_amount", "surcharge", "mta_tax", "tip_amount",
                              "toll_amount", "ehail_fee", "total_amount", "payment_type", "trip_type", "dummy1", "dummy2")
colnames(dataMarchYellow) <- c("vendor_id", "pickup_time", "dropoff_time", "passenger_count", "trip_distance", "pickup_longitude", "pickup_latitude",
                               "rate_code_id", "store_and_forward_flag", "dropoff_longitude", "dropoff_latitude", "payment_type", "fare_amount", "surcharge",
                               "mta_tax","tip_amount", "toll_amount","additional_surcharge", "total_amount")

#########################################################
# Pre processing the data to include 
# Combine the yellow and green cab data
#########################################################
# The following are the column names in the final data frame 

# vendor_id, pickup_time, dropoff_time, store_and_forward_flag, rate_code_id, pickup_longitude, pickup_latitude, 
# dropoff_longitude, dropoff_latitude, passenger_count, trip_distance, fare_amount, surcharge, mta_tax, tip_amount
# toll_amount, total_amount, payment_type(cash or credit card and others), 
# trip_type(this is for the green cab only), cab_type(yellow, green), year, month, medallion, hack_license
normalisedDataGreen  <- dataMarchGreen %>%
    select(-c(ehail_fee, dummy1, dummy2)) %>%
    mutate(vendor_id=replace(vendor_id,vendor_id==1, "CMT")) %>%
    mutate(vendor_id=replace(vendor_id,vendor_id==2, "VTS")) %>%
    mutate(payment_type=replace(payment_type, payment_type==1, "CRD")) %>%
    mutate(payment_type=replace(payment_type, payment_type==2, "CSH")) %>%
    mutate(payment_type=replace(payment_type, payment_type==3, "NOC")) %>%
    mutate(payment_type=replace(payment_type, payment_type==4, "DIS")) %>%
    mutate(payment_type=replace(payment_type, payment_type==5, "UNK")) %>%
    mutate(cab_type="green", year=2015, month=3, "medallion"=NA, hack_license=NA) %>%
    mutate(pickup_time=ymd_hms(pickup_time, tz="EST")) %>%
    mutate(dropoff_time=ymd_hms(dropoff_time, tz="EST")) %>%
    mutate(store_and_forward_flag=as.factor(store_and_forward_flag)) %>%
    mutate(rate_code_id=as.factor(rate_code_id)) %>%
    mutate(payment_type=as.factor(payment_type)) %>%
    mutate(trip_type=as.factor(trip_type)) %>%
    mutate(cab_type=as.factor(cab_type)) %>%
    mutate(medallion=as.factor(medallion)) %>%
    mutate(hack_license=as.factor(hack_license)) %>%
    select(c(vendor_id, pickup_time, dropoff_time, store_and_forward_flag, rate_code_id, pickup_longitude, pickup_latitude, dropoff_longitude,
             dropoff_latitude, passenger_count, trip_distance, fare_amount, surcharge, mta_tax, tip_amount, toll_amount, total_amount, payment_type, 
             trip_type, cab_type, year, month, medallion, hack_license))

normalisedDataYellow <- dataMarchYellow %>%
    mutate(pickup_time=ymd_hms(pickup_time, tz="EST"), dropoff_time=ymd_hms(dropoff_time, tz="EST")) %>%
    mutate(vendor_id=replace(vendor_id,vendor_id==1, "CMT")) %>%
    mutate(vendor_id=replace(vendor_id,vendor_id==2, "VTS")) %>%
    mutate(payment_type=replace(payment_type, payment_type==1, "CRD")) %>%
    mutate(payment_type=replace(payment_type, payment_type==2, "CSH")) %>%
    mutate(payment_type=replace(payment_type, payment_type==3, "NOC")) %>%
    mutate(payment_type=replace(payment_type, payment_type==4, "DIS")) %>%
    mutate(payment_type=replace(payment_type, payment_type==5, "UNK")) %>%
    mutate(rate_code_id=as.factor(rate_code_id)) %>%
    mutate(store_and_forward_flag=as.factor(store_and_forward_flag)) %>%
    mutate(payment_type=as.factor(payment_type)) %>%
    mutate(cab_type="yellow", year=2015, month=3, "medallion"=NA, hack_license=NA, trip_type=NA) %>%
    mutate(cab_type=as.factor(cab_type)) %>%
    mutate(medallion=as.factor(medallion)) %>%
    mutate(hack_license=as.factor(hack_license)) %>%
    mutate(trip_type=as.factor(trip_type)) %>%
    select(c(vendor_id, pickup_time, dropoff_time, store_and_forward_flag, rate_code_id, pickup_longitude, pickup_latitude, dropoff_longitude,
             dropoff_latitude, passenger_count, trip_distance, fare_amount, surcharge, mta_tax, tip_amount, toll_amount, total_amount, payment_type, 
             trip_type, cab_type, year, month, medallion, hack_license))


normalisedMarch <- rbind(normalisedDataYellow, normalisedDataGreen)
normalisedMarch <- normalisedMarch %>%
                   filter(payment_type== "CRD") %>%
                   select(-c(store_and_forward_flag, mta_tax,  payment_type)) %>%
                    mutate(vendor_id = as.factor(vendor_id)) %>%
                    mutate(weekday  = factor(weekdays(pickup_time)),
                           duration = as.numeric(difftime(dropoff_time, pickup_time, units = c("mins"))), # trip duration in decimal minutes
                           ratio_tip_total    = (tip_amount / total_amount)*100,    # A) possible measure for tips
                           ratio_tip_distance = tip_amount / trip_distance,       # B) possible measure for tips
                           ratio_tip_duration = tip_amount / duration) 

save(normalisedMarch , file = "normalisedMarch2015.RData")