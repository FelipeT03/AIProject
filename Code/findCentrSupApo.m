function centroidsSupApo = findCentrSupApo(eco)
    K = 2;
    threshold = 20/100;%Porcentaje para treshold
    max_iters = 100; 

    centroids = NaN;

    data_eco = eco(:);
    
    data_eco(data_eco < threshold) = [];


    while sum(isnan(centroids),'all')
        initial_centroids = kMeansInitCentroids(data_eco, K);
        [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    end
    centroidsSupApo  = sort(centroids,1);
end 