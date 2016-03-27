# power forwards should have these attributes typically 
# they should have 2point capabilities 
# they should be defensive - good rebounds offensively and defensively 
# they should have good blocks 


library('RSQLite') # Loads the pacakges that is reqiured for reading from the sql database
library('dplyr') # perform operations on data frame 
library('Hmisc')
library('corrplot')
library('ggplot2')
library('cluster')
library('LICORS')
library('fpc')
source('utils.R')

sketballDb <- dbConnect(SQLite(), "/Users/abhinav/Abhinav/howba/app/src/gp1/db/basketBall.db")
sqlStatement  <- "SELECT * FROM PF_PREVIOUS5YEARS"
playerStats <- dbGetQuery(basketballDb, sqlStatement)
playerStats <- tbl_df(playerStats)
playerStats <- playerStats %>%
                group_by(PLAYER_ID) %>%
                summarise(GAMES= mean(GAMES), 
                          GAMES_STARTED=mean(GAMES_STARTED),
                          MINUTES_PLAYED = mean(MINUTES_PLAYED), 
                          TWO_POINTS_FG = mean(TWO_POINTS_FG),
                          TWO_POINTS_FG_ATTEMPTS= mean(TWO_POINTS_FG_ATTEMPTS),
                          EFF_FIELD_GOAL_PERCENT = mean(EFF_FIELD_GOAL_PERCENT),
                          OFFENSIVE_REBOUNDS = mean(OFFESNIVE_REBOUNDS),
                          DEFENSIVE_REBOUNDS = mean(DEFENSIVE_REBOUNDS),
                          BLOCKS = mean(BLOCKS),
                          POINTS=mean(POINTS),
                          SALARY=mean(SALARY),
                          POSITION=paste(POSITION, collapse=",")) %>%
                mutate(pf_sg= ifelse(grepl("PF-SG",POSITION, fixed=TRUE), 1 ,ifelse(grepl("SG", POSITION, fixed=TRUE), 1, 0))) %>%
                mutate(pf_sf=ifelse(grepl("PF-SF",POSITION, fixed=TRUE), 1 ,ifelse(grepl("SF", POSITION, fixed=TRUE), 1, 0)))%>%
                mutate(pf_pg=ifelse(grepl("PF-PG",POSITION, fixed=TRUE), 1 ,ifelse(grepl("PG", POSITION, fixed=TRUE), 1, 0)))%>%
                mutate(pf_c=ifelse(grepl("PF-C",POSITION, fixed=TRUE), 1 ,ifelse(grepl("C", POSITION, fixed=TRUE), 1, 0))) %>%
                select(-c(POSITION))

pfAttributes <- playerStats %>%
    select(-(PLAYER_ID))



# among the attributes that are selected find the correlations between then 
correlation <- rcorr(as.matrix(pfAttributes))
correlationFlattened = flattenCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)


#from the correlation matrix we identify that the these variables be removed 
# TWO_POINTS_FG_ATTEMPTS
# TWO_POINTS_FG


features <- pfAttributes %>%
    select(-c(TWO_POINTS_FG_ATTEMPTS, TWO_POINTS_FG, SALARY)) %>%
    mutate(GAMES = (GAMES - mean(GAMES))/sd(GAMES),
           GAMES_STARTED = (GAMES_STARTED - mean(GAMES_STARTED))/sd(GAMES_STARTED),
           MINUTES_PLAYED= (MINUTES_PLAYED - mean(MINUTES_PLAYED)) / sd(MINUTES_PLAYED),
           OFFENSIVE_REBOUNDS = (OFFENSIVE_REBOUNDS -mean(OFFENSIVE_REBOUNDS)) / sd(OFFENSIVE_REBOUNDS),
           DEFENSIVE_REBOUNDS = (DEFENSIVE_REBOUNDS -mean(DEFENSIVE_REBOUNDS)) / sd(DEFENSIVE_REBOUNDS),
           BLOCKS = (BLOCKS -mean(BLOCKS)) / sd(BLOCKS),
           POINTS = (POINTS -mean(POINTS)) / sd(POINTS)
    ) 

plotFrame <- getPlotFrame(features)
ggplot(plotFrame, aes(x=numClusters, y=sumOfSquares)) +
    geom_point() +
    geom_line()

print(plotFrame)

finalNumberOfClusters = 3


km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
kmeans <- kmeansruns(features, krange=2:10)
bestNumberOfClusters <- kmeans$bestk

comparison <- getComparisonBetweenKmeansppAndfpc(km, kmeans)


membersOfClusters <- getMembersOfClusters(features, finalNumberOfClusters, playerStats)
mean_matrix <- getMeanMatrix(membersOfClusters)

topTwoPointScorerAttrbiutes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "TWO_POINTS_FG", membersOfClusters)
topOffensiveReboundsAttributes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "OFFENSIVE_REBOUNDS", membersOfClusters)
topDefensiveReboundsAttributes <- getTopPlayersForAnAttribute(playerStats, finalNumberOfClusters, "DEFENSIVE_REBOUNDS", membersOfClusters)

bestPlayersPercentagesInEachCluster = data.frame(twoPointers= topTwoPointScorerAttrbiutes$percentages, ofrb=topOffensiveReboundsAttributes$percentages,
                                                 dfrb=topDefensiveReboundsAttributes$percentages)

print(bestPlayersPercentagesInEachCluster)
bestCluster <- which.max(bestPlayersPercentagesInEachCluster$dfrb)
meanSalaryBestCluster <- mean(membersOfClusters[[bestCluster]]$SALARY)
makeAnOffer <- tbl_df(membersOfClusters[[bestCluster]]) %>%
    filter(DEFENSIVE_REBOUNDS > topDefensiveReboundsAttributes$score, 
           OFFENSIVE_REBOUNDS >  topOffensiveReboundsAttributes$score, 
           TWO_POINTS_FG > topTwoPointScorerAttrbiutes$score,
           SALARY <= meanSalaryBestCluster)

print(makeAnOffer)










