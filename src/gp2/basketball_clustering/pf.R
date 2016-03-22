# power forwards should have these attributes typically 
# they should have 2point capabilities 
# they should be defensive - good rebounds offensively and defensively 
# they should have good blocks 

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

flattenCorrelationMatrix <- function(cormat, pmat) {
    ut <- upper.tri(cormat)
    data.frame(
        row = rownames(cormat)[row(cormat)[ut]],
        col = rownames(cormat)[col(cormat)[ut]],
        cor = (cormat)[ut],
        p = pmat[ut]
    )
}
basketballDb <- dbConnect(SQLite(), "/Users/abhinav/Abhinav/howba/app/src/gp1/db/basketBall.db")
sqlStatement  <- "SELECT * FROM PF_PREVIOUS5YEARS_AVERAGE"
playerStats <- dbGetQuery(basketballDb, sqlStatement)
playerStats <- tbl_df(playerStats)

pfAttributes <- playerStats %>%
    select(-(PLAYER_ID))



# among the attributes that are selected find the correlations between then 
correlation <- rcorr(as.matrix(pfAttributes))
correlationFlattened = flattenCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)
corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)

#from the correlation matrix we identify that the these variables be removed 
# TWO_POINTS_FG_ATTEMPTS
# TWO_POINTS_FG


features <- pfAttributes %>%
    select(-c(TWO_POINTS_FG_ATTEMPTS, TWO_POINTS_FG, SALARY)) %>%
    mutate(GAMES = (GAMES - mean(GAMES))/sd(GAMES),
           GAMES_STARTED = (GAMES_STARTED - mean(GAMES_STARTED))/sd(GAMES_STARTED),
           MINUTES_PLAYED= (MINUTES_PLAYED - mean(MINUTES_PLAYED)) / sd(MINUTES_PLAYED),
           THREE_POINTS_FG = (THREE_POINTS_FG - mean(THREE_POINTS_FG)) / sd(THREE_POINTS_FG),
           FREE_THROWS = (FREE_THROWS - mean(FREE_THROWS)) / sd(FREE_THROWS),
           OFFENSIVE_REBOUNDS = (OFFENSIVE_REBOUNDS -mean(OFFENSIVE_REBOUNDS)) / sd(OFFENSIVE_REBOUNDS),
           DEFENSIVE_REBOUNDS = (DEFENSIVE_REBOUNDS -mean(DEFENSIVE_REBOUNDS)) / sd(DEFENSIVE_REBOUNDS),
           BLOCKS = (BLOCKS -mean(BLOCKS)) / sd(BLOCKS),
           POINTS = (POINTS -mean(POINTS)) / sd(POINTS)
    ) 

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

finalNumberOfClusters = 3
membersOfClusters <- list() 
km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
clusters <- km$cluster
for(i in 1:finalNumberOfClusters){
    members_i <- playerStats[which(clusters == i),]
    membersOfClusters[[i]] <- members_i
}
print(membersOfClusters[[1]])
averageScores <- numeric(0)
averageSalaries <- numeric(0)
for(i in 1:finalNumberOfClusters){
    averageScore <- sum((0.2* membersOfClusters[[i]]$DEFENSIVE_REBOUNDS) + (0.2 * membersOfClusters[[i]]$OFFENSIVE_REBOUNDS + (0.3* membersOfClusters[[i]]$TWO_POINTS_FG) + (0.3 * membersOfClusters[[i]]$BLOCKS)))/ length(membersOfClusters[[i]])
    averageScores <- c(averageScores, averageScore)
}
for(i in 1: finalNumberOfClusters){
    averageSalary <- sum(membersOfClusters[[i]]$SALARY) / length(membersOfClusters[[i]])
    averageSalaries <- c(averageSalaries, averageSalary)
}

scoreSalariesFrame <- data.frame(scores= averageScores, salaries = averageSalaries)
print(scoreSalariesFrame)



