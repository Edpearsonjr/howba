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
# A few constants that you may need
################################################################################
DB_HOST = 'localhost'
DB_PORT = '3306'
DB_NAME = 'howba'





