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
        if(polygonType== "Polygon"){
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
        }
        
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


whichBorough <- function(lat,long, boroughs_data){
    # Returns the borough name for the lat long 
    # A wrapper function 
    boroughs_names <- names(boroughs_data)
    print(boroughs_names)
    unique_names <- unique(sapply(strsplit(boroughs_names,"_"), function(x){x[[1]]}))
    name <- ""
    for(everyBorough in unique_names){
        xCoord <- paste(everyBorough,"_x", sep="")
        yCoord <- paste(everyBorough,"_y", sep="")
        print(xCoord)
        boroughXCoordinates <- as.list(boroughs_data[[xCoord]])
        boroughYCoordinates <- as.list(boroughs_data[[yCoord]])
        print(boroughXCoordinates)
        if(isInsidePolygon(lat, long, boroughXCoordinates, boroughYCoordinates)== TRUE){
            name <- everyBorough
            break;
        }
    }
    name
}

################################################################################
# Test the code 
################################################################################
data <- getBoroughsData(BOROUGH_GEOJSON)
x <- 40.7265 # These are manhattan coordinates
y <- -73.9815
print(isInsidePolygon(x, y,data$manhattan_x, data$manhattan_y))
borough_name <- whichBorough(x, y, data)
print(borough_name)

x <- 40.8448 # These coordinates are the ones that are in bronx
y <- -73.8648
print(isInsidePolygon(x, y, data$manhattan_x, data$manhattan_y))
# 
# #Checks to see whether the point is inside the bounding box defined inside the coordinates
x <- 40.7204
y <- -73.8412
lat_max <- 40.7457829458
lat_min <- 40.6734170542
lon_max <- -73.7829268215
lon_min <- -73.8783931785
isInsidePolygon(x, y, c(lat_max, lat_max, lat_min, lat_min), c(lon_min, lon_max, lon_max, lon_min))
