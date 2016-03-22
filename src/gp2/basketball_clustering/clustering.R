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
sqlStatement  <- "SELECT * FROM SG_PREVIOUS5YEARS_AVERAGE"
playerTotals <- dbGetQuery(basketballDb, sqlStatement)
shootingGuardsPrevious5years <- tbl_df(playerTotals)

# select a few columns and prepare the data for cluster analysis 
# if the player has played shooting-guard and smallforward he is given a value of 1 in a separate column
# likewise do it for sg-pf, sg-pg
shootingGuards <- shootingGuardsPrevious5years %>% 
                    select(GAMES, GAMES_STARTED, MINUTES_PLAYED, FIELD_GOALS, FIELD_GOALS_ATTEMPTS, TWO_POINTS_FG, TWO_POINTS_FG_ATTEMPTS, 
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
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)

corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)


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


withinGroupSumSquares <- numeric(0)
betweenGroupSumSquares <- numeric(0)
range <- 1:20
for(i in range){
    km <- kmeans(features, i, iter.max=100, nstart=10)
    sumSquares <- km$tot.withinss
    betweenSquares <- km$betweenss
    withinGroupSumSquares <- c(withinGroupSumSquares, sumSquares)
    betweenGroupSumSquares <- c(betweenGroupSumSquares, betweenSquares)
}


plotFrame <- data.frame(numClusters=range, sumOfSquares=withinGroupSumSquares, betweenGroupSumSquares=betweenGroupSumSquares)
ggplot(plotFrame, aes(x=numClusters, y=sumOfSquares)) +
    geom_point() +
    geom_line()
print(plotFrame)
    
# We chose the number of clusters for this position as 4 from the elbow method
# I chose 4 rather than 3 because the between sum squares seem to be more for 4 clusters rather than 3 and intercluster sum squares is less for 4
#but we have to work with random centres

    finalNumberOfClusters = 4
    membersOfClusters <- list() 
    km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
    clusters <- km$cluster
    for(i in 1:finalNumberOfClusters){
      members_i <- shootingGuardsPrevious5years[which(clusters == i),]
      membersOfClusters[[i]] <- members_i
    }
    averageScores <- numeric(0)
    averageSalaries <- numeric(0)
    for(i in 1:finalNumberOfClusters){
      averageScore <- sum((0.8) * membersOfClusters[[i]]$POINTS + 0.2 * membersOfClusters[[i]]$ASSISTS) / length(membersOfClusters[[i]])
      averageScores <- c(averageScores, averageScore)
    }
    for(i in 1: finalNumberOfClusters){
      averageSalary <- sum(membersOfClusters[[i]]$SALARY) / length(membersOfClusters[[i]])
      averageSalaries <- c(averageSalaries, averageSalary)
    }
   
  scoreSalariesFrame <- data.frame(scores= averageScores, salaries = averageSalaries)
  print(scoreSalariesFrame)
  clusplot(features, km$cluster, color=TRUE, shade=TRUE, labels=0, lines=0)
  dev.off()

 
        











