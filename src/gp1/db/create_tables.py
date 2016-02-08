from src.gp1.scrap.utils import *
from src.gp1.db.connection import getConnection

connection = getConnection() #This has to be used only once in the module

usefulConstants = constants()
sqlFolder = usefulConstants["SQL_FOLDER"]

def createTables(filename):
    createCommand = open(filename, "r").read()
    connection.execute(createCommand)


if __name__ == "__main__":
    createBasicProfileSql = sqlFolder + "create_basic_profile.sql"
    createTotalTableSql = sqlFolder + "create_totals_table.sql"
    createSalaryTableSql = sqlFolder + "create_salary_tables.sql"
    createTables(createBasicProfileSql)
    createTables(createTotalTableSql)
    createTables(createSalaryTableSql)
    connection.commit()
    connection.close()

