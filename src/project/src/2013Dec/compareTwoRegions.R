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
# SOME OF THE UTILITY FUNCTIONS THAT IDEALLY HAS TO BE PUT IN UTILS.R 
# R DOESNT ALLOW ME TO SOURCE IT 
# SO ITS PUT HERE
################################################################    
getKSDValue <- function(collection1, collection2) {
    ksObject <- ks.test(collection1, collection2)
    ksObject$statistic
}

    
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

dataForVTSAcrossTimeDistribution <- rbind(dropoff_disaster_vts, 
                                          dropoff_queens_vts)

ggplot(dataForCMTAcrossTimeDistribution, aes(dropoff_hour, fill=vendor)) + 
    geom_density(alpha=0.5)

ggplot(dataForVTSAcrossTimeDistribution, aes(dropoff_hour, fill=vendor)) + 
    geom_density(alpha=0.5)



################################################################

    # USE THE STATISTICAL TESTS FOR THE TWO REGIONS ARE THE SAME 
    # WE FIND FROM THE PLOTS THAT THE DISTRIBUTION IS NOT A 
    # GAUSSIAN DISTRIBUTION AND WE NEED TO USE SOMETHING APART 
    # FROM T-TESTS WHICH ASSUME NORMAL DISTRIUBTION 
    # THERE IS K-S TEST THAT CAN BE USED IN THIS CASE
    # INTERPRETATION OF THIS IS AS FOLLOWS 
    # IF THE D VALUE IS CLOSE TO 0 IT IS LIKELY THAT THE TWO DISTRIBUTION ARE FROM THE SAME DISTRIBUTION 


################################################################


# COMPARING THE DROP OFF HOURS OF THE TWO AREAS USING KS TEST
distributions <- list(list(dropoff_disaster_cmt$dropoff_hour,dropoff_queens_cmt$dropoff_hour),
                   list(dropoff_disaster_vts$dropoff_hour, dropoff_queens_vts$dropoff_hour),
                   list(dropoff_disaster_cmt$tip_amount, dropoff_queens_cmt$tip_amount),
                   list(dropoff_disaster_vts$tip_amount, dropoff_queens_cmt$tip_amount),
                   list(dropoff_disaster_cmt$total_amount, dropoff_queens_cmt$total_amount),
                   list(dropoff_disaster_vts$total_amount, dropoff_queens_vts$total_amount),
                   list(dropoff_disaster_cmt$trip_distance, dropoff_queens_cmt$trip_distance),
                   list(dropoff_disaster_vts$trip_distance, dropoff_queens_vts$trip_distance))

dValues <- c()
for(distribution in distributions){
    dValues <- c(dValues, getKSDValue(distribution[[1]], distribution[[2]]))
}
print(dValues)