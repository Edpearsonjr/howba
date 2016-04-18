################################################################################
# Preamble - Load all the libraries here 
#library('libraryName') # The purpose of the library 
################################################################################

library('data.table')               # For handling large files 
library('dplyr')                    # Operations on frames 
library('RMySQL')                   # For connecting with the mysql package

################################################################################
# Clearing the environment variables 
################################################################################
rm(list=ls())


################################################################################
# A few constants that are needed
################################################################################
DB_HOST = 'localhost'
DB_PORT = '3306'
DB_USER = 'root'
DB_PASSWORD = '#Ab1992#'
DB_NAME = 'howba'

################################################################################
# Connecting to the database
################################################################################
print("Connecting to the database")
connection <- dbConnect(RMySQL::MySQL(), user=DB_USER, password=DB_PASSWORD, host=DB_HOST, dbname=DB_NAME)
