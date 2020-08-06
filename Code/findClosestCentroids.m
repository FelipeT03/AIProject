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
%     for l = 1:m
%         for j = 2:K
%             if sum((X(l, :) - centroids(j,:)) .^ 2,2) < sum((X(l, :) - centroids(idx(l),:)) .^ 2,2)
%                 idx(l) = j;
%             end
%         end
%     end


end

