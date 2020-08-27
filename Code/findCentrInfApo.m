function [centroidsInfApo, area_delete] = findCentrInfApo(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior
    %% Parameters
    K = 2;
    threshold = 1/100;%Porcentaje para treshold
    max_iters = 100; 
    centroids = NaN;
    %% Tratamiento de los datos
    data_eco = eco(:);
    data_eco(data_eco < threshold) = [];

    %% Training
    while sum(isnan(centroids),'all')
    initial_centroids = kMeansInitCentroids(data_eco, K);
    [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsInfApo  = sort(centroids,1);
    
    %% area_delete
    T = graythresh(eco) + 0.05;
    BW = imbinarize(eco,T);
    BW = bwareaopen(BW,25);
    D = bwdist(~bwconvhull(BW,'objects')); 
    D = D ./ max(D);
    D = D > 0.2;
    se = strel('rectangle',[10 150]);
    D(isnan(D)) = 0;
    D = imclose(D,se); 
    D = bwdist(D);
    DL = watershed(D);
    bgm = DL == 0;
    area = ~bgm;
    S = regionprops(area, 'Area', 'Centroid');
    Areas = [S.Area];
    if length([S.Area]) >= 2
        area = bwareaopen(area,Areas(2));
    else 
        area = bwareaopen(area,Areas(length([S.Area])));
    end
    
    CC = bwconncomp(area, 8);
    S = regionprops(CC, 'Area', 'Centroid');
    Areas = [S.Area];
    numObj = numel(S);
    Centroids = zeros(numObj,2);
    for k = 1:numObj
        Centroids(k,:) = [S(k).Centroid(1) S(k).Centroid(2)];
    end
    [value, value_p] = min(Centroids(:,2));
    L = labelmatrix(CC);
    area_delete = ismember(L, find([S.Area] == Areas(value_p))); 
    
    
    %area_delete = findLargestArea(area);

end 