function centroidsInfApo = findCentrInfApo(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior

    K = 2;
%     threshold = 0.1/100;%Porcentaje para treshold
    max_iters = 100; 

    centroids = NaN;
    
    data_eco = eco(:);
%     data_eco(data_eco < threshold) = [];


    while sum(isnan(centroids),'all')
    initial_centroids = kMeansInitCentroids(data_eco, K);
    [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsInfApo  = sort(centroids,1);
end 