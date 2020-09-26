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
    eco_C = bwareaopen(eco_C,25);
    se90 = strel('line',5,90); 
    se0 = strel('line',30,0);
    eco_C = imdilate(eco_C,[se90 se0]);
    eco_C = imfill(eco_C,'holes');%Imagen rellena espacios libres dentro de un elemento 
    %Eliminación de bordes irregulares de la figura
    seD = strel('rectangle',[3 3]); 
    eco_C = imerode(eco_C,seD); 
    eco_C = imerode(eco_C,seD);

    %Encuentra las dos areas mas grandes
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    if length([S.Area]) >= 2
        eco_C = bwareaopen(eco_C,Areas(2));
    else 
        eco_C = bwareaopen(eco_C,Areas(length([S.Area])));
    end

    %Encuentra el area mas cercana al centro
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Centroid','Area');
    centroid_y = [S(1).Centroid;S(2).Centroid];
    centroid_y = centroid_y(:,2);
    [c,nArea] = max(centroid_y);
    Areas = [S.Area];
    L = labelmatrix(CC);
    eco_C = ismember(L, find([S.Area] == Areas(nArea))); 
    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);  
    [C,IA] = unique(col,'first');
    vector = [C row(IA)];
    
    x_SupApo = 1:size(eco,2);
    y_SupApo = zeros(size(eco,2),1) + mean(vector(:,2));
    y_SupApo(vector(:,1)) = vector(:,2);
end 