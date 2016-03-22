from urllib2 import urlopen
import urllib2 as urllib
from bs4 import BeautifulSoup
from utils import writeCsv
from utils import constants
import re

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]
csvFolder = dataDir + "csv/"

#Team URL
url_team = 'http://www.basketball-reference.com/teams/'
handle = urllib.urlopen(url_team)
html = handle.read()
soup = BeautifulSoup(html,"lxml")
franchiseTable = soup.find('table')
table_body = soup.find('tbody')
trs = table_body.find_all('tr')

franchise_dict = []

for tr in trs:
    for i, td in enumerate(tr.find_all('td')):
        if i == 0:
            franchise = td.get_text()
        if i == 1:
            lg_text = td.get_text()
        if i == 2:
            from_date = td.get_text()
        if i == 3:
            to = td.get_text()
        if i == 4:
            yrs = td.get_text()
        if i == 5:
            g = td.get_text()
        if i == 6:
            w = td.get_text()
        if i == 7:
            l = td.get_text()
        if i == 8:
            wl = td.get_text()
        if i == 9:
            if td.get_text() == '':
                plyfs = "NA"
            else:
                plyfs = td.get_text()
        if i == 10:
            div = td.get_text()
        if i == 11:
            if td.get_text() == '':
                conf = "NA"
            else:
                conf = td.get_text()
        if i == 12:
            if td.get_text() == '':
                champ = "NA"
            else:
                champ = td.get_text()

    franchise_dict_temp = { 'Franchise': franchise,
                            'Lg' : lg_text,
                            'From' : from_date,
                            'To' : to,
                            'G' : g,
                            'Yrs' : yrs,
                            'W':w,
                            'L':l,
                            'W/L%' : wl,
                            'Plyfs' : plyfs,
                            'Div' : div,
                            'Conf' : conf,
                            'Champ' : champ
                           }

franchise_dict.append(franchise_dict_temp)

writeCsv(franchise_dict, csvFolder + "Team_Franchise_Info.csv")

# Status message
print 'Built file Team_Franchise_Info.csv successfully.'

#Retrieve active links data
activeTableDiv = soup.findAll('div', {'class': 'stw'})[0]
fullTableTrs = activeTableDiv.findAll('tr', {'class': "full_table"})

seasons_dict = []
names_dict = []
teamSalDict = []

#Indentifying and following URLs
for t in fullTableTrs:

     for target in t.find_all('a'):
          teamName = target.get_text()
          href =  target.get('href')
          teamUrl = "http://www.basketball-reference.com/"+href

          print teamUrl
          current_webpage = urlopen(teamUrl).read()
          current_soup = BeautifulSoup(current_webpage, "lxml")
          current_table = current_soup.find("table")
          current_body = current_table.find("tbody")
          current_trs = current_body.find_all("tr")

          for tr in current_trs:

              for i,j in enumerate(tr.find_all("td")):
                  if i == 0:
                      if j.get_text() == '':
                          season = 'NA'
                      else:
                          season = j.get_text().encode('utf-8')
                  if i == 2:
                      if j.get_text() == '':
                          team = 'NA'
                      else:
                          team = j.get_text().encode('utf-8')
                          team = re.sub("[^a-zA-Z]+", "", team)
                          team_name = team
                          link = j.find('a').get('href')
                          re.split("\W+", link)
                          link = link[7:10]
                          full_link = j.find('a').get('href')
                          pathToFollow = "http://www.basketball-reference.com" + full_link
                          print 'Following the path ' + pathToFollow

                          nested_webpage = urlopen(pathToFollow).read()
                          nested_soup = BeautifulSoup(nested_webpage, "lxml")
                          nestedTable = nested_soup.find('table', {'id':'salaries'} , {'class' : 'stats_table'})
                          if not nestedTable:
                              continue
                          nestedBody = nestedTable.find("tbody")
                          if not nestedBody:
                              continue
                          nestedTrs = nestedBody.findAll('tr')
                          print nestedTrs

                          for tr in nestedTrs:
                              for i, j in enumerate(tr.find_all("td")):
                                  if i == 1:
                                      if j.get_text() == '':
                                          player = 'NA'
                                      else:
                                          player = j.get_text().encode('utf-8')
                                  if i == 2:
                                      if j.get_text() == '':
                                          salary = 'NA'
                                      else:
                                          salary = j.get_text().encode('utf-8')

                              teamSalDict_temp = {
                                                    'Season' : season,
                                                    'Team Name' : team_name,
                                                    'Link' : link,
                                                    'Player' : player,
                                                    'Salary' : salary
                                                  }
                              teamSalDict.append(teamSalDict_temp)

writeCsv(teamSalDict, csvFolder + "Team_Sal_Info.csv")

#Status message
print 'Built file Team_Sal_Info.csv successfully.'
