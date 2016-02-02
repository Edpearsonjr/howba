import time 
import csv
import pickle
def constants():
	'''
		Contains some of the constants needed
	'''
	constants = {
	"WEBSITE_URL": "http://www.basketball-reference.com",
	"BASEPLAYER_URL" : "http://www.basketball-reference.com/players/", #starting url for players
	"SLEEP_FOR": 1, #program sleep for the entire project, before crawling the next time 
	"DATA_DIR": "../data/"
	}
	return constants 


def sleepForAWhile(seconds = None):
	'''
		sleep the program for specified number of seconds 
	'''
	if seconds == None:
		seconds = constants()["SLEEP_FOR"]
	time.sleep(seconds)

def writeFile(filename, string):
	'''
		Write the string to the file 
	'''
	fileHandle = open(filename, "w")
	fileHandle.write(string)

def writeCsv(listOfDictionaries, filename):
	'''
		This takes in a list of dictionaries 
		keys of a dictionary is the header 
		the dictionaries are the rows 
	'''
	if not filename.endswith('csv'):
		print "Please provide a filename that ends with csv"
	
	header = listOfDictionaries[0].keys() #Take the keys of the first dictionary as headers
	with open(filename, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames = header)
		writer.writeheader()
		for eachDict in listOfDictionaries:
			writer.writerow(eachDict)

def pickleObject(obj, filename):
	filehandle = open(filename, 'wb')
	pickle.dump(obj, filehandle)
