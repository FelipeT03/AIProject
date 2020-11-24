function [t_centroids, mask] = findCentrInfApo(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior
    %% Parameters
    K = 3;
    %% Training
    [~,centroids] = imsegkmeans(im2single(eco),K);
    centroids = sort(centroids,1);
    t_centroids = mean(centroids(end-1:end));
    %% area_delete
    eco_C = eco > t_centroids;
    stats = regionprops(eco_C,'BoundingBox');
    mask = ones(size(eco));
    stats_bb = [stats.BoundingBox];
    stats_bb = stats_bb(3:4:end);
    [~, position] = max(stats_bb);
    mask(round((stats(position).BoundingBox(2) + stats(position).BoundingBox(4))*1.1):end,:) = 0;

end 