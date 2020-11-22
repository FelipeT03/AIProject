function [t_centroids, mask] = findCentrSupApo(eco)
%Encuentra los centroides de luminancia para fascia superior
    %% Parameters
    K = 3;
    threshold = graythresh(eco);%Porcentaje para treshold
    max_iters = 100; 
    centroids = NaN;
    %% Tratamiento de los datos
    eco_t = eco .* imbinarize(eco,threshold);
    data_eco = eco_t(:);
    data_eco(data_eco == 0) = [];

    %% Training
    while sum(isnan(centroids),'all')
        initial_centroids = kMeansInitCentroids(data_eco, K);
        [centroids, ~] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsSupApo  = sort(centroids,1);
    t_centroids = (centroidsSupApo(end) + centroidsSupApo(end - 1)) / 2;
    
    %% Mask
    eco_C = eco > t_centroids;
    eco_C = bwareaopen(eco_C,1000);
    se90 = strel('line',20,90); 
    se0 = strel('line',5,0);
    eco_C = imdilate(eco_C,[se90 se0]);
    stats = regionprops(eco_C,'BoundingBox');
    mask = ones(size(eco));
    mask(1:stats(1).BoundingBox(2) + stats(1).BoundingBox(4),:) = 0;

end 