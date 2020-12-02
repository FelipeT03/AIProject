function [t_centroids, mask] = findCentrSupApo(eco, muscle_y_min)
%Encuentra los centroides de luminancia para fascia superior   
    %% Parameters
    K = 4;
    %% Training
    [~,centroids] = imsegkmeans(im2single(eco(muscle_y_min:end,:)),K);
    centroids = sort(centroids,1);
    t_centroids = mean(centroids(end-1:end)) * 1.12; 
    %1.12 valor que devuleve resultado similar al programa utilizado
    %anteriormente. Curso de Andrew Ng.
    %% Mask
    eco_C = eco > t_centroids;
    eco_C = bwareaopen(eco_C,1000);
    se90 = strel('line',20,90); 
    se0 = strel('line',5,0);    
    eco_C = imdilate(eco_C,[se90 se0]);
    stats = regionprops(eco_C,'BoundingBox');
    mask = ones(size(eco));
    mask((1:stats(1).BoundingBox(2) + stats(1).BoundingBox(4)),:) = 0;
    %mask((1:108),:) = 0; cambiar mascara superior
end 