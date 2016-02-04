import time 
import csv
import pickle
import re
def constants():
    """
        Contains some of the constants needed
    """
    constants = dict(WEBSITE_URL="http://www.basketball-reference.com",
                     BASEPLAYER_URL="http://www.basketball-reference.com/players/",
                     SLEEP_FOR=5,
                     DATA_DIR="../data/")
    return constants


def sleepForAWhile(seconds = None):
    """
        sleep the program for specified number of seconds
        :param seconds: numbe of seconds to sleep
    """
    if seconds is None:
        seconds = constants()["SLEEP_FOR"]
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

def cleanHtmlForRegex(html):
    """
    Cleans the html of \n and spaces and makes it ready for further regex matching
    :param html:
    :return: cleaned html
    """
    html = re.sub(r'\s*', '', html) #replacing all the white space characters and returning
    return html
