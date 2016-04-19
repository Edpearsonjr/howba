################################################################################
# Preamble - Load all the libraries here 
#library('libraryName') # The purpose of the library 
################################################################################
library('lubridate')  # This helps in handling the day
library('sp')         # This helps in finding whether a point is inside a polygon 
library('geojsonio')  # helps in reading the geojson files

################################################################################
# Clearing the environment variables 
################################################################################
rm(list = ls())

################################################################################
# Some of the constants that are required 
################################################################################
BOROUGH_GEOJSON <- "../data/misc/boroughs.json"
NEIGHBORHOOD_GEOJSON <- "../data/misc/neighborhood.json"
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

getBoroughsData <- function(jsonfile){
    # @params jsonfile - geojson file containing the polygon coordinates
    json <- geojson_read(x = jsonfile)
    features <- json$features
    boroughData <- c()
    #coordinates has many lists inside it 
    # for eachList in coordinates:
    #   for latlng in eachList:
    #       x <- latlng[1]
    #       y <- latlng[2]
    for(l in 1:length(features)){
        feature <- features[[l]]
        coordinates <- feature$geometry$coordinates
        boroughName <- feature$properties$BoroName
        polygonType <- feature$geometry$type
        xcoord <- c()
        ycoord <- c()
        # process it here
        for(listOfCoordinates in coordinates){
            for(coordinates in listOfCoordinates){
                x <- coordinates[[2]]
                y <- coordinates[[1]]
                xcoord <- c(xcoord, x)
                ycoord <- c(ycoord, y)
            }
        }
        boroughX <- paste(gsub(" ", "",tolower(boroughName)),"_x", sep="")
        boroughY <- paste(gsub(" ", "",tolower(boroughName)),"_y", sep="")
        boroughData[[boroughX]] <- xcoord
        boroughData[[boroughY]] <- ycoord
        
        else if(polygonType == "MultiPolygon"){
            for(polygon in coordinates){
                for(listOfCoordinates in polygon){
                    for (eachCoordinate in listOfCoordinates){
                        x <- eachCoordinate[[2]]
                        y <- eachCoordinate[[1]]
                        xcoord <- c(xcoord, x)
                        ycoord <- c(ycoord, y)
                    }
                }
            }
            boroughX <- paste(gsub(" ", "",tolower(boroughName)),"_x", sep="")
            boroughY <- paste(gsub(" ", "",tolower(boroughName)),"_y", sep="")
            boroughData[[boroughX]] <- xcoord
            boroughData[[boroughY]] <- ycoord
        }
    }
    
    boroughData
}


getNeighborhoodData <- function(jsonfile){# @params jsonfile - geojson file containing the polygon coordinates
    json <- geojson_read(x = jsonfile)
    features <- json$features
    boroughData <- c()
    #coordinates has many lists inside it 
    # for eachList in coordinates:
    #   for latlng in eachList:
    #       x <- latlng[1]
    #       y <- latlng[2]
    for(l in 1:length(features)){
        feature <- features[[l]]
        coordinates <- feature$geometry$coordinates
        boroughName <- feature$properties$borough
        neighborhood <- feature$properties$neighborhood 
        polygonType <- feature$geometry$type
        xcoord <- c()
        ycoord <- c()
        # process it here
        if(polygonType == "Polygon"){
            for(listOfCoordinates in coordinates){
                for(coordinates in listOfCoordinates){
                    x <- coordinates[[2]]
                    y <- coordinates[[1]]
                    xcoord <- c(xcoord, x)
                    ycoord <- c(ycoord, y)
                }
            }
            boroughX <- paste(gsub(" ", "",tolower(boroughName)), "_", gsub(" ", "", tolower(neighborhood)),"_x", sep="")
            boroughY <- paste(gsub(" ", "",tolower(boroughName)), "_", gsub(" ", "", tolower(neighborhood)), "_y", sep="")
            boroughData[[boroughX]] <- xcoord
            boroughData[[boroughY]] <- ycoord
        }
    }
    
    boroughData
    
}
data <- getNeighborhoodData(NEIGHBORHOOD_GEOJSON)
x <- 40.7265 # These are manhattan coordinates
y <- -73.9815
print(isInsidePolygon(x, y,data$manhattan_x, data$manhattan_y))

x <- 40.8448 # These coordinates are the ones that are in bronx
y <- -73.8648
print(isInsidePolygon(x, y, data$manhattan_x, data$manhattan_y))


