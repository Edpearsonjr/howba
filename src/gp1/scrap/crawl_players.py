from utils import constants 
from utils import writeFile
from utils import sleepForAWhile
from utils import writeCsv
from utils import cleanHtmlForRegex
import urllib2 as urllib
import string 
from bs4 import BeautifulSoup
import re
import os 
import sys
import getopt
from regex_definitions import *

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]	
csvFolder = dataDir + "csv/"
pickleFolder = dataDir + "pickled/"
playerListsFolder = dataDir + "player_lists_html/"
basePlayerUrl = usefulConstants["BASEPLAYER_URL"]
baseWebsiteUrl = usefulConstants["WEBSITE_URL"]


def getHtmlForPlayers(character):
	"""
		get the html for all the players mentioned by character
		:return:
		:param character:
	"""
	url = basePlayerUrl + character
	handle = urllib.urlopen(url)
	html_players = handle.read() #Contains all the players beginning with `character`
	return html_players
	
def getPlayerUrlUsingBS4(directory):
	"""
		directory: Directory containing all the players-list files
		:param directory:
	"""
	players_initial_info = [] #This list contains dictionaries
	for (dirpath, dirnames, filenames) in os.walk(directory):		
		for filename in filenames:
			print "generating the dictionaries for: ", filename
			filename = dirpath + filename 
			if filename.endswith(".txt"):
				fileHandle = open(filename)
				html = fileHandle.read()
				soup = BeautifulSoup(html, "lxml")
				playersTable = soup.find('table', {'id': 'players'}) # Contains all the rows of the table
				if not playersTable:
					continue
				tablebody = playersTable.find('tbody')
				trs = tablebody.find_all('tr')
				for tr in trs:
					for i, td in enumerate(tr.find_all('td')):
						if i == 0:				
							if td.find('strong'): 
								active = True
								anchorTag = td.find('strong').find('a')
							else:
								active = False  
								anchorTag = td.find('a')
							name = anchorTag.string 
							url =  baseWebsiteUrl + anchorTag['href']
						elif i == 1:
							fromYear = td.string 
						elif i == 2:
							toYear = td.string 
						elif i == 3:
							position = td.string 
						elif i == 4:
							height = td.string 			
						elif i == 5:
							weight = td.string 
						elif i == 6:
							# We would wanna store the date of birth as dd-mm-yyyy
							# dd and mm is available in the href tag
							# year is available in the innerHTML				
							dobAnchorTag = td.find('a')
							if dobAnchorTag:
								year = dobAnchorTag.string.split(',')[1].strip()
								href = dobAnchorTag['href'] 
								pattern = r"""
								^\D*					#This can start with anything
								month=(\d{1,2})			# month needs to have either 1 or two digits
								&						#ampersand is used in the GET call by the website to combine two query parameters
								day=(\d{1,2})			# Day has to be a digit with either 1 or 2 digits
								"""
								match = re.search(pattern, href, re.VERBOSE)
								if match:
									groups = match.groups()
									month = groups[0]
									day = groups[1]
								# I have not handled the else part here
								# It seems like everyone's date of birth is indeed available
								dateOfBirth = str(day) +  "-" + str(month) + "-" + str(year)
							else:
								dateOfBirth = 'NA'					
						elif i == 7:
							collegeAnchorTag = td.find('a')
							if collegeAnchorTag:
								college = collegeAnchorTag.string 
							else:
								college = 'NA' 

					player_dict = {'active': active, 'url': url, 'from': fromYear, 'to': toYear, 'position': position, 'height': height,
									'weight': weight, 'dob': dateOfBirth, 'college': college}
					players_initial_info.append(player_dict)				
			else:
				print "Filenames without .txt extension are fad :p"
	writeCsv(players_initial_info, csvFolder + "playersInitialInfo.csv")

def getPlayerUsingRegEx(directory):
    filename = playerListsFolder + "a-list.txt"
    fileHandle = open(filename, "r")
    html = fileHandle.read()
    allTrsRegex = reGetAllTrInListPage()
    alltrs = re.findall(allTrsRegex, html, re.VERBOSE | re.DOTALL)[0]
    alltrs = alltrs.replace("\n", "").replace("\t", "")
    innerHtmlRegex = reGetInnerHtmlWithinATrInListPage() #To get info within tr
    tdRegex = reGetTdsWithinTrInListPage() #To get the info within tds
    matchIterator = re.finditer(innerHtmlRegex, alltrs, re.VERBOSE)
    for i, match in enumerate(matchIterator):
        if i == 0:
            tds = match.group(1)




def main(argv):
	try:
		opts, args = getopt.getopt(argv, 'hlcr')
		if len(opts) == 0:
			print "type python crawlplayers.py -h for help"
			sys.exit(2)			
	except getopt.GetoptError:
		print "To run the file use python crawlplayers.py -l -c as options"
		sys.exit(2)
	for opt, arg in opts:
		if opt == "-h":
			print "To run the file use python crawlplayers.py with -h or -i or both as options"
			sys.exit()
		elif opt == "-l":
			for letter in string.ascii_lowercase:
				html = getHtmlForPlayers(letter)
				filename = letter + "-list.txt"
				print "writing file for: " + letter
				writeFile(playerListsFolder + filename, html)
				sleepForAWhile()
		elif opt == "-c":
			getPlayerUrlUsingBS4(playerListsFolder)
		elif opt == "-r":
			getPlayerUsingRegEx(playerListsFolder)
		else:
			print "type python crawlplayers.py -h for help"
			sys.exit()

if __name__ == "__main__":
	main(sys.argv[1:])
	
	
	



