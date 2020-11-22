function [t_centroids, area_delete] = findCentrInfApo(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior
    %% Parameters
    K = 2;
    threshold = 1/100;%Porcentaje para treshold
    max_iters = 100; 
    centroids = NaN;
    
    %% area_delete
    T = graythresh(eco) + 0.05;
    BW = imbinarize(eco,T);
    BW = bwareaopen(BW,50);
    D = bwdist(~bwconvhull(BW,'objects')); 
    D = D ./ max(D);
    D = D > 0.2;
    se = strel('rectangle',[10 100]);
    D(isnan(D)) = 0;
    D = imclose(D,se); 
    D = bwdist(D);
    DL = watershed(D);
    bgm = DL == 0;
    area = ~bgm;
    
    v_1 = round([(size(eco,1) * 0.75) 1]);  %row col
    v_2 = round([1 size(eco,2) * 0.3]);
    x = [v_1(2) v_2(2)];                   % x coordinates
    y = [v_1(1) v_2(1)];                   % y coordinates
    nPoints = max(abs(diff(x)), abs(diff(y)))+1;    % Number of points in line
    rIndex = round(linspace(y(1), y(2), nPoints));  % Row indices
    cIndex = round(linspace(x(1), x(2), nPoints));  % Column indices
    index = sub2ind(size(area), rIndex, cIndex);     % Linear indices
    area(index) = 1;  % Set the line points to white
    
    v_1 = round([(size(eco,1) * 0.25) size(eco,2)]); %row col
    v_2 = round([1 size(eco,2) * 0.75]);
    x = [v_1(2) v_2(2)];                   % x coordinates
    y = [v_1(1) v_2(1)];                   % y coordinates
    nPoints = max(abs(diff(x)), abs(diff(y)))+1;    % Number of points in line
    rIndex = round(linspace(y(1), y(2), nPoints));  % Row indices
    cIndex = round(linspace(x(1), x(2), nPoints));  % Column indices
    index = sub2ind(size(area), rIndex, cIndex);     % Linear indices
    area(index) = 1;  % Set the line points to white
    
    
    area_l = area(:,1:round(size(eco,2) * 0.4));
        S = regionprops(area_l, 'Area', 'Centroid');
        Areas = [S.Area];
        Areas = sort(Areas,'descend');
        if length([S.Area]) >= 2
            area_l = bwareaopen(area_l,Areas(2));
        else 
            area_l = bwareaopen(area_l,Areas(length([S.Area])));
        end

        CC = bwconncomp(area_l, 8);
        S = regionprops(CC, 'Area', 'Centroid');
        Areas = [S.Area];
        numObj = numel(S);
        Centroids = zeros(numObj,2);
        for k = 1:numObj
            Centroids(k,:) = [S(k).Centroid(1) S(k).Centroid(2)];
        end
        [value, value_p] = min(Centroids(:,2));
        L = labelmatrix(CC);
        area_delete_l = ismember(L, find([S.Area] == Areas(value_p)));
        
    
        
        
    area_r = area(:,(1 + round(size(eco,2) * 0.4)):end);
    %0.4 valor con el cual se lograba identificar fascia inferior para
    %casos donde se tenían mancahs debajo del lado derecho. 
        S = regionprops(area_r, 'Area', 'Centroid');
        Areas = [S.Area];
        Areas = sort(Areas,'descend');
        if length([S.Area]) >= 2
            area_r = bwareaopen(area_r,Areas(2));
        else 
            area_r = bwareaopen(area_r,Areas(length([S.Area])));
        end

        CC = bwconncomp(area_r, 8);
        S = regionprops(CC, 'Area', 'Centroid');
        Areas = [S.Area];
        numObj = numel(S);
        Centroids = zeros(numObj,2);
        for k = 1:numObj
            Centroids(k,:) = [S(k).Centroid(1) S(k).Centroid(2)];
        end
        [value, value_p] = min(Centroids(:,2));
        L = labelmatrix(CC);
        area_delete_r = ismember(L, find([S.Area] == Areas(value_p))); 
    
    area_delete = [area_delete_l,area_delete_r];
    se90 = strel('line',5,90); 
    se0 = strel('line',5,0);
    area_delete = imdilate(area_delete,[se90 se0]);

    %% Tratamiento de los datos
    data_eco = eco .* area_delete;
    data_eco = data_eco(:);
    data_eco(data_eco < threshold) = [];

    %% Training
    while sum(isnan(centroids),'all')
        initial_centroids = kMeansInitCentroids(data_eco, K);
        [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsInfApo  = sort(centroids,1);
    t_centroids = (centroidsInfApo(end) + centroidsInfApo(end - 1)) / 2;

end 