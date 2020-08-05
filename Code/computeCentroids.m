function centroids = computeCentroids(X, idx, K)
%COMPUTECENTROIDS returns the new centroids by computing the means of the 
%data points assigned to each centroid.

n = size(X,2);

centroids = zeros(K, n);

    for j = 1:K
        pk = find(idx==j);
        centroids(j,:) = (1/length(pk)) * sum(X(pk,:),1);
    end

end

