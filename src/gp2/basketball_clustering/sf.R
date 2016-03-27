# small forwards are the most versatile 
# they need to be prolific scorers
# They have defense responsibilities offensive and defensive rebounds 
# They are fouled against more and they need to have good free throw skills 
# Their height should be between 6.6 to 6.9

library('RSQLite') # Loads the pacakges that is reqiured for reading from the sql database
library('dplyr') # perform operations on data frame 
library('Hmisc')
library('corrplot')
library('ggplot2')
library('cluster')
library('LICORS')
library('fpc')
source('utils.R')

basketballDb <- dbConnect(SQLite(), "/Users/abhinav/Abhinav/howba/app/src/gp1/db/basketBall.db")
sqlStatement  <- "SELECT * FROM SF_PREVIOUS5YEARS"
playerStats <- dbGetQuery(basketballDb, sqlStatement)
playerStats <- tbl_df(playerStats)

playerStats <- playerStats %>%
        select(-c(SEQ_NO)) %>%
        group_by(PLAYER_ID) %>%
        summarise(GAMES= mean(GAMES), 
                  GAMES_STARTED=mean(GAMES_STARTED),
                  MINUTES_PLAYED = mean(MINUTES_PLAYED), 
                  FIELD_GOALS = mean(FIELD_GOALS),
                  FIELD_GOALS_ATTEMPTS= mean(FIELD_GOALS_ATTEMPTS),
                  TWO_POINTS_FG = mean(TWO_POINTS_FG),
                  TWO_POINTS_FG_ATTEMPTS = mean(TWO_POINTS_FG_ATTEMPTS),
                  EFF_FIELD_GOAL_PERCENT = mean(EFF_FIELD_GOAL_PERCENT),
                  FREE_THROWS=mean(FREE_THROWS),
                  FREE_THROWS_ATTEMPTS=mean(FREE_THROWS_ATTEMPTS),
                  OFFENSIVE_REBOUNDS = mean(OFFESNIVE_REBOUNDS),
                  DEFENSIVE_REBOUNDS = mean(DEFENSIVE_REBOUNDS),
                  BLOCKS = mean(BLOCKS),
                  POINTS=mean(POINTS),
                  SALARY=mean(SALARY),
                  POSITION=paste(POSITION, collapse=",")) %>%
        mutate(sf_sg= ifelse(grepl("SF-SG",POSITION, fixed=TRUE), 1 ,ifelse(grepl("SG", POSITION, fixed=TRUE), 1, 0))) %>%
        mutate(sf_pf=ifelse(grepl("SF-PF",POSITION, fixed=TRUE), 1 ,ifelse(grepl("PF", POSITION, fixed=TRUE), 1, 0)))%>%
        mutate(sf_pg=ifelse(grepl("SF-PG",POSITION, fixed=TRUE), 1 ,ifelse(grepl("PG", POSITION, fixed=TRUE), 1, 0)))%>%
        mutate(sf_c=ifelse(grepl("SF-C",POSITION, fixed=TRUE), 1 ,ifelse(grepl("C", POSITION, fixed=TRUE), 1, 0))) %>%
        select(-c(POSITION))

sfAttributes <- playerStats %>%
    select(-(PLAYER_ID))



# among the attributes that are selected find the correlations between then 
correlation <- rcorr(as.matrix(sfAttributes))
correlationFlattened = flattenCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)
corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)

#from the correlation matrix we identify that the these variables be removed 
# FIELD_GOALS_ATTEMPTS
# TWO_POINTS_FG_ATTEMPTS
# TWO_POINTS_FG
# TWO_POINTS_FG_ATTEMPTS
# FREE_THROWS_ATTEMPTS
# FIELD_GOALS 

features <- sfAttributes %>%
    select(-c(FIELD_GOALS_ATTEMPTS, TWO_POINTS_FG_ATTEMPTS, TWO_POINTS_FG, TWO_POINTS_FG_ATTEMPTS, FREE_THROWS_ATTEMPTS,
              FIELD_GOALS, SALARY)) %>%
    mutate(GAMES = (GAMES - mean(GAMES))/sd(GAMES),
           GAMES_STARTED = (GAMES_STARTED - mean(GAMES_STARTED))/sd(GAMES_STARTED),
           MINUTES_PLAYED= (MINUTES_PLAYED - mean(MINUTES_PLAYED)) / sd(MINUTES_PLAYED),
           FREE_THROWS = (FREE_THROWS - mean(FREE_THROWS)) / sd(FREE_THROWS),
           OFFENSIVE_REBOUNDS = (OFFENSIVE_REBOUNDS -mean(OFFENSIVE_REBOUNDS)) / sd(OFFENSIVE_REBOUNDS),
           DEFENSIVE_REBOUNDS = (DEFENSIVE_REBOUNDS -mean(DEFENSIVE_REBOUNDS)) / sd(DEFENSIVE_REBOUNDS),
           BLOCKS = (BLOCKS -mean(BLOCKS)) / sd(BLOCKS),
           POINTS = (POINTS -mean(POINTS)) / sd(POINTS)
    ) 


plotFrame <- getPlotFrame(features)
ggplot(plotFrame, aes(x=numClusters, y=sumOfSquares)) +
    geom_point() +
    geom_line()

finalNumberOfClusters = 3

membersOfClusters <- list() 
km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
kmeans <- kmeansruns(features, krange=2:10)
bestNumberOfClusters <- kmeans$bestk

comparison <- getComparisonBetweenKmeansppAndfpc(km, kmeans)


membersOfClusters <- getMembersOfClusters(features, finalNumberOfClusters, playerStats)
mean_matrix <- getMeanMatrix(membersOfClusters)
topScorePlayersAttrbiutes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "POINTS", membersOfClusters)
topOffensiveReboundsAttributes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "OFFENSIVE_REBOUNDS", membersOfClusters)
topDefensiveReboundsAttributes <- getTopPlayersForAnAttribute(playerStats, finalNumberOfClusters, "DEFENSIVE_REBOUNDS", membersOfClusters)
bestPlayersPercentagesInEachCluster <- data.frame(points=topScorePlayersAttrbiutes$percentages, ofrb=topOffensiveReboundsAttributes$percentages, dfrb=topDefensiveReboundsAttributes$percentages)
print(bestPlayersPercentagesInEachCluster)
bestCluster <- which.max(bestPlayersPercentagesInEachCluster$dfrb)
meanSalaryBestCluster <- mean(membersOfClusters[[bestCluster]]$SALARY)
makeAnOffer <- tbl_df(membersOfClusters[[bestCluster]]) %>%
    filter(POINTS >topScorePlayersAttrbiutes$score,SALARY <= meanSalaryBestCluster)
print(makeAnOffer)










