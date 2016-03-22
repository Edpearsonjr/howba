# We would like to store the Most Valuable Award player information in the website
# These are the information that we would like to crawl from the website
# Season
# Player Name
# We cant get other information of the player from the other tables in the db
import urllib2
from src.gp1.scrap.utils import *
from bs4 import BeautifulSoup

usefulConstants = constants()
MVP_URL = usefulConstants["MVP_URL"]

def getMVPStats():
    urlHandle = urllib2.urlopen(MVP_URL)
    html = urlHandle.read()
    soup = BeautifulSoup(html, "lxml")
    stwDiv = soup.findAll('div', {'class': 'stw'})[0]
    stats = scrapPlayerStatisticsTable(stwDiv)
    return map(lambda x: (x[0], x[2]), stats)

if __name__ == "__main__":
    stats = getMVPStats()
    print stats
