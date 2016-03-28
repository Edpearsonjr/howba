# Some of the thoughts that I have with repsect to clustering the players
# While the boss hires the players, it is not done randomly 
# It depends on 
# a. The position that the team is missing (Due to an earlier player missing as we see in MoneyBall)
# b. One of the players in the position is not performing well
# c. The need to improve certain areas of the gameplay and so on
# What we have to do is consider every position on the basket ball field different and perform analysis
# Different positions have different requirements. Some need a better 3 point average, some need better assists
# Performing analysis of salaries on the entire basketball players doesn't provide good insights
#---------------------------------------------------------------------------------------------------------------


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

# lets look at the SG- Shooting Guard position 
# Main objective is to score points 
# They need to have long range shots - 3P should be high 
# They may also assist well 
# SG-SF are known as wingman 
# Good free throw percentage too 
# SG-PG has value too 

# Some of the features to consider for Shooting Guard position conisdering the charactersitcs
# Percentage of games started(Indication of a good player)
# Mintutes played(Generally indicates a good player)
# 3P
# 3PA
# 2P
# 2PA
# FT
# FTA
# AST
# STL
# PTS 
# TOV
# If he played the dual role like SG-SF SG-PG SG-PF
# if he was the MVP of the season 
# the experience that he has (sometimes if he is too aged it might play a role in deciding whether to hire or no)
#---------------------------------------------------------------------------------------------------------------


#Trying for the 2012-2013 season only now 
sqlStatement  <- "SELECT * FROM SG_PREVIOUS5YEARS"
playerTotals <- dbGetQuery(basketballDb, sqlStatement)
shootingGuardsPrevious5years <- tbl_df(playerTotals)
shootingGuardsPrevious5years <- shootingGuardsPrevious5years %>%
                                select(-c(SEQ_NO)) %>%
                                group_by(PLAYER_ID) %>%
                                summarise(GAMES= mean(GAMES), GAMES_STARTED=mean(GAMES_STARTED),
                                          MINUTES_PLAYED = mean(MINUTES_PLAYED), FIELD_GOALS = mean(FIELD_GOALS),
                                          FIELD_GOALS_ATTEMPTS= mean(FIELD_GOALS_ATTEMPTS),
                                          THREE_POINTS_FG = mean(THREE_POINTS_FG),
                                          THREE_POINTS_FG_ATTEMPTS = mean(THREE_POINTS_FG_ATTEMPTS),
                                          TWO_POINTS_FG = mean(TWO_POINTS_FG),
                                          TWO_POINTS_FG_ATTEMPTS = mean(TWO_POINTS_FG_ATTEMPTS),
                                          EFF_FIELD_GOAL_PERCENT = mean(EFF_FIELD_GOAL_PERCENT),
                                          FREE_THROWS=mean(FREE_THROWS),
                                          FREE_THROWS_ATTEMPTS=mean(FREE_THROWS_ATTEMPTS),
                                          ASSISTS = mean(ASSISTS),
                                          TURNOVERS=mean(TURNOVERS),
                                          POINTS=mean(POINTS),
                                          SALARY=mean(SALARY),
                                          POSITION=paste(POSITION, collapse=",")) %>%
                                mutate(sg_sf= ifelse(grepl("SG-SF",POSITION, fixed=TRUE), 1 ,ifelse(grepl("SF", POSITION, fixed=TRUE), 1, 0))) %>%
                                mutate(sg_pf=ifelse(grepl("SG-PF",POSITION, fixed=TRUE), 1 ,ifelse(grepl("PF", POSITION, fixed=TRUE), 1, 0)))%>%
                                mutate(sg_pg=ifelse(grepl("SG-PG",POSITION, fixed=TRUE), 1 ,ifelse(grepl("PG", POSITION, fixed=TRUE), 1, 0)))%>%
                                mutate(sg_c=ifelse(grepl("SG-C",POSITION, fixed=TRUE), 1 ,ifelse(grepl("C", POSITION, fixed=TRUE), 1, 0))) %>%
                                select(-c(POSITION))
    

# select a few columns and prepare the data for cluster analysis 
# if the player has played shooting-guard and smallforward he is given a value of 1 in a separate column
# likewise do it for sg-pf, sg-pg
shootingGuards <- shootingGuardsPrevious5years %>% 
                    select(GAMES, GAMES_STARTED, MINUTES_PLAYED, FIELD_GOALS, FIELD_GOALS_ATTEMPTS, TWO_POINTS_FG, TWO_POINTS_FG_ATTEMPTS, 
                           THREE_POINTS_FG, THREE_POINTS_FG_ATTEMPTS, EFF_FIELD_GOAL_PERCENT, FREE_THROWS, FREE_THROWS_ATTEMPTS,
                           ASSISTS, TURNOVERS, POINTS, -c(sg_sf, sg_pf, sg_pg)) 
    


