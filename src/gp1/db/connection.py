import sqlite3
from src.gp1.scrap.utils import *

usefulConstants = constants()
dbFile = usefulConstants["DB_FILE"]

def getConnection():
    connection = sqlite3.connect(dbFile)
    if connection:
        print "The connection is successful"
        return connection

def commit(connection):
    connection.commit()

def close(connection):
    connection.close()

def cursor(connection):
    return connection.cursor()
