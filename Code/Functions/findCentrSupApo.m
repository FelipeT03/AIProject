function [centroidsSupApo, mask] = findCentrSupApo(eco)
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
        [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsSupApo  = sort(centroids,1);
    
    %% Mask
    K = 3;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroidsSupApo);
    C_K = C(:,K);
    eco_C = C_K(idx_eco,:);%Imagen b/n
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    eco_C = bwareaopen(eco_C,25);
    se90 = strel('line',5,90); 
    se0 = strel('line',40,0);
    eco_C = imdilate(eco_C,[se90 se0]);
    mask =  ~filterRegionsSup(eco_C > 0);

end 