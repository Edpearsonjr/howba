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
    createMVPTableSql = sqlFolder + "create_mvp_table.sql"
    createTeamMappingSql = sqlFolder + "create_team_mapping.sql"
    createBasicFranchiseInfoSql = sqlFolder + "create_basic_franchise_info.sql"
    createSeasonsFranchises = sqlFolder + "create_seasons_franchises.sql"
    createStatsInfo = sqlFolder + "create_stats_info.sql"

    createSqls = [createBasicProfileSql, createTotalTableSql, createSalaryTableSql, createMVPTableSql,
                  createTeamMappingSql, createBasicFranchiseInfoSql, createSeasonsFranchises,
                  createStatsInfo]

    for eachSql in createSqls:
        createTables(eachSql)

    connection.commit()
    connection.close()

