from urllib2 import urlopen
import urllib2 as urllib
from bs4 import BeautifulSoup
from utils import writeCsv
from utils import constants
from utils import writeFile
import re
import numpy as np

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]
csvFolder = dataDir + "csv/"

#The team franchise page - General
#Lists out the basic team information
url = 'http://www.basketball-reference.com/teams/'
handle = urllib.urlopen(url)
# franchise_list = handle.read()
# print "Writing the HTML page for Team Franchise information"
# filename = "Team_Franchise.txt"
# writeFile(filename, franchise_list)
#
# if filename.endswith(".txt"):
#     print filename
#     fileHandle = open(filename)
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

    franchise_dict_temp = {'Franchise': franchise,
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
                               'Champ' : champ}

    franchise_dict.append(franchise_dict_temp)

writeCsv(franchise_dict, csvFolder + "Basic_Team_Franchise_Info.csv")

# Status message
print 'Built file Basic_Team_Franchise_Info.csv successfully.'

#Retrieve active links data
activeTableDiv = soup.findAll('div', {'class': 'stw'})[0]
fullTableTrs = activeTableDiv.findAll('tr', {'class': "full_table"})

seasons_dict = []
names_dict = []

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
                  if i == 1:
                      if j.get_text() == '':
                          lg = 'NA'
                      else:
                          lg = j.get_text().encode('utf-8')
                  if i == 2:
                      if j.get_text() == '':
                          team = 'NA'
                      else:
                          team = j.get_text().encode('utf-8')
                          team = re.sub("[^a-zA-Z]+", "", team)
                          team_name = team
                          link = j.find('a').get('href')
                          re.split("\W+", link)
                          link =  link[7:10]
                  if i == 3:
                      if j.get_text() == '':
                          w = 'NA'
                      else:
                          w = j.get_text().encode('utf-8')
                  if i == 4:
                      if j.get_text() == '':
                          l = 'NA'
                      else:
                          l = j.get_text().encode('utf-8')
                  if i == 5:
                      if j.get_text() == '':
                          wl = 'NA'
                      else:
                          wl = j.get_text().encode('utf-8')
                  if i == 6:
                      if j.get_text() == '':
                          finish = 'NA'
                      else:
                          finish = j.get_text().encode('utf-8')
                  if i == 7:
                      if j.get_text() == '':
                          srs = 'NA'
                      else:
                          srs = j.get_text().encode('utf-8')
                  if i == 8:
                      if j.get_text() == '':
                          pace = 'NA'
                      else:
                          pace = j.get_text().encode('utf-8')
                  if i == 9:
                      if j.get_text() == '':
                          rel_pace = 'NA'
                      else:
                          rel_pace = j.get_text().encode('utf-8')
                  if i == 10:
                      if j.get_text() == '':
                          ortg = 'NA'
                      else:
                          ortg = j.get_text().encode('utf-8')
                  if i == 11:
                      if j.get_text() == '':
                          rel_ortg = 'NA'
                      else:
                          rel_ortg = j.get_text().encode('utf-8')
                  if i == 12:
                      if j.get_text() == '':
                          drtg = 'NA'
                      else:
                          drtg = j.get_text().encode('utf-8')
                  if i == 13:
                      if j.get_text() == '':
                          rel_drtg = 'NA'
                      else:
                          rel_drtg = j.get_text().encode('utf-8')
                  if i == 14:
                      if j.get_text() == '':
                          playoffs = 'NA'
                      else:
                          playoffs = j.get_text().encode('utf-8')
                  if i == 15:
                      if j.get_text() == '':
                          coaches = 'NA'
                      else:
                          coaches = j.get_text().encode('utf-8')
                  if i == 16:
                      if j.get_text() == '':
                          topws = 'NA'
                      else:
                          topws = j.get_text().encode('utf-8')

              seasons_dict_temp = { 'Season' : season,
                                    'Lg' : lg,
                                    'Team': team,
                                    'W' : w,
                                    'L' : l,
                                    'W/L%' : wl,
                                    'Finish' : finish,
                                    'SRS' : srs,
                                    'Pace' : pace,
                                    'Rel_Pace' : rel_pace,
                                    'ORtg' : ortg,
                                    'Rel_ORtg' : rel_ortg,
                                    'DRtg' : drtg,
                                    'Rel_DRtg' : rel_drtg,
                                    'Playoffs' : playoffs,
                                    'Coaches' : coaches,
                                    'Top WS' : topws
                                  }
              names_dict_temp = { 'Team Name' : team_name,
                                  'Abbreviation' : link
                                }

              seasons_dict.append(seasons_dict_temp)
              names_dict.append(names_dict_temp)


writeCsv(seasons_dict, csvFolder + "Seasons_Team_Franchise_Info.csv")

#Status message
print 'Built file Seasons_Team_Franchise_Info.csv successfully.'

list_of_unique_dicts=list(np.unique(np.array(names_dict)))

writeCsv(list_of_unique_dicts,csvFolder+ "Unique_Dict.csv")

#Status message
print 'Built file Unique_Dict.csv successfully.'

#Retrieve active links data for get Stats_Total
activeTableDiv = soup.findAll('div', {'class': 'stw'})[0]
fullTableTrs = activeTableDiv.findAll('tr', {'class': "full_table"})

stats_total_dict = []

