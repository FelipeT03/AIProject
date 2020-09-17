function Scale_Factor = ScaleFactor(ruler)
%Scale_Factor [mm]
    ModelScaleFactor = load('ModelScaleFactor.mat');
    ruler = imcrop(ruler,[17 20 10 size(ruler,2)]);
    ruler = rgb2gray(ruler) > (255/2);
    ruler_y = sum(ruler,2) > 0;
    stats_ruler_y = regionprops(ruler_y,'Centroid');
    ruler_centroids_y = [stats_ruler_y.Centroid];
    ruler_centroids_y = reshape(ruler_centroids_y,[2 length(ruler_centroids_y)/2])';
    ruler_centroids_y(:,1) = [];
    ruler_centroids_y = round(ruler_centroids_y);
    ruler_number = zeros(15,size(ruler,2),length(ruler_centroids_y));
    for j = 1:length(ruler_centroids_y)
        ruler_number(:,:,j) = ruler(ruler_centroids_y(j) - 7:ruler_centroids_y(j) + 7,1:end);
    end
    ruler_number = ruler_number .* 255;
    ruler_number_first = classify(ModelScaleFactor.net,imresize(ruler_number(:,:,1),[28 28]));
    ruler_number_second = classify(ModelScaleFactor.net,imresize(ruler_number(:,:,2),[28 28]));
    %grp2idx devuelve la posición del label resultante, en el entrenamiento
    %0 tiene la primera posición, 1 la 2, 3 la 4, etc. Por lo que se
    %debería restar el valor de 1 luego de usar grp2idx, pero debido a que
    %está en ambas partes de la resta esto haría que se anulen. 
    Scale_Factor = ((grp2idx(ruler_number_second) - grp2idx(ruler_number_first)) / (ruler_centroids_y(2) - ruler_centroids_y(1))) * 10 ; 
end