import os
import sys
import csv

from src.gp1.scrap.utils import *
from src.gp1.db.connection import *
from src.gp1.scrap.crawl_mvp import getMVPStats

connection = getConnection()
connection.text_factory = str

usefulConstants = constants()
pickledFolder = usefulConstants["PICKLED_FOLDER"]
sqlFolder = usefulConstants["SQL_FOLDER"]
csvFolder = usefulConstants["CSV_FOLDER"]
playersPickled = pickledFolder + "players/"

def idGenerator():
    i = 1
    while True:
        yield i
        i = i+1


def loadTable(listOfTuples, insertSqlFilename):
    print "loading the table in: ", insertSqlFilename
    insertSql = open(sqlFolder + insertSqlFilename).read()
    connection.executemany(insertSql, listOfTuples)


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
    print "5. Load TEAM_MAPPING table"
    print "6. Load BASIC_FRANCHISE_INFO table"
    print "7. Load SEASONS_FRANCHISES table"
    print "8. Load STATS_INFO table"
    print "999. Exit"
    print "*" * 15
    choice = raw_input("Please enter a choice: ")
    choice =int(choice)
    print choice
    if choice == 1:
        basicPlayerInfoList = getBasicPlayerInfoList()
        loadTable(basicPlayerInfoList, "insert_into_basic_profile.sql")
        connection.commit()

    elif choice == 2:
        playersSalaryList = getPlayerSalaryInfoList()
        loadTable(playersSalaryList, "insert_into_player_salary.sql")
        connection.commit()
    elif choice == 3:
        playerTotalsList = getPlayerTotalsList()
        loadTable(playerTotalsList, "insert_into_players_totals.sql")
        connection.commit()

    elif choice == 4:
        mvpStats = getMVPStats()
        loadTable(mvpStats, "insert_into_mvp.sql")
        connection.commit()

    elif choice == 5:
        csvfile = csvFolder + "team_mapping.csv"
        teamMappingInfo = getListOfTuplesFromCsv(csvfile)
        loadTable(teamMappingInfo, "insert_into_team_mapping.sql")
        connection.commit()

    elif choice == 6:
        csvfile = csvFolder + "basic_team_franchise_info.csv"
        teamFranchiseInfo = getListOfTuplesFromCsv(csvfile)
        loadTable(teamFranchiseInfo, "insert_into_basic_franchise_info.sql")
        connection.commit()

    elif choice == 7:
        csvFile = csvFolder + "seasons_franchises.csv"
        seasonsFranchiseInfo = getListOfTuplesFromCsv(csvFile)
        loadTable(seasonsFranchiseInfo, "insert_into_seasons_franchises.sql")
        connection.commit()

    elif choice == 8:
        csvFile = csvFolder + "season_stats_info.csv"
        seasonsStatsInfo = getListOfTuplesFromCsv(csvFile)
        loadTable(seasonsStatsInfo, "insert_into_stats_info.sql")
        connection.commit()

    elif choice == 999:
        sys.exit(1)
    else:
        print "Please run the program again"


if __name__ == "__main__":
    main()

