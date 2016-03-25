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

getPlotFrame <- function(features, range=1:20){
    withinGroupSumSquares <- numeric(0)
    betweenGroupSumSquares <- numeric(0)
    for(i in range){
        km <- kmeans(features, i, iter.max=100, nstart=10)
        sumSquares <- km$tot.withinss
        betweenSquares <- km$betweenss
        withinGroupSumSquares <- c(withinGroupSumSquares, sumSquares)
        betweenGroupSumSquares <- c(betweenGroupSumSquares, betweenSquares)
    }
    plotFrame <- data.frame(numClusters=range, sumOfSquares=withinGroupSumSquares, betweenGroupSumSquares=betweenGroupSumSquares)
    plotFrame 
}

getMembersOfClusters <- function(features, finalNumberOfClusters, dataFrame){
    membersOfClusters <- list() 
    km <- kmeanspp(features, k=finalNumberOfClusters, start="random", iter.max = 100, nstart = 45)
    clusters <- km$cluster
    for(i in 1:finalNumberOfClusters){
        members_i <- dataFrame[which(clusters == i),]
        membersOfClusters[[i]] <- members_i
    }
    membersOfClusters;
}

getComparisonBetweenKmeansppAndfpc <- function(km ,kmfpc){
    withinGroupSumSquares <- km$tot.withinss
    betweenGroupSumSquares <- km$betweenss
    withinGroupSumSquaresFpc <- kmfpc$tot.withinss
    betweenGroupSumSquaresFpc <- kmfpc$betweenss
    comparison <- data.frame(withinSumOfSquares = c(withinGroupSumSquares, withinGroupSumSquaresFpc), 
                             betweenGroupSumSquares = c(betweenGroupSumSquares, betweenGroupSumSquaresFpc))
    comparison;
}

getMeanMatrix <- function(membersOfClusters){
    ncols <- ncol(membersOfClusters[[1]])
    mean_matrix <- matrix(nrow=finalNumberOfClusters, ncol=ncols)
    dimension_names <- dimnames(membersOfClusters[[1]])
    for(i in 1:finalNumberOfClusters){
        mean_matrix[i, ] <- sapply(membersOfClusters[[i]], mean)
    }
    colnames(mean_matrix) <- dimension_names[[2]]
    mean_matrix <- mean_matrix[,2:ncols]
    mean_matrix;
    
}

getTopPlayersForAnAttribute <- function(dataFrame,finalNumberOfClusters, feature, membersOfClusters, percentile=0.9){
    
    
    mean_attribute <- mean(dataFrame[[feature]])
    sd_attribute <- sd(dataFrame[[feature]])
    score_90Percentile <- qnorm(percentile, mean=mean_attribute, sd=sd_attribute)
    totalAbove90Percentile <- sum(dataFrame[[feature]] >= score_90Percentile)
    above90Percentile <- double(0)
    for(i in 1:finalNumberOfClusters){
        numberOfPlayersIn90Percentile <- sum(membersOfClusters[[i]][[feature]] >= score_90Percentile) 
        percentage = numberOfPlayersIn90Percentile / totalAbove90Percentile
        
        above90Percentile <- c(above90Percentile, (numberOfPlayersIn90Percentile/ totalAbove90Percentile)* 100)
    }
    
    list(percentages=above90Percentile, score=score_90Percentile); 
    
}


