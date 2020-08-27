function [centroids, idx] = runkMeans(X, initial_centroids,max_iters)
%RUNKMEANS runs the K-Means algorithm on data matrix X, where each row of X
%is a single example

m = size(X,1);
K = size(initial_centroids, 1);
centroids = initial_centroids;
previous_centroids = centroids;
idx = zeros(m, 1);

    % Run K-Means
    for i=1:max_iters

        % Output progress
        %fprintf('K-Means iteration %d/%d...\n', i, max_iters);

        % For each example in X, assign it to the closest centroid
        idx = findClosestCentroids(X, centroids);    

        % Given the memberships, compute new centroids
        centroids = computeCentroids(X, idx, K);

        if sum(abs(centroids - previous_centroids),'all') < 0.0005
            %fprintf('K-Means iteration %d/%d...\n', i, max_iters);
            break
        end
        if sum(isnan(centroids),'all')
            %fprintf('length(Centroids) < K \n');
            break
        end
        previous_centroids = centroids;
    end

end

