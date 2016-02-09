import os
import sys
from src.gp1.scrap.utils import *
from src.gp1.db.connection import *
from src.gp1.scrap.crawl_mvp import getMVPStats

connection = getConnection()

usefulConstants = constants()
pickledFolder = usefulConstants["PICKLED_FOLDER"]
sqlFolder = usefulConstants["SQL_FOLDER"]
playersPickled = pickledFolder + "players/"

def idGenerator():
    i = 1
    while True:
        yield i
        i = i+1


def loadBasicPlayerInfo(playersInfoList):
    print "loading the basic player info"
    insertSql = open(sqlFolder+"insert_into_basic_profile.sql").read()
    connection.executemany(insertSql, playersInfoList)


def loadPlayerSalaryInfo(playersSalaryList):
    print "loading the player salary info"
    insertSql = open(sqlFolder+"insert_into_player_salary.sql").read()
    connection.executemany(insertSql, playersSalaryList)


def loadPlayerTotalsInfo(playersTotalsList):
    print "loading the player totals info"
    insertSql = open(sqlFolder + "insert_into_players_totals.sql").read()
    connection.executemany(insertSql, playersTotalsList)

def loadMVPData(playerMVPStats):
    print "loading the player mvp information"
    insertSql = open(sqlFolder + "insert_into_mvp.sql").read()
    connection.executemany(insertSql, playerMVPStats)

def getBasicPlayerInfoList():
    playersInfoList = []
    for dirpath, dirnames, filenames in os.walk(playersPickled):
        for filename in filenames:
            filename = dirpath + filename
            print "returning basic profile info for  filename: ", filename
            player =  unpickle(filename)
            playersInfoList.append((player._name, player._dob, player._height, player._weight, player._fromYear,
                                    player._toYear, player._position, player._shootingHand, player._college,
                                    player._url))
    return playersInfoList

def getPlayerSalaryInfoList():
    playersSalaryList = []
    generator  = idGenerator()
    for dirpath, dirnames, filenames in os.walk(playersPickled):
        for filename in filenames:
            id = generator.next()
            filename = dirpath + filename
            print "returning salary info for  filename: ", filename
            player =  unpickle(filename)
            player_salary_objects = player._salary
            for eachSalary in player_salary_objects:
                salary = eachSalary._salary
                if salary == 'NA':
                    salary = 0
                else:
                    salary = salary.replace("$","").replace(",", "")

                playersSalaryList.append((id, eachSalary._season, eachSalary._team, eachSalary._league,
                                          int(salary)
                                         ))
    return playersSalaryList

def getPlayerTotalsList():
    playersTotalsList = []
    generator  = idGenerator()
    for dirpath, dirnames, filenames in os.walk(playersPickled):
        for filename in filenames:
            id = generator.next()
            filename = dirpath + filename
            print "returning totals info for  filename: ", filename
            player =  unpickle(filename)
            totals = player._totals
            for eachTotal in totals:
                team = eachTotal._team
                league = eachTotal._league
                if len(team) > 3:
                    team = 'NA'
                if len(league) > 3:
                    league = 'NA'
                playersTotalsList.append((id, unicode(eachTotal._season), eachTotal._age, team, league,
                                          unicode(eachTotal._position), eachTotal._games, eachTotal._gamesStarted,
                                         eachTotal._minutesPlayed, eachTotal._fieldGoals, eachTotal._fieldGoalsAttempted,
                                         eachTotal._threePoints, eachTotal._threePointsAttempted, eachTotal._twoPoints,
                                         eachTotal._twoPointsAttempted, eachTotal._effectiveFieldGoalPercentage, eachTotal._freeThrows,
                                         eachTotal._freeThrowsAttempted, eachTotal._offensiveRebounds,
                                         eachTotal._defensiveRebounds, eachTotal._assist, eachTotal._steals,
                                         eachTotal._blocks, eachTotal._turnOvers, eachTotal._personalFouls,
                                         eachTotal._points))

    return playersTotalsList


def main():
    print "*" * 15
    print "Menu"
    print "*" * 15
    print "1. Load BASIC_PLAYER_INFO  table"
    print "2. Load PLAYERS_SALARY table"
    print "3. Load PLAYERS_TOTALS table"
    print "4. Load MVP table"
    print "999. Exit"
    print "*" * 15
    choice = raw_input("Please enter a choice: ")
    choice =int(choice)
    print choice
    if choice == 1:
        basicPlayerInfoList = getBasicPlayerInfoList()
        loadBasicPlayerInfo(basicPlayerInfoList)
        connection.commit()

    elif choice == 2:
        playersSalaryList = getPlayerSalaryInfoList()
        loadPlayerSalaryInfo(playersSalaryList)
        connection.commit()
    elif choice == 3:
        playerTotalsList = getPlayerTotalsList()
        loadPlayerTotalsInfo(playerTotalsList)
        connection.commit()

    elif choice == 4:
        mvpStats = getMVPStats()
        loadMVPData(mvpStats)
        connection.commit()
    elif choice == 999:
        sys.exit(1)
    else:
        print "Please run the program again"


if __name__ == "__main__":
    main()

