function centroidsSupApo = findCentrSupApo(eco)
%Encuentra los centroides de luminancia para fascia superior
    %% Parameters
    K = 2;
    threshold = 30/100;%Porcentaje para treshold
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
    centroidsSupApo  = sort(centroids,1);
end 