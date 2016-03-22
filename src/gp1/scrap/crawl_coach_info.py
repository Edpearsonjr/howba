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

for eachTBody in tbody:
    trs = eachTBody.find_all('tr')
    for tr in trs:
        for i,td in enumerate(tr.find_all('td')):
            if i == 0:
             if td.get_text() == '':
                 coach_name = 'NA'
             else:
                 coach = td.get_text()
                 coach = re.sub("[^a-z A-Z]+", "", coach)
                 coach_name = coach  #1 - Dictionary Column 1
                 link = td.find('a').get('href')
                 follow_link = 'http://www.basketball-reference.com' + link
                 print 'Following the path ' + follow_link


                 indv_webpage = urlopen(follow_link).read()
                 current_soup = BeautifulSoup(indv_webpage, "lxml")
                 currentTable = current_soup.find('table', {'id':'stats'})
                 tfoot = currentTable.find('tfoot')
                 trs = tfoot.find('tr')
                 td = trs.findAll('td')


                 for i, j in enumerate(td):
                     if i == 2:
                         if j.get_text() == '':
                             Lg = 'NA'
                         else:
                             Lg = j.get_text().encode('utf-8') #2 - Dictionary Column 2
                     if i == 4:
                         if j.get_text() == '':
                             G = 'NA'
                         else:
                             G = j.get_text().encode('utf-8')
                     if i == 5:
                         if j.get_text() == '':
                             W = 'NA'
                         else:
                             W = j.get_text().encode('utf-8')
                     if i == 6:
                         if j.get_text() == '':
                             L = 'NA'
                         else:
                             L = j.get_text().encode('utf-8')
                     if i == 7:
                         if j.get_text() == '':
                             WLP = 'NA'
                         else:
                             WLP = j.get_text().encode('utf-8')
                     if i == 8:
                         if j.get_text() == '':
                             W_500 = 'NA'
                         else:
                             W_500 = j.get_text().encode('utf-8')
                     if i == 9:
                         if j.get_text() == '':
                             finish = 'NA'
                         else:
                             finish = j.get_text().encode('utf-8')
                     if i == 10:
                         if j.get_text() == '':
                             plyOffG = 'NA'
                         else:
                             plyOffG = j.get_text().encode('utf-8')
                     if i == 11:
                         if j.get_text() == '':
                             plyOffW = 'NA'
                         else:
                             plyOffW = j.get_text().encode('utf-8')
                     if i == 12:
                         if j.get_text() == '':
                             plyOffL = 'NA'
                         else:
                             plyOffL = j.get_text().encode('utf-8')
                     if i == 13:
                         if j.get_text() == '':
                             plyOffWLP = 'NA'
                         else:
                             plyOffWLP = j.get_text().encode('utf-8')

                 coaches_dict_temp = {
                                        'Coach Name' : coach_name,
                                        'Lg' : Lg,
                                        'G' : G,
                                        'W' : W,
                                        'L' : L,
                                        'WLP' : WLP,
                                        'W_500' : W_500,
                                        'PlayOff-G' : plyOffG,
                                        'PlayOff-W' : plyOffW,
                                        'PlayOff-L' : plyOffL,
                                        'Playoff-WLP' : plyOffWLP
                                     }
                 coaches_dict.append(coaches_dict_temp)

writeCsv(coaches_dict, csvFolder + "Coach_Statistics.csv")

#Status message
print 'The file Coach_Statistics.csv has been built successfully'






