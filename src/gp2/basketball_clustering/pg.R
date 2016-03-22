# This is for the point guard position in the NBA
# They are small tiny and fast enough
# They are valued more for their assits rather than the points
# What matters for the point guard is the assist-turnover ratio
# They should have a reasonable jump shot 

library('RSQLite')
library('dplyr')
library('Hmisc')
library('corrplot')
library('ggplot2')
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
sqlStatement  <- "SELECT * FROM PG_PREVIOUS5YEARS_AVERAGE"
playerStats <- dbGetQuery(basketballDb, sqlStatement)
playerStats <- tbl_df(playerStats)


# since assist to turnover ratio is obtained using division of two columns 
# handle the NAs here 
playerStats$ASSIST_TURNOVER_RATIO[is.na(playerStats$ASSIST_TURNOVER_RATIO)] <- 0

pgAttributes <- playerStats %>%
                select(-(PLAYER_ID))



# among the attributes that are selected find the correlations between then 
correlation <- rcorr(as.matrix(pgAttributes))
correlationFlattened = flattenCorrelationMatrix(correlation$r, correlation$P)
corGreaterThan99 <- filter(correlationFlattened, cor>0.95)
print(corGreaterThan99)
# corrplot(correlation$r, type="upper", order="hclust", tl.col="black", tl.srt=45)


# From the correlation matrix we find that 
# THREE_POINTS_FG and THREE_POINTS_FG_ATTEMPTS
# FREE_THROWS AND FREE_THROWS_ATTEMPTS 
# are correlated 


features <- pgAttributes %>%
            select(-c(THREE_POINTS_FG_ATTEMPTS, FREE_THROWS_ATTEMPTS, SALARY)) %>%
            mutate(GAMES = (GAMES - mean(GAMES))/sd(GAMES),
                   GAMES_STARTED = (GAMES_STARTED - mean(GAMES_STARTED))/sd(GAMES_STARTED),
                   MINUTES_PLAYED= (MINUTES_PLAYED - mean(MINUTES_PLAYED)) / sd(MINUTES_PLAYED),
                   THREE_POINTS_FG = (THREE_POINTS_FG - mean(THREE_POINTS_FG)) / sd(THREE_POINTS_FG),
                   FREE_THROWS = (FREE_THROWS - mean(FREE_THROWS)) / sd(FREE_THROWS),
                   ASSIST_TURNOVER_RATIO = (ASSIST_TURNOVER_RATIO - mean(ASSIST_TURNOVER_RATIO)) / sd(ASSIST_TURNOVER_RATIO)
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
    averageScore <- sum( (0.7* membersOfClusters[[i]]$ASSIST_TURNOVER_RATIO) + (0.3 * membersOfClusters[[i]]$EFF_FIELD_GOAL_PERCENT))/ length(membersOfClusters[[i]])
    averageScores <- c(averageScores, averageScore)
}
for(i in 1: finalNumberOfClusters){
    averageSalary <- sum(membersOfClusters[[i]]$SALARY) / length(membersOfClusters[[i]])
    averageSalaries <- c(averageSalaries, averageSalary)
}

scoreSalariesFrame <- data.frame(scores= averageScores, salaries = averageSalaries)
print(scoreSalariesFrame)



