from urllib2 import urlopen
import urllib2 as urllib
from bs4 import BeautifulSoup
from utils import writeCsv
from utils import constants
from utils import writeFile
import re
import sys
import os

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]
csvFolder = dataDir + "csv/"

url_coaches = 'http://www.basketball-reference.com/coaches/'
handle = urllib.urlopen(url_coaches)
html = handle.read()
soup = BeautifulSoup(html,"lxml")
table = soup.find('table')
tbody = table.findAll('tbody')

coaches_dict = []
coachBasicDict = []

for eachTBody in tbody:
    trs = eachTBody.find_all('tr')
    for tr in trs:
        for i, td in enumerate(tr.find_all('td')):
            if i == 0:
                if td.get_text() == '':
                    coach_name = 'NA'
                else:
                    coach = td.get_text()
                    coach = re.sub("[^a-z A-Z]+", "", coach)
                    coach_name = coach
            if i == 1:
                if td.get_text() == '':
                    from_date = 'NA'
                else:
                    from_date = td.get_text()
            if i == 2:
                if td.get_text() == '':
                    to_date = 'NA'
                else:
                    to_date = td.get_text()

        coachBasicDictTemp = {
                                 "Coach Name" : coach_name,
                                 "Active From" : from_date,
                                 "Active To" : to_date
                                 }
        coachBasicDict.append(coachBasicDictTemp)

writeCsv(coachBasicDict, csvFolder + "Coach_Basic_Data.csv")

#Status message

print 'The file Coach_Basic_Data.csv has been written successfully.'