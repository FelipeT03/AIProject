function idx = findClosestCentroids(X, centroids)
%FINDCLOSESTCENTROIDS computes the centroid memberships for every example
K = size(centroids, 1);

idx = zeros(size(X,1), 1);

    idx = idx + 1;
    for l = 1:size(X,1)
        for j = 2:K
            if sum((X(l, :) - centroids(j,:)) .^ 2,2) < sum((X(l, :) - centroids(idx(l),:)) .^ 2,2)
                idx(l) = j;
            end
        end
    end


end