# in order to decide which variables to keep and which not to 
# here we perform co-relational analysis using the Hmisc library
correlation <- rcorr(as.matrix(shootingGuards))
correlationFlattened = flattenCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)
corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)
dev.off()



#some of the variables that were identified to remove are as follows 
# FG_Attempted 
# Field_Goals 
# 3PFGA
# FTA
# 2PFGA



features <- shootingGuardsPrevious5years %>%
    select(-c(PLAYER_ID,FIELD_GOALS, FIELD_GOALS_ATTEMPTS, THREE_POINTS_FG_ATTEMPTS, FREE_THROWS_ATTEMPTS, TWO_POINTS_FG_ATTEMPTS)) %>%
    mutate(
       GAMES = (GAMES - mean(GAMES))/sd(GAMES),
       GAMES_STARTED = (GAMES_STARTED - mean(GAMES_STARTED))/sd(GAMES_STARTED),
       MINUTES_PLAYED= (MINUTES_PLAYED - mean(MINUTES_PLAYED)) / sd(MINUTES_PLAYED),
       THREE_POINTS_FG = (THREE_POINTS_FG - mean(THREE_POINTS_FG)) / sd(THREE_POINTS_FG),
       FREE_THROWS = (FREE_THROWS - mean(FREE_THROWS)) / sd(FREE_THROWS),
       TWO_POINTS_FG = (TWO_POINTS_FG - mean(TWO_POINTS_FG)) / sd(TWO_POINTS_FG),
       ASSISTS = (ASSISTS - mean(ASSISTS)) / sd(ASSISTS),
       TURNOVERS = (TURNOVERS - mean(TURNOVERS)) / sd(TURNOVERS),
       POINTS = (POINTS - mean(POINTS)) / sd(POINTS)
        ) %>%
    select(-c(SALARY))





plotFrame <- getPlotFrame(features)
ggplot(plotFrame, aes(x=numClusters, y=sumOfSquares)) +
    geom_point() +
    geom_line()
print(plotFrame)
    


    # This is determined from the elbow graph 
    finalNumberOfClusters = 3
    membersOfClusters <- list() 
    km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
    
    kmeans <- kmeansruns(features, krange=2:10)
    bestNumberOfClusters <- kmeans$bestk
    
    
    comparison <- getComparisonBetweenKmeansppAndfpc(km, kmeans)
    print(comparison)
    
    #The conclusion here is using the two packages are same 
    # The difference is fpc gives the best number of clusters using the silhouette method 
    # We have calculated using the elbow method 
    # however we chose the elbow graph method because number of cluster being 3 achieved better 
    # between group sum of squares being large means better in terms of making a judgement 
    
    membersOfClusters <- getMembersOfClusters(features, finalNumberOfClusters, shootingGuardsPrevious5years)
    mean_matrix <- getMeanMatrix(membersOfClusters)
    
    #consider points variable - since shooting guard needs to score more and should have a better three point game
    topPointAttributes  <- getTopPlayersForAnAttribute(shootingGuardsPrevious5years, finalNumberOfClusters, "POINTS", membersOfClusters)
    topAssistAttributes <- getTopPlayersForAnAttribute(shootingGuardsPrevious5years, finalNumberOfClusters, "ASSISTS", membersOfClusters)
    topThreePointersAttributes <- getTopPlayersForAnAttribute(shootingGuardsPrevious5years,finalNumberOfClusters, "THREE_POINTS_FG", membersOfClusters)
    
    topPointsClusterPercentages <- topPointAttributes$percentages
    topAssistsClusterPerecentages <- topAssistAttributes$percentages
    topThreePointerClusterPercentages <- topThreePointersAttributes$percentages
    
    bestPlayersPercentagesInEachCluster <- data.frame(points = topPointsClusterPercentages, assists=topAssistsClusterPerecentages, threepointers=topThreePointerClusterPercentages)
    print(bestPlayersPercentagesInEachCluster)
    
    #This clearly justifies the high quality of the players in the clusters 
    # The best cluster has 100%  of the top 10% good shooters 
    # The best cluster has 77.77% if the top 10% good passers
    # The number of best three pointers are shared between two of them 
    
    
    # now look at the best cluster 
    # calcluate the mean and the stanadard deviation of the salaries in that cluster 
    # select someone who is a good shooter but is being paid less 
    # This will be a good pick for the boss 
    
    # player with id 2898 has top 10% skills in points scoring and is in top 10% in assists
    # he is paid around 3 million less than the mean of salaries in that cluster 
    bestCluster <- which.max(bestPlayersPercentagesInEachCluster$points)
    meanSalaryBestCluster <- mean(membersOfClusters[[bestCluster]]$SALARY)
    makeAnOffer <- tbl_df(membersOfClusters[[bestCluster]]) %>%
        filter(ASSISTS > topAssistAttributes$score, POINTS > topPointAttributes$score, SALARY < meanSalaryBestCluster)
    print(makeAnOffer)
    
    
    
    
    
    