from utils import constants 
from utils import writeFile
from utils import sleepForAWhile
from utils import writeCsv
import urllib2 as urllib
import string 
from bs4 import BeautifulSoup
from utils import pickleObject

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]	
csvFolder = dataDir + "csv/"
pickleFolder = dataDir + "pickled/"
basePlayerUrl = usefulConstants["BASEPLAYER_URL"]
baseWebsiteUrl = usefulConstants["WEBSITE_URL"]

def getHtmlForPlayers(character):
	'''
		get the html for all the players mentioned by character
	'''	
	url = basePlayerUrl + character
	handle = urllib.urlopen(url)
	html_players = handle.read() #Contains all the players beginnign with `character`
	return html_players
	
def getPlayerUrlUsingBS4(directory):
	'''
		directory: Directory containing all the players-list files 
	'''
	players_initial_info = [] #This list contains dictionaries
	filename = dataDir + "player_lists_html/a-list.txt"
	fileHandle = open(filename)
	html = fileHandle.read()
	soup = BeautifulSoup(html, "lxml")
	playersTable = soup.find('table', {'id': 'players'}) # Contains all the rows of the table
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
				dateOfBirth = "dd-mm-yyyy"
				pass #This is for date of birth, needs some regex
			elif i == 7:
				college = td.string 
		player_dict = {'active': active, 'url': url, 'from': fromYear, 'to': toYear, 'position': position, 'height': height,
						'weight': weight, 'dob': dateOfBirth, 'college': college}
		players_initial_info.append(player_dict)
	writeCsv(players_initial_info, csvFolder + "playersInitialInfo.csv")



if __name__ == "__main__":
	
	# for letter in string.ascii_lowercase:
	# 	html = getHtmlForPlayers(letter)
	# 	filename = letter + "-list.txt"
	# 	print "writing file for: " + letter
	# 	writeFile(dataDir+"player_lists_html/"+filename, html)
	# 	sleepForAWhile()

	getPlayerUrlUsingBS4("")



