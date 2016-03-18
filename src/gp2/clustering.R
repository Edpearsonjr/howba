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

basketballDb <- dbConnect(SQLite(), "~/Abhinav/howba/app/src/gp1/db/basketBall.db")

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
sqlStatement  <- "SELECT * FROM SHOOTING_GUARDS_2012_2013"
playerTotals <- dbGetQuery(basketballDb, sqlStatement)
shootingGuards2012 <- tbl_df(playerTotals)

# select a few columns and prepare the data for cluster analysis 
# if the player has played shooting-guard and smallforward he is given a value of 1 in a separate column
# likewise do it for sg-pf, sg-pg
shootingGuards <- shootingGuards2012 %>% 
                    select(AGE, GAMES, GAMES_STARTED, MINUTES_PLAYED, FIELD_GOALS, FIELD_GOALS_ATTEMPTS, TWO_POINTS_FG, TWO_POINTS_FG_ATTEMPTS, 
                           THREE_POINTS_FG, THREE_POINTS_FG_ATTEMPTS, EFF_FIELD_GOAL_PERCENT, FREE_THROWS, FREE_THROWS_ATTEMPTS,
                           ASSISTS, TURNOVERS, POINTS)
    

# in order to decide which variables to keep and which not to 
# here we perform co-relational analysis using the Hmisc library
flatternCorrelationMatrix <- function(cormat, pmat) {
    ut <- upper.tri(cormat)
    data.frame(
        row = rownames(cormat)[row(cormat)[ut]],
        col = rownames(cormat)[col(cormat)[ut]],
        cor = (cormat)[ut],
        p = pmat[ut]
    )
}

correlation <- rcorr(as.matrix(shootingGuards))
correlationFlattened = flatternCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95 | cor < -0.95)
print(corGreaterThan99)

# corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)


#some of the variables that were identified to remove are as follows 
# FG_Attempted 
# Field_Goals 
# 3PFGA
# FTA
# 2PFGA



features <- shootingGuards2012 %>%
    select(-c(PLAYER_ID, SEASON_ID,FIELD_GOALS, TEAM, FIELD_GOALS_ATTEMPTS, THREE_POINTS_FG_ATTEMPTS, FREE_THROWS_ATTEMPTS, TWO_POINTS_FG_ATTEMPTS)) %>%
    mutate(
       AGE = (AGE - mean(AGE))/ sd(AGE),
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
    select(-c(POSITION, SALARY)) %>%
    print


withinGroupSumSquares <- numeric(0)
range <- 1:20
for(i in range){
    km <- kmeans(features, i, iter.max=100, nstart=10)
    sumSquares <- km$tot.withinss
    withinGroupSumSquares <- c(withinGroupSumSquares, sumSquares)
}

plotFrame <- data.frame(numClusters=range, sumOfSquares=withinGroupSumSquares)
print(plotFrame)
ggplot(plotFrame, aes(x=numClusters, y=sumOfSquares)) +
    geom_point() +
    geom_line()
 
    
# We chose the number of clusters for this position as 3 from the elbow method
#but we have to work with random centres

    km <- kmeans(features, 3, iter.max = 1000, nstart = 10)
    clusters <- km$cluster
    membersFirstCluster <- shootingGuards2012[which(clusters==1),]
    membersSecondCluster <- shootingGuards2012[which(clusters==2),]
    membersThirdCluster <- shootingGuards2012[which(clusters == 3),]
    
    # Analysis of the clusters is done here for the position SG 
    #since the sg position is supposed to score well and assist well we consider this for cluster analysis
    # we say that the player is good if he has a good weighted combination of this 
    # we will give the average score to a cluster 
    averageScoreFirstCluster <- sum((0.8) * membersFirstCluster$POINTS + 0.2 * membersFirstCluster$ASSISTS) / length(membersFirstCluster)
    averageScoreSecondCluster <- sum((0.8) * membersSecondCluster$POINTS + 0.2 * membersSecondCluster$ASSISTS) / length(membersSecondCluster)
    averageScoreThirdCluster <- sum((0.8) * membersThirdCluster$POINTS + 0.2 * membersThirdCluster$ASSISTS) / length(membersThirdCluster)
    
    # The clusters thus give an idea of the skills of the players 
    # The first second and third cluster give mediocre, exceptional and bad players 
    
    #lets check the average salaries now 
    averageFirstClusterSalaries <- sum(membersFirstCluster$SALARY) / length(membersFirstCluster)
    averageSecondClusterSalaries <- sum(membersSecondCluster$SALARY) / length(membersSecondCluster)
    averageThirdClusterSalaries <- sum(membersThirdCluster$SALARY) / length(membersThirdCluster)
    print(averageFirstClusterSalaries)
    print(averageSecondClusterSalaries)
    print(averageThirdClusterSalaries)
    
    
    
    
    
    
    



# clusplot(features, km$cluster, color=TRUE, shade=TRUE, labels=0, lines=0)
# dev.off()


    










