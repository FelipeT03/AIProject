function idx = findClosestCentroids(X, centroids)
%FINDCLOSESTCENTROIDS computes the centroid memberships for every example
%ultima modificacion 05/08/2020 FT
    K = size(centroids, 1);
    m = size(X,1);
    error_c = zeros(m,K);
    for f = 1:K
        error_c(:,f) = sum((X - centroids(f,:)).^2,2);
    end
    [Y, idx] = min(error_c,[],2);

end

