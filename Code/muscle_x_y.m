function [muscle_x, muscle_y, muscle_x_min, muscle_x_max] = muscle_x_y(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior
    %% Parameters
    K = 2;
    %threshold = 0.1/100;%Porcentaje para treshold
    max_iters = 100;
    centroids = NaN;
    %% Tratamiento de los datos
    data_eco = eco(:);
    %data_eco(data_eco < threshold) = [];

    %% Training
    while sum(isnan(centroids),'all')
    initial_centroids = kMeansInitCentroids(data_eco, K);
    [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroids  = sort(centroids,1);
    
    eco_C = eco > mean(centroids);
    eco_C = findLargestArea(eco_C);
    [row,col] = find(eco_C);
    muscle_y = round((min(row) + max(row)) / 2);
    muscle_x = round((min(col) + max(col)) / 2);
    muscle_x_min = min(col);
    muscle_x_max = max(col);
    
end 