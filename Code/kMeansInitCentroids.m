function centroids = kMeansInitCentroids(X, K)
%KMEANSINITCENTROIDS This function initializes K centroids that are to be 
%used in K-Means on the dataset X

    randidx = randperm(size(X, 1)); 
    centroids = X(randidx(1:K), :);

end

