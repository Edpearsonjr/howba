# Q3. Panel data. What predicts the players' salaries in the past 10 years?

#Load the libraries
library("Matrix")
library("plm")
library(gplots)
library(stargazer)
#setwd("C:/Users/vidyasagar/Desktop/NUS Coursework/Sem2/HowBA/Projects/Guided Project2/VISA/Datasets")

##For time invariant factors###
dataForQ3 <- read.csv("Q3_finaldata_season_player_gran.csv",header=TRUE)
summary(dataForQ3)

nrow(dataForQ3)
dataForQ3_filtered = na.omit(dataForQ3)
nrow(dataForQ3_filtered)
ncol(dataForQ3_filtered)
names(dataForQ3_filtered)

#[1] "PLAYER_ID"      "SEASON_ID"      "POS"            "TEAM_ID"        "G"             
#[6] "FT"             "FTA"            "FG_3"           "FGA_3"          "FG_2"          
#[11] "FGA_2"          "ORB"            "DRB"            "TRB"            "AST"           
#[16] "STL"            "PTS"            "MP"             "FG"             "FGA"           
#[21] "EFGP"           "BLK"            "TOR"            "PF"             "FT_PG"         
#[26] "FTA_PG"         "FG_3_PG"        "FGA_3_PG"       "FG_2_PG"        "FGA_2_PG"      
#[31] "ORB_PG"         "DRB_PG"         "TRB_PG"         "AST_PG"         "STL_PG"        
#[36] "PTS_PG"         "MP_PG"          "FG_PG"          "FGA_PG"         "BLK_PG"        
#[41] "TOR_PG"         "PF_PG"          "EXP_In_Seasons" "SF_FLAG"        "PF_FLAG"       
#[46] "SG_FLAG"        "PG_FLAG"        "CTR_FLAG"       "Tot_POS"        "Tot_Games"     
#[51] "Adj_salary"     "FTPerc"         "FG_3_Perc"      "FG_2_Perc"      "Front_pos"     
#[56] "Back_pos"       "HEIGHT"         "WEIGHT"         "COLLEGE"       

attach(dataForQ3_filtered)
numericPredictorsWithSAL <- dataForQ3_filtered[,-c(1:4,46:50,59)]
corr_sal = sort(cor(numericPredictorsWithSAL)[,"Adj_salary"], T)
stargazer(corr_sal, title="Correlation Matrix", out="D:/correlationswithSalary.html")

numericPredictors <- subset(numericPredictorsWithSAL, select = -c(Adj_salary))

require(usdm)
viftable = vif(numericPredictors[,])
vifcor(numericPredictors[,], th=0.75)


#Variables to be used in the model are
# 
XVIF <- cbind(G, FTA, EFGP, FGA_3_PG, ORB_PG, AST_PG, STL_PG, BLK_PG, PF_PG, EXP_In_Seasons,
              SF_FLAG, PF_FLAG, FTPerc, FG_3_Perc, FG_2_Perc, Back_pos, HEIGHT, WEIGHT)

Y <- cbind(Adj_salary)
XTimeInvariant <- cbind(HEIGHT, WEIGHT, as.factor(COLLEGE), as.factor(POS), Tot_POS, EXP_In_Seasons)

paneldata <- plm.data(dataForQ3_filtered, index=c("PLAYER_ID","SEASON_ID"))

fixedestimator <- plm(Y ~ XTimeInvariant, data=paneldata, model= "within")
summary(fixedestimator)
stargazer(fixedestimator, title="Fixed Estimator for Time Invariant Variables",
          align=TRUE,out="D:/Fixedmodel_TimeInvariant.html",object.names = TRUE, 
          notes = "Salary~(predictor variables):Time Invariant ones",report = "vct*",single.row = TRUE)

randomestimator <- plm(Y ~ XTimeInvariant, data=paneldata, model= "random")
summary(randomestimator)
stargazer(randomestimator, title="Random Estimator for Time Invariant Variables",
          align=TRUE,out="D:/Randommodel1_TimeInvariant.html",object.names = TRUE, 
          notes = "Salary~(predictor variables):Time Invariant ones",report = "vct*",single.row = TRUE)
phtest(randomestimator, fixedestimator)


#output nicely
install.packages("stargazer")
library(stargazer)

fixedestimator <- plm(Y ~ XVIF, data=paneldata, model= "within")
summary(fixedestimator)
stargazer(fixedestimator, title="Fixed Estimator for both time variant and time invariant variables",
          align=TRUE,out="D:/Fixedmodel_ForAll.html",object.names = TRUE, 
          notes = "Salary~(predictor variables):18 variables after removing ones due to multicollinearity",report = "vct*",single.row = TRUE)

# Random effects estimator
randomestimator <- plm(Y ~ XVIF, data=paneldata, model= "random")
summary(randomestimator)
stargazer(randomestimator, title="Random Estimator for both time variant and time invariant variables",
          align=TRUE,out="D:/Randommodel_ForAll.html",object.names = TRUE, 
          notes = "Salary~(predictor variables):18 variables after removing ones due to multicollinearity",report = "vct*",single.row = TRUE)

phtest(randomestimator, fixedestimator)

plotmeans(Y ~ SEASON_ID, main="Heterogeneity across Seasons", data=dataForQ3_filtered)
plotmeans(Y ~ EXP_In_Seasons, main="Heterogeneity based on experience", data=dataForQ3_filtered)
plotmeans(Y ~ Tot_POS, main="Heterogeneity based on no. of positions", data=dataForQ3_filtered)
plotmeans(Y ~ as.factor(Front_pos), main="Heterogeneity based on whether a player can play in the front court", data=dataForQ3_filtered)
plotmeans(Y ~ PF_FLAG, main="Heterogeneity based on PF vs rest", data=dataForQ3_filtered)
plotmeans(Y ~ SF_FLAG, main="Heterogeneity based on SF vs rest", data=dataForQ3_filtered)
plotmeans(Y ~ PG_FLAG, main="Heterogeneity based on PG vs rest", data=dataForQ3_filtered)
