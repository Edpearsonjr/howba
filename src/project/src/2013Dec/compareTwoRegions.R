library('dplyr')
library('ggplot2')


PICKUP_DISASTER_FILE <- "aroundTheDerailmentPickup20131124.RData"
DROPOFF_DISASTER_FILE <- "aroundTheDerailmentDropoff20131124.RData"
PICKUP_QUEENS_STATION_FILE <- "aroundTheQueensStationPickup20131124.RData"
DROPOFF_QUEENS_STATION_FILE <- "aroundTheQueensStationDropoff20131124.RData"

load(PICKUP_DISASTER_FILE)
load(DROPOFF_DISASTER_FILE)
load(PICKUP_QUEENS_STATION_FILE)
load(DROPOFF_QUEENS_STATION_FILE)
pickup_disaster <- tbl_df(aroundTheDerailmentPickup)
dropoff_disaster <- tbl_df(aroundTheDerailmentDropoff)
pickup_queens <- tbl_df(aroundTheQueensStationPickup)
dropoff_queens <- tbl_df(aroundTheQueensStationtDropoff)

pickup_disaster <- pickup_disaster %>%
                    mutate(pickup_time = ymd_hms(pickup_time), 
                    dropoff_time = ymd_hms(dropoff_time),
                    pickup_day = day(pickup_time),
                    pickup_hour = hour(pickup_time),
                    area = 'around the blast')

dropoff_disaster <- dropoff_disaster %>%
                        mutate(pickup_time = ymd_hms(pickup_time), 
                        dropoff_time = ymd_hms(dropoff_time),
                        dropoff_day = day(dropoff_time),
                        dropoff_hour = hour(dropoff_time),
                        area = 'around the blast')

pickup_queens <- pickup_queens %>%
                    mutate(pickup_time = ymd_hms(pickup_time), 
                    dropoff_time = ymd_hms(dropoff_time),
                    pickup_day = day(pickup_time),
                    pickup_hour = hour(pickup_time),
                    area= 'similar place')

dropoff_queens <- dropoff_queens %>%
                    mutate(pickup_time = ymd_hms(pickup_time), 
                    dropoff_time = ymd_hms(dropoff_time),
                    dropoff_day = day(dropoff_time),
                    dropoff_hour = hour(dropoff_time),
                    area= 'similar place')
                
    
    
################################################################
    # COMPARE THE PICKUPS IN THE TWO REGIONS AND 
    # GET THE HISTOGRAM PLOTS 
################################################################

dataForPickupHistogram  <- rbind(pickup_disaster, pickup_queens)
ggplot(dataForPickupHistogram, aes(pickup_hour, fill=area)) + 
    geom_density(alpha=0.5)


################################################################

# COMPARE THE DROPOFFS IN THE TWO REGIONS AND 
# GET THE HISTOGRAM PLOTS 
# FROM THE PLOTS IT CAN BE SEEN THAT THE DISTRIBUTION IS THE SAME

################################################################


dataForDropoffHistogram <- rbind(dropoff_disaster, dropoff_queens)
ggplot(dataForDropoffHistogram, aes(dropoff_hour, fill=area)) + 
    geom_density(alpha=0.5)


################################################################

# SEE HOW DIFFERENT VENDORS ARE OPERATING IN THESE TWO REGIONS
# FROM THE PLOTS THE DISTRIBUTIO OF HOW THE DIFFERENT VENDORS 
# OPERATE IN A DAY ARE ALSO THE SAME 

################################################################

dropoff_disaster_cmt <- dropoff_disaster %>%
                        filter(vendor_id=="CMT") %>%
                        mutate(vendor="CMT_DISASTER_AREA")

dropoff_disaster_vts <- dropoff_disaster %>%
                        filter(vendor_id=="VTS") %>%
                        mutate(vendor="VTS_DISASTER_AREA")

dropoff_queens_cmt <- dropoff_queens %>%
                        filter(vendor_id=="CMT") %>%
                        mutate(vendor="CMT_QUEENS")

dropoff_queens_vts <- dropoff_queens %>%
                        filter(vendor_id=="VTS") %>%
                        mutate(vendor="VTS_QUEENS")


dataForCMTAcrossTimeDistribution <- rbind(dropoff_disaster_cmt,
                                             dropoff_queens_cmt)


ggplot(dataForVendorAcrossTimeDistribution, aes(dropoff_hour, fill=vendor)) + 
    geom_density(alpha=0.5)




