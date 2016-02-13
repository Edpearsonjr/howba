import time
import pickle
import re
import csv
import os
from src.gp1.root import getRootPath
gp1RootDirectory = getRootPath() + "/"

def constants():
    """
        Contains some of the constants needed
    """
    constants = dict(WEBSITE_URL="http://www.basketball-reference.com",
                     BASEPLAYER_URL="http://www.basketball-reference.com/players/",
                     MVP_URL = "http://www.basketball-reference.com/awards/mvp.html",
                     SLEEP_FOR=1,
                     DATA_DIR=gp1RootDirectory + "data/",
                     CSV_FOLDER= gp1RootDirectory + "data/csv/",
                     PLAYER_LISTS_FOLDER = gp1RootDirectory + "data/player_lists_html/",
                     PICKLED_FOLDER = gp1RootDirectory + "data/pickled/",
                     PLAYERS_INDIVIDUAL_INFO_FOLDER= gp1RootDirectory + "data/players_individual_info/",
                     DB_FILE = gp1RootDirectory + "db/basketBall.db",
                     SQL_FOLDER = gp1RootDirectory + "db/sql/")
    return constants


def sleepForAWhile(seconds = None):
    """
        sleep the program for specified number of seconds
        :param seconds: numbe of seconds to sleep
    """
    if seconds is None:
        seconds = constants()["SLEEP_FOR"]
    print "sleeping for:", seconds
    time.sleep(seconds)

def writeFile(filename, string):
    """
        Write the string to the file
        :param filename: filename to open and write
        :param string: string to be written into the file
    """
    fileHandle = open(filename, "w")
    fileHandle.write(string)

def writeCsv(listOfDictionaries, filename):
    """
        This takes in a list of dictionaries
        keys of a dictionary is the header in csv
        the dictionaries are the rows in csv
        :param listOfDictionaries: [{}, {}] is converted to csv
        :param filename: csv filename
    """
    print "Writing the csv"
    if not filename.endswith('csv'):
        print "Please provide a filename that ends with csv"
    header = listOfDictionaries[0].keys() #Take the keys of the first dictionary as headers
    with open(filename, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = header)
        writer.writeheader()
        for eachDict in listOfDictionaries:
            writer.writerow(eachDict)

def pickleObject(obj, filename):
    """

    :param obj: object to write to file
    :param filename: file name
    :return: None
    """
    filehandle = open(filename, 'wb')
    pickle.dump(obj, filehandle)

def unpickle(filename):
    fileHandle = open(filename, 'rb')
    return pickle.load(fileHandle)


def cleanHtmlForRegex(html):
    """
    Cleans the html of \n and spaces and makes it ready for further regex matching
    :param html:
    :return: cleaned html
    """
    html = re.sub(r'\s*', '', html) #replacing all the white space characters and returning
    return html

def scrapPlayerStatisticsTable(soup):
    """
    This takes a Beautiful Soup and then returns whatever the content is inside everyrow
    :param soup:
    :return:
    """
    tableContainerDiv = soup.find('div', {'class': 'table_container'})
    table = tableContainerDiv.find('table')
    tbody = table.find('tbody')
    trs = tbody.find_all('tr')
    statistics = []
    for tr in trs:
        tds = tr.find_all('td')
        rowData = []
        for td in tds:
            anchorTag = td.find_all('a') #if there is an anchor tag then find it
            if anchorTag:
                rowData.append(anchorTag[0].string.encode('utf-8'))
            elif td.string:
                rowData.append(td.string.encode('utf-8'))
        statistics.append(rowData)

    return statistics

def getListOfTuplesFromCsv(csvfilename):
    listOfTuples = []
    with open(csvfilename, 'rb') as csvHandle:
        teamMapping = csv.reader(csvHandle, delimiter=',')
        next(teamMapping, None)
        for everyRow in teamMapping:
            everyRow = map(lambda x: str(x), everyRow)
            listOfTuples.append(tuple(everyRow))
    return listOfTuples

# This defines a simple decorator
# This decorator is used to time functions, that take in arguments

def generalWrapper(func, *args, **kwargs):
    def wrapped():
        return func(*args, **kwargs)
    return wrapped


if __name__ == "__main__":
    constants()