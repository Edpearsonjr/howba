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
library('fpc')
source("utils.R")


basketballDb <- dbConnect(SQLite(), "/Users/abhinav/Abhinav/howba/app/src/gp1/db/basketBall.db")
sqlStatement  <- "SELECT * FROM PG_PREVIOUS5YEARS"
playerStats <- dbGetQuery(basketballDb, sqlStatement)
playerStats <- tbl_df(playerStats)


playerStats <- playerStats %>%
                select(-c(SEQ_NO)) %>%
                group_by(PLAYER_ID) %>%
                summarise(GAMES= mean(GAMES), 
                          GAMES_STARTED=mean(GAMES_STARTED),
                          MINUTES_PLAYED = mean(MINUTES_PLAYED), 
                          THREE_POINTS_FG = mean(THREE_POINTS_FG),
                          THREE_POINTS_FG_ATTEMPTS = mean(THREE_POINTS_FG_ATTEMPTS),
                          EFF_FIELD_GOAL_PERCENT = mean(EFF_FIELD_GOAL_PERCENT),
                          FREE_THROWS=mean(FREE_THROWS),
                          FREE_THROWS_ATTEMPTS=mean(FREE_THROWS_ATTEMPTS),
                          ASSIST_TURNOVER_RATIO= mean(ASSISTS/TURNOVERS, na.rm=TRUE),
                          SALARY=mean(SALARY),
                          POSITION=paste(POSITION, collapse=",")) %>%
                mutate(pg_sf= ifelse(grepl("PG-SF",POSITION, fixed=TRUE), 1 ,0)) %>%
                mutate(pg_pf=ifelse(grepl("PG-PF",POSITION, fixed=TRUE), 1 ,0))%>%
                mutate(pg_sg=ifelse(grepl("PG-SG",POSITION, fixed=TRUE), 1 ,0))%>%
                mutate(pg_c=ifelse(grepl("PG-C",POSITION, fixed=TRUE), 1 ,0)) %>%
                select(-c(POSITION))
    
playerStats$ASSIST_TURNOVER_RATIO[is.na(playerStats$ASSIST_TURNOVER_RATIO)] <- 0
playerStats$ASSIST_TURNOVER_RATIO[is.infinite(playerStats$ASSIST_TURNOVER_RATIO)] <- 0


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

topAssistsTurnOverRatioAttrbiutes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "ASSIST_TURNOVER_RATIO", membersOfClusters)
topThreePointersAttributes <- getTopPlayersForAnAttribute(playerStats,finalNumberOfClusters, "THREE_POINTS_FG", membersOfClusters)
bestPlayersPercentagesInEachCluster <- data.frame(assistsTurnOverRatio=topAssistsTurnOverRatioAttrbiutes$percentages, scores=topThreePointersAttributes$percentages)
bestCluster <- which.max(bestPlayersPercentagesInEachCluster$assistsTurnOverRatio)
meanSalaryBestCluster <- membersOfClusters[[bestCluster]]
makeAnOffer <- tbl_df(membersOfClusters[[bestCluster]]) %>%
    filter(ASSIST_TURNOVER_RATIO > topAssistsTurnOverRatioAttrbiutes$score)
print(makeAnOffer)
#player id 568










