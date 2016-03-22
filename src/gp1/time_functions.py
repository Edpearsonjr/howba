# This is used to time various functions using python module
import timeit
import matplotlib.pyplot as plt
from src.gp1.scrap.utils import generalWrapper
from src.gp1.scrap.utils import constants
from src.gp1.scrap.crawl_players import getPlayerUsingBs4
from src.gp1.scrap.crawl_players import getPlayerUsingRegEx

usefulConstants = constants()
dataDir = usefulConstants["DATA_DIR"]
playerListsFolder = dataDir + "player_lists_html/"

def timeScrappingUsingBs4(times = 10):
    wrapped = generalWrapper(getPlayerUsingBs4, playerListsFolder)
    time = timeit.timeit(wrapped, number= times)
    return time

def timeScrappingUsingRegex(times = 10):
    wrapped = generalWrapper(getPlayerUsingRegEx, playerListsFolder)
    time = timeit.timeit(wrapped, number = times)
    return time



if __name__ == "__main__":
    times = range(1, 21)
    regExTimes = []
    bs4Times = []

    for time in times:
        timeUsingbs4 = timeScrappingUsingBs4(times = time)
        timeUsingRegex = timeScrappingUsingRegex(times  = time)
        bs4Times.append(timeUsingbs4)
        regExTimes.append(timeUsingRegex)

    print "plotting the times"
    bs4Plot = plt.plot(times, bs4Times, 'g^')
    regexPlot = plt.plot(times, regExTimes, 'bs')

    plt.xlabel("Number of repetitions")
    plt.ylabel('time in seconds')
    plt.savefig("runningTime1.jpg")
    print "finished plotting the times"
