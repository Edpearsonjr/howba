################################################################################
# Preamble - Load all the libraries here 
#library('libraryName') # The purpose of the library 
################################################################################
library('lubridate')  # This helps in handling the day
library('sp')         # This helps in finding whether a point is inside a polygon 

################################################################################
# Clearing the environment variables 
################################################################################
rm(list = ls())

################################################################################
# Some of the constants that are required 
################################################################################
BOROUGH_GEOJSON <- "../data/misc/boroughs.json"

groupIntoTimeOfTheDay <- function(date){
  # @params date -> lubridate object 
  # 3-6 am is EarlyMorning
  # 6-9 am    Morning 
  # 9-4 pm    Noon 
  # 4-9 pm    Evening
  # 9-12:00   Night
  # 00:00-3   VeryEarlyMorning 
  
  hour <- hour(date)
  category <- ""
  # put the logic here 
  if(hour >=0 & hour<3){
    category <- "VerYEarlyMorning"
  } else if(hour >=3 & hour<6){
    category <- "EarlyMorning"
  } else if(hour >=6 & hour<9){
    category <- "Morning"
  } else if(hour>=9 & hour<16){
    category <- "Noon"
  } else if(hour>=16 & hour<21){
    category <- "Evening"
  }  else if(hour>=21 & hour<=23){
    category <- "Night"
  }
  category
}


getBoroughs <- function(latitude, longitude){
  # @params: latitude -> float 
  #          longitude -> float
          
}

getBoroughsDataFrame <- function(jsonfile){
    # @params jsonfile - geojson file containing the polygon coordinates
    

}

getBoroughsDataFrame(BOROUGH_GEOJSON)




