#Q2_Linear Regression for Basketball Players Data

#libraries
library("RSQLite")
library('dplyr')
library("ggplot2")
library("sqldf")
library('ggplot2')
library('cluster')
library('MASS')
library("relaimpo")
library("stargazer")
library("reshape2")
library("car")

#making the connection
basketBallDb <- dbConnect(SQLite(), "G:/basketBall.db")
print("I have reached")
#lists the tables in the database
dbListTables(basketBallDb)

#query - To Train the model
result <- dbGetQuery(basketBallDb, "SELECT * FROM PLAYERINFO_ALL")

#names(result)
#normalize the columns
scaled.res <- as.data.frame(
  cbind(
    result[,c(1:4,21)], 
    scale(result[5:20]), 
    scale(result[c(22:42,50)]),
    result[,43:49],
    result[,51:56]
  )
)

#Attach the dataframe
attach(scaled.res)

SF_FLAG <- as.factor(SF_FLAG) 
PF_FLAG <- as.factor(PF_FLAG) 
SG_FLAG <- as.factor(SG_FLAG)
PG_FLAG <- as.factor(PG_FLAG)
CTR_FLAG <- as.factor(CTR_FLAG)
Front_pos <- as.factor(Front_pos) 
Back_pos <- as.factor(Back_pos)
POS <- as.factor(POS)

#Linear Regression - Using Both
step.bt <- step(lm( Adj_salary ~  MP+EFGP+FT+TOR+AST+BLK+PF+PTS+DRB+G+STL+ORB+EXP_In_Seasons,data=scaled.res), direction="both")
summary(step.bt)

cor(scaled.res$MP,scaled.res$Adj_salary)
?cor

#output nicely
stargazer(step.bt, title="Linear Regression Analysis Results",align=TRUE,out="G:/Q2_aicresults.html",object.names = TRUE, notes = "Salary~(predictor variables):StepAIC",column.labels = c("Using 'Both'- stepAIC call"),report = "vct*",single.row = TRUE)


#Build the test data
#query - To test the model
testData <- dbGetQuery(basketBallDb, "SELECT * FROM PLAYERINFO_ALL")
summary(testData)

#normalize the columns
scaled.testData <- as.data.frame(
  cbind(
    testData[,c(1:4,21)], 
    scale(testData[5:20]), 
    scale(testData[c(22:42,50)]),
    testData[,43:49],
    testData[,51:56]
  )
)

#Attach the dataframe
attach(scaled.testData)
summary(scaled.testData)

scaled.testData$SF_FLAG <- as.factor(scaled.testData$SF_FLAG) 
scaled.testData$PF_FLAG <- as.factor(scaled.testData$PF_FLAG) 
scaled.testData$SG_FLAG <- as.factor(scaled.testData$SG_FLAG)
scaled.testData$PG_FLAG <- as.factor(scaled.testData$PG_FLAG)
scaled.testData$CTR_FLAG <- as.factor(scaled.testData$CTR_FLAG)
scaled.testData$Front_pos <- as.factor(scaled.testData$Front_pos) 
scaled.testData$Back_pos <- as.factor(scaled.testData$Back_pos)
scaled.testData$POS <- as.factor(scaled.testData$POS)

scaled.testData.omitNa = na.omit(scaled.testData)

Xtest_t <-  cbind(scaled.testData.omitNa$MP, scaled.testData.omitNa$EFGP, scaled.testData.omitNa$FT, scaled.testData.omitNa$TOR,
                  scaled.testData.omitNa$AST, scaled.testData.omitNa$BLK, scaled.testData.omitNa$PF,scaled.testData.omitNa$PTS,
                  scaled.testData.omitNa$DRB, scaled.testData.omitNa$G, 
                  scaled.testData.omitNa$STL, scaled.testData.omitNa$ORB,
                  scaled.testData.omitNa$EXP_In_Seasons)

class(Xtest_t)
Xtest_t=as.data.frame(Xtest_t)
head(Xtest_t)
colnames(Xtest_t)=c('MP', 'EFGP', 'FT', 'TOR', 'AST', 'BLK', 'PF', 'PTS', 'DRB', 'G', 'STL', 'ORB','EXP_In_Seasons')
predObj1 <- predict(step.bt, Xtest_t)
str(scaled.testData.omitNa$Adj_salary)
str(predObj1)
SSE1 <- sum((scaled.testData.omitNa$Adj_salary - predObj1)^2)
SST1 <- sum((scaled.testData.omitNa$Adj_salary - mean(predObj1))^2)
X=Adj_salary-predObj1
str(predObj1)
str(scaled.testData.omitNa$Adj_salary)

R2 <- 1 - SSE1/SST1
R2

#Testing correlation
numericPredictorsWithSAL <- scaled.res[ ,c('MP', 'EFGP', 'FT', 'TOR', 'AST', 'BLK', 'PF', 'PTS', 'DRB', 'G', 'STL', 'ORB','EXP_In_Seasons')]

numericPredictorsWithSAL
corr_sal = sort(cor(numericPredictorsWithSAL)[,"Adj_salary"], T)

numericPredictors <- subset(numericPredictorsWithSAL, select = -c(Adj_salary))
install.packages("usdm")
require(usdm)
vif(numericPredictors[,])
vifcor(numericPredictors[,], th=0.95)

#Q.4(a)
confint(step.bt, level=0.95)
predict(step.bt,interval="prediction")