#Indentifying and following URLs
for t in fullTableTrs:

     for target in t.find_all('a'):
          team_Name = target.get_text()
          href =  target.get('href')
          teamUrl = "http://www.basketball-reference.com/"+href+"stats_totals.html"

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
                  if i == 1:
                      if j.get_text() == '':
                          lg = 'NA'
                      else:
                          lg = j.get_text().encode('utf-8')
                  if i == 2:
                      if j.get_text() == '':
                          tm = 'NA'
                      else:
                          tm = j.get_text().encode('utf-8')
                  if i == 3:
                      if j.get_text() == '':
                          w = 'NA'
                      else:
                          w = j.get_text().encode('utf-8')
                  if i == 4:
                      if j.get_text() == '':
                          l = 'NA'
                      else:
                          l = j.get_text().encode('utf-8')
                  if i == 5:
                      if j.get_text() == '':
                          finish = 'NA'
                      else:
                          finish = j.get_text().encode('utf-8')
                  if i == 7:
                      if j.get_text() == '':
                          age = 'NA'
                      else:
                          age = j.get_text().encode('utf-8')
                  if i == 8:
                      if j.get_text() == '':
                          ht = 'NA'
                      else:
                          ht = j.get_text().encode('utf-8')
                          re.split('\W+',ht)
                          ht =  ht
                  if i == 9:
                      if j.get_text() == '':
                          wt = 'NA'
                      else:
                          wt = j.string
                  if i == 11:
                      if j.get_text() == '':
                          g = 'NA'
                      else:
                          g = j.get_text().encode('utf-8')
                  if i == 12:
                      if j.get_text() == '':
                          mp = 'NA'
                      else:
                          mp = j.get_text().encode('utf-8')
                  if i == 13:
                      if j.get_text() == '':
                          fg = 'NA'
                      else:
                          fg = j.get_text().encode('utf-8')
                  if i == 14:
                      if j.get_text() == '':
                          fga = 'NA'
                      else:
                          fga = j.get_text().encode('utf-8')
                  if i == 15:
                      if j.get_text() == '':
                          fgp = 'NA'
                      else:
                          fgp = j.get_text().encode('utf-8')
                  if i == 16:
                      if j.get_text() == '':
                          threep = 'NA'
                      else:
                          threep = j.get_text().encode('utf-8')
                  if i == 17:
                      if j.get_text() == '':
                          threepa = 'NA'
                      else:
                          threepa = j.get_text().encode('utf-8')
                  if i == 18:
                      if j.get_text() == '':
                          threepp = 'NA'
                      else:
                          threepp = j.get_text().encode('utf-8')
                  if i == 19:
                      if j.get_text() == '':
                          twop = 'NA'
                      else:
                          twop = j.get_text().encode('utf-8')
                  if i == 20:
                      if j.get_text() == '':
                          twopa = 'NA'
                      else:
                          twopa = j.get_text().encode('utf-8')
                  if i == 21:
                      if j.get_text() == '':
                          twopp = 'NA'
                      else:
                          twopp = j.get_text().encode('utf-8')
                  if i == 22:
                      if j.get_text() == '':
                          ft = 'NA'
                      else:
                          ft = j.get_text().encode('utf-8')
                  if i == 23:
                      if j.get_text() == '':
                          fta = 'NA'
                      else:
                          fta = j.get_text().encode('utf-8')
                  if i == 24:
                      if j.get_text() == '':
                          ftp = 'NA'
                      else:
                          ftp = j.get_text().encode('utf-8')
                  if i == 25:
                      if j.get_text() == '':
                          orb = 'NA'
                      else:
                          orb = j.get_text().encode('utf-8')
                  if i == 26:
                      if j.get_text() == '':
                          drb = 'NA'
                      else:
                          drb = j.get_text().encode('utf-8')
                  if i == 27:
                      if j.get_text() == '':
                          trb = 'NA'
                      else:
                          trb = j.get_text()
                  if i == 28:
                      if j.get_text() == '':
                          ast = 'NA'
                      else:
                          ast = j.get_text().encode('utf-8')
                  if i == 29:
                      if j.get_text() == '':
                          stl = 'NA'
                      else:
                          stl = j.get_text().encode('utf-8')
                  if i == 30:
                      if j.get_text() == '':
                          blk = 'NA'
                      else:
                          blk = j.get_text().encode('utf-8')
                  if i == 31:
                      if j.get_text() == '':
                          tov = 'NA'
                      else:
                          tov = j.get_text().encode('utf-8')
                  if i == 32:
                      if j.get_text() == '':
                          pf = 'NA'
                      else:
                          pf = j.get_text().encode('utf-8')
                  if i == 33:
                      if j.get_text() == '':
                          pts = 'NA'
                      else:
                          pts = j.get_text().encode('utf-8')

              stats_total_dict_temp = { 'Season' : season,
                                        'Lg' : lg,
                                        'Tm' : tm,
                                        'W' : w,
                                        'L' : l,
                                        'Finish' : finish,
                                        'Age' : age,
                                        'Ht' : ht,
                                        'Wt' : wt,
                                        'G' : g,
                                        'MP' : mp,
                                        'FG' : fg,
                                        'FGA' : fga,
                                        'FG%' : fgp,
                                        '3P' : threep,
                                        '3PA' : threepa,
                                        '3P%' : threepp,
                                        '2P' : twop,
                                        '2PA' : twopa,
                                        '2P%' : twopp,
                                        'FT' : ft,
                                        'FTA' : fta,
                                        'FT%' : ftp,
                                        'ORB' : orb,
                                        'DRB' : drb,
                                        'TRB' : trb,
                                        'AST' : ast,
                                        'STL' : stl,
                                        'BLK' : blk,
                                        'TOV' : tov,
                                        'PF' : pf,
                                        'PTS' : pts
                                      }

              stats_total_dict.append(stats_total_dict_temp)

writeCsv(stats_total_dict, csvFolder + "Stats_Total_Team__Info.csv")

#Status message
print 'Built file Stats_Total_Team_Info.csv successfully.'
