from bs4 import BeautifulSoup
import csv
import os
import urllib2 as urllib
import ast
import httplib
from Player import Player
from utils import *
import sys

usefulConstants = constants()
csvFolder = usefulConstants["CSV_FOLDER"]
playersIndividualInfoFolder = usefulConstants["PLAYERS_INDIVIDUAL_INFO_FOLDER"]

class PlayerStatsInfoGenerator():
    """
        This class takes in a csv file that contains the player information
        Parses the information that is contained in that csv file and in
        the individual players info page and generates the stats
    """
    def __init__(self, csvfile):
        self.csvfile = csvfile
        self.allPlayersBasicInfo = self.convertCsvToDictionary()
        self._playerSoup = None  #Yummy player soup

    @property
    def csvfile(self):
        return self.csvfile

    @csvfile.setter
    def csvfile(self, filename):
        if filename.endswith('csv'):
            self.csvfile = filename
        else:
            raise ValueError("There is a problem with you extension")

    @property
    def allPlayersBasicInfo(self):
        return self.allPlayersBasicInfo

    @allPlayersBasicInfo.setter
    def allPlayersBasicInfo(self, allPlayers):
        self.allPlayersBasicInfo = allPlayers


    @property
    def playerSoup(self):
        return self._playerSoup

    @playerSoup.setter
    def playerSoup(self, object):
        self._playerSoup = object

    def convertCsvToDictionary(self):
        try:
            csvFileHandle = open(self.csvfile, 'r')
            allPlayersBasicInfo = csv.DictReader(csvFileHandle)
            return allPlayersBasicInfo
        except:
            raise IOError("cant open the file")

    def generateInfo(self):
        """
        Read the dictionary one by one and generate a player
        :return:
        """
        for i, eachPlayer in enumerate(self.allPlayersBasicInfo):
                if i < 15:
                    self.__makePlayer(eachPlayer)

    def __makePlayer(self, player):
        """
        This gives birth to a player :p :D
        NOTE: This function takes the help of some other functions too :p
        :param player: player is a dictionary that contains the basic information
        :return: Player object that contains the information of the player
        """
        url = player["url"]
        college = player["college"]
        fromYear = player["from"]
        name = player["name"]
        weight = player["weight"]
        to = player["to"]
        active = ast.literal_eval(player["active"])
        position = player["position"]
        dob = player["dob"]
        height = player["dob"]

        # We are getting the info for the active players only here. The structure of the html for inactive
        # players is different
        if active:
            html_for_player = self._getPlayerHtml(url)
            self._playerSoup = BeautifulSoup(html_for_player, "lxml")
            print "getting the basic info for the player: ", name
            self._getBasicInfoOfActivePlayer()
        else:
            pass #We can implement this based on the requirement

    def _getPlayerHtml(self, url):
        """
        This method checks if we have already got the players file in the disk
        if it is not found in the disk, then query the website and get the html to store it
        The player file names are stored with the last part of the url as the file name
        TODO: Check if the file that is being accessed is older than `t` and if it is get it from the website
        :param url:
        :return: html file for the player
        """
        splitUrl = url.split('/')
        filename = splitUrl[len(splitUrl) - 1]
        if os.path.exists(playersIndividualInfoFolder + filename):
            print "The file is already there"
            fileHandle = open(playersIndividualInfoFolder + filename)
            html = fileHandle.read()
        else:
            print "contacting the website for getting player info"
            try:
                urlHandle = urllib.urlopen(url)
            except httplib.BadStatusLine:
                print "There is an error in opening the url"
                sys.exit(2)

            html = urlHandle.read()
            writeFile(playersIndividualInfoFolder + filename, html)
            sleepForAWhile()
        return html

    def _getBasicInfoOfActivePlayer(self):
        """
        This method makes use of the playerSoup and returns the basic info of the player that is not yet scrapped
        some of the basic info like the position and name are already scrapped from the player list page
        :return:
        """

        playerInfoBox = self._playerSoup.find('div', {'id': 'info_box'})
        playerPaddingBottomHalfDiv = playerInfoBox.find('p', {'class': 'padding_bottom_half'})
        shootingHandSpan = playerPaddingBottomHalfDiv.find_all('span')[1]
        shootingHand = shootingHandSpan.nextSibling

        marginLeftHalfDiv =  playerInfoBox.findAll('div', {'class': 'margin_left_half'})[0]
        spans = marginLeftHalfDiv.find_all('span')
        for span in spans:
            print span.string




if __name__ == "__main__":
    playerInfoGenerator = PlayerStatsInfoGenerator(csvFolder+"/playersInitialInfo.csv")
    playerInfoGenerator.generateInfo()