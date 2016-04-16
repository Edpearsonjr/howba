import csv
import requests
from polyline.codec import PolylineCodec
import time
import datetime

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
        self.pickupStructTime = pickupStruct
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
            stepsList.append({"time": datetime.datetime.fromtimestamp(time.mktime(self.pickupStructTime)) + datetime.timedelta(seconds=counter),
                              "cabRideNumber": self.cabRideNumber,
                              'latitude': lat,
                              'longitude': long})
        return stepsList


    def getPaths(self):
        self.responseJson = self.__makeRequest()
        self.lines = self.convertToLines(self.responseJson)
        return self.lines

if __name__ == "__main__":
    csvFile = "../data/aroundTheBlast.csv"
    csvreader = csv.reader(open(csvFile))
    header = csvreader.next()
    allCabData =[]
    for i, row in enumerate(csvreader):
        print "processing for the cab", str(i)
        if i == 100:
            break
        startLatitude = row[8]
        startLongitude = row[7]
        endLatitude = row[11]
        endLongitude = row[10]
        pickupTime = time.strptime(row[3],'%Y-%m-%d %H:%M:%S')
        dropOffTime = time.strptime(row[4], '%Y-%m-%d %H:%M:%S')
        paths = GooglePaths(startLatitude, startLongitude, endLatitude, endLongitude, pickupTime, i)
        lod = paths.getPaths()
        allCabData = allCabData + lod
        print "will get up after 1 seconds"
        time.sleep(1)

    keys = allCabData[0].keys()
    timeDataFile = open('../data/time_data_aroundTheBlast100.csv', 'w')
    writer = csv.DictWriter(timeDataFile, keys)
    writer.writeheader()
    writer.writerows(allCabData)


