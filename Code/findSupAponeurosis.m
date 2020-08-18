function [x_SupApo,y_SupApo] = findSupAponeurosis(eco, centroids)
%Encuentra el límite superior de la fascia superior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    K = 2;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroids);
    C_K = C(:,K);
    eco_C = C_K(idx_eco,:);%Imagen b/n
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    se90 = strel('line',5,90); 
    se0 = strel('line',5,0);
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
    eco_C = bwareaopen(eco_C,Areas(2));

    %Encuentra el area mas cercana al centro
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Centroid','Area');
    centroid_y = [S(1).Centroid;S(2).Centroid];
    centroid_y = centroid_y(:,2);
    [c,nArea] = max(centroid_y);
    Areas = [S.Area];
    L = labelmatrix(CC);
    eco_C = ismember(L, find([S.Area] == Areas(nArea))); 
    
%     eco_C_outline = bwperim(eco_C); 
%     Segout_eco = eco;  
%     Segout_eco(eco_C_outline) = 1;  
%     figure()
%     imshow(eco_C)
%     pause()
    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);
    col_start = col(1);
    col_end = col(end);
    vector = zeros(col_end - col_start + 1,2);
    index = 0;
    %Análisis por columna
    for j = col_start:col_end
        index = index + 1;
        vector(index,:) = [j find(eco_C(:,j),1,'first')];
    end
    x_SupApo = vector(:,1);
    y_SupApo = vector(:,2);
    y_SupApo = smooth(x_SupApo,y_SupApo,0.2,'rloess'); %Use a span of 10% of the total number of data points.
end 