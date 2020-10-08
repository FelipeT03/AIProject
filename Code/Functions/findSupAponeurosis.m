function [x_SupApo,y_SupApo] = findSupAponeurosis(eco, centroids)
%Encuentra el límite superior de la fascia superior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    K = 3;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroids);
    C_K = C(:,K);
    eco_C = C_K(idx_eco,:);%Imagen b/n
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    eco_C = bwareaopen(eco_C,2000);
    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);  
    [C,IA] = unique(col,'first');
    vector = [C row(IA)];
    
    x_SupApo = 1:size(eco,2);
    y_SupApo = zeros(size(eco,2),1) + mean(vector(:,2));
    y_SupApo(vector(:,1)) = vector(:,2);
end 