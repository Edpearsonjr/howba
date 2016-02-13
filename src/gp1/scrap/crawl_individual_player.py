import ast
import httplib
import os
import sys
import urllib2 as urllib
import inspect

from bs4 import BeautifulSoup

from utils import *

from src.gp1.models.Player import Player
from src.gp1.models.Totals import Totals
from src.gp1.models.PerGame import PerGame
from src.gp1.models.Per36Minutes import Per36Minutes
from src.gp1.models.Salary import Salary
from src.gp1.models.Per100Possession import Per100Possession
from src.gp1.models.Advanced import Advanced

usefulConstants = constants()
csvFolder = usefulConstants["CSV_FOLDER"]
playersIndividualInfoFolder = usefulConstants["PLAYERS_INDIVIDUAL_INFO_FOLDER"]
pickledPlayerFolder = usefulConstants["PICKLED_FOLDER"] + "players/"
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
            player = self.__makePlayer(eachPlayer)
            if player:
                pickleObject(player, pickledPlayerFolder + player.name.strip().replace(" ", "") + ".pkl")


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
        toYear = player["to"]
        active = ast.literal_eval(player["active"])
        position = player["position"]
        dob = player["dob"]
        height = player["height"]

        # We are getting the info for the active players only here. The structure of the html for inactive
        # players is different

        html_for_player = self._getPlayerHtml(url)
        self._playerSoup = BeautifulSoup(html_for_player, "lxml")
        basicInfoDict = self._getBasicInfoOfPlayer()
        playerTotalsStatistics = self._getPlayerStatistics('all_totals')
        playerPerGameStatistics = self._getPlayerStatistics('all_per_game')
        playerPer36MinuteStatistics = self._getPlayerStatistics('all_per_minute')
        playerPer100PossessionStatistics = self._getPlayerStatistics('all_per_poss')
        playerAdvandedStatistics = self._getPlayerStatistics('all_advanced')
        playerSalaries = self._getPlayerStatistics('all_salaries')


        shootingHand = basicInfoDict["shootingHand"]
        experience = basicInfoDict["experience"]
        totals = self._getPlayerTotalsObjects(playerTotalsStatistics) if playerTotalsStatistics else []
        perGame = self._getPerGameObject(playerPerGameStatistics) if playerPerGameStatistics else []
        per36Minutes = self._getPer36MinutesObject(playerPer36MinuteStatistics) if playerPer36MinuteStatistics else []
        per100Possessions = self._getPer100PossessionObject(playerPer100PossessionStatistics) if playerPer100PossessionStatistics else []
        advanced = self._getAdvancedObject(playerAdvandedStatistics) if playerAdvandedStatistics else []
        if not playerSalaries:
            salary = []
        else:
            salary = self._getSalaryObject(playerSalaries)

        #now constructing the player Object with all the information
        player = Player(name=name, active=active, url=url, fromYear=fromYear, toYear=toYear,
                        position=position, height=height, weight=weight, dob=dob, college=college,
                        shootingHand=shootingHand, experience=experience, totals=totals, perGame=perGame,
                        per36Minutes=per36Minutes, per100Possessions= per100Possessions, advanced = advanced,
                        salary=salary)

        return player




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
            print "Getting the file from the disk"
            fileHandle = open(playersIndividualInfoFolder + filename)
            html = fileHandle.read()
        else:
            print "contacting the website for", url
            try:

                urlHandle = urllib.urlopen(url)
            except httplib.BadStatusLine:
                print "There is an error in opening the url"
                sys.exit(2)

            html = urlHandle.read()
            writeFile(playersIndividualInfoFolder + filename, html)
            sleepForAWhile()
        return html

    def _getBasicInfoOfPlayer(self):
        """
        This method makes use of the playerSoup and returns the basic info of the player that is not yet scrapped
        some of the basic info like the position and name are already scrapped from the player list page
        :return:
        """
        shootingHand = 'NA'
        experience = 'NA'

        playerInfoBox = self._playerSoup.find('div', {'id': 'info_box'})
        playerPaddingBottomHalfDiv = playerInfoBox.find('p', {'class': 'padding_bottom_half'})
        if playerPaddingBottomHalfDiv:
            spans = playerPaddingBottomHalfDiv.find_all('span')
            for span in spans:
                string = unicode(span.string)
                match = re.search('shoots', string, re.IGNORECASE)
                if match:
                    shootingHand = span.nextSibling.strip()
                match = re.search('experience', string, re.IGNORECASE)
                if match:
                    experience = span.nextSibling.replace("years", "").strip()

        marginLeftHalfDiv =  playerInfoBox.findAll('div', {'class': 'margin_left_half'})
        if marginLeftHalfDiv:
            marginLeftHalfDiv = marginLeftHalfDiv[0]
            spans = marginLeftHalfDiv.find_all('span')
            for span in spans:
                string = unicode(span.string)
                match = re.search("experience", string, re.IGNORECASE)
                if match:
                    experience = span.nextSibling
                    experience = experience.replace("years", "").strip()

        return dict(shootingHand = shootingHand, experience = experience)

    def _getPlayerStatistics(self, divId):
        """
        Given the divid it will fetch the information contained in the table inside it
        :param divId:
        :return:
        """
        div = self._playerSoup.find('div', {'id': divId})
        if not div:
            return None
        else:
            return scrapPlayerStatisticsTable(div)


    def _getPlayerTotalsObjects(self, stats):
        """
        This returns a list of the Totals obejcts
        every row in totals is a Totals object
        :param stats:
        :return: a list of obejcts
        """
        totalObjects = []
        for eachList in stats:
            total = Totals(*eachList)
            totalObjects.append(total)

        return totalObjects

    def _getPerGameObject(self, stats):
        perGameObjects = []
        for eachList in stats:
            perGame = PerGame(*eachList)
            perGameObjects.append(perGame)
        return perGame

    def _getPer36MinutesObject(self, stats):
        per36MinutesObjects = []
        for eachList in stats:
            per36Minute = Per36Minutes(*eachList)
            per36MinutesObjects.append(per36Minute)

        return per36MinutesObjects

    def _getSalaryObject(self, stats):
        salaryObjects = []
        for eachList in stats:
            salary = Salary(*eachList)
            salaryObjects.append(salary)
        return salaryObjects

    def _getPer100PossessionObject(self, stats):
        per100PossessionObjects = []
        for eachList in stats:
            per100PossessionObject = Per100Possession(*eachList)
            per100PossessionObjects.append(per100PossessionObject)
        return per100PossessionObjects

    def _getAdvancedObject(self, stats):
        advancedObjects = []
        for eachList in stats:
            advancedObject = Advanced(*eachList)
            advancedObjects.append(advancedObject)
        return advancedObjects


if __name__ == "__main__":
    playerInfoGenerator = PlayerStatsInfoGenerator(csvFolder+"/playersInitialInfo.csv")
    playerInfoGenerator.generateInfo()