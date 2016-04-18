import csv
import requests
from polyline.codec import PolylineCodec
import time
import datetime
import random

class GooglePaths():
    """
    This tries to get all the coordinates along the start and end of a path for a user
    """

    def __init__(self, startLatitude, startLongitude, endLatitude, endLongitude, pickupStruct, cabRideNumber):
        self.baseUrl = "https://maps.googleapis.com/maps/api/directions/json?"
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.pickupTime = pickupStruct
        self.cabRideNumber = cabRideNumber
        self.apiKey = "AIzaSyCuzBdk6sIIrrJpgQmcJbwtfumumuRLStU"
        self.polylineCodec = PolylineCodec()


    def __makeRequest(self):
        requestUrl = self.baseUrl + "origin= " + self.startLatitude + "," + self.startLongitude + "&destination= " + self.endLatitude + "," + self.endLongitude + "&key= " + self.apiKey
        response = requests.request("GET", requestUrl)
        return response.json()

    def convertToLines(self, responseJson):
        polyline = responseJson["routes"][0]["overview_polyline"]["points"]
        points =  self.polylineCodec.decode(polyline)
        stepsList =[]
        counter = 0
        for lat, long in points:
            counter += 1
            stepsList.append({"time": str(pickupTime + datetime.timedelta(seconds=counter+5)),
                              "cabRideNumber": self.cabRideNumber,
                              'latitude': lat,
                              'longitude': long})

        stepsListFinal = [stepsList[0]]
        length = len(stepsList)
        sample = []
        if len(stepsList)-2 > 20:
            sample = random.sample(stepsList[1: (length-2)], length/6)

        stepsListFinal = stepsListFinal + sample + [stepsList[length -1]]

        return stepsListFinal


    def getPaths(self):
        self.responseJson = self.__makeRequest()
        self.lines = self.convertToLines(self.responseJson)
        return self.lines

if __name__ == "__main__":
    csvFile = "20130112AroundTheBlast.csv"
    csvreader = csv.reader(open(csvFile))
    header = csvreader.next()
    allCabData =[]
    for i, row in enumerate(csvreader):
        print "processing for the cab", str(i)
        startLatitude = row[12]
        startLongitude = row[13]
        endLatitude = row[3]
        endLongitude = row[4]
        pickupTime = row[14].replace("AM", "").strip().replace("/", "-")
        pickupTime = datetime.datetime.strptime(pickupTime,'%d-%m-%Y %H:%M:%S')
        dropOffTime = row[5].replace("AM", "").strip().replace("/", "-")
        dropOffTime = datetime.datetime.strptime(dropOffTime, '%d-%m-%Y %H:%M:%S')
        paths = GooglePaths(startLatitude, startLongitude, endLatitude, endLongitude, pickupTime, i)
        lod = paths.getPaths()
        allCabData = allCabData + lod
        print "will get up after 1 seconds"
        time.sleep(1)

    keys = allCabData[0].keys()
    timeDataFile = open('201312Time1.csv', 'w')
    writer = csv.DictWriter(timeDataFile, keys)
    writer.writeheader()
    writer.writerows(allCabData)


