function [x_InfApo,y_InfApo] = findInfAponeurosis(eco,centroids)
%Encuentra el límite inferior de la fascia inferior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    K = 2;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroids);
    C_K = C(:,K);
    eco_C = C_K(idx_eco,:);%Imagen b/n
    
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    
    
    % Crear la base donde se va a formar la fascia inferior
    T = graythresh(eco);
    eco_T = imbinarize(eco,T);
    CC = bwconncomp(eco_T, 8);
    S = regionprops(CC, 'Area');
    areas = [S.Area];
    areas = sort(areas);
    areasgrad = gradient(areas);
    areasgrad2 = gradient(areasgrad);
    [value,value_p] = max(areasgrad2);
    if value_p < length(areas)
        value_p = value_p + 1;
    end
    BW2 = bwareaopen(eco_T,areas(value_p));
    S = regionprops(BW2,'Extrema','Centroid','Area');
    numObj = numel(S); 
    eco_T_centroids = zeros(numObj,2);
    eco_T_extrema = zeros(numObj,2);
    eco_T_area = zeros(numObj,1);
    for k = 1 : numObj
        eco_T_centroids(k,:) = [S(k).Centroid(1), S(k).Centroid(2)]; 
        eco_T_extrema(k,:) = [S(k).Extrema(2,1), S(k).Extrema(2,2)]; 
        eco_T_area(k) = S(k).Area(1);
    end
    img_size_eco_x = img_size_eco(2);
    img_size_eco_y = img_size_eco(1);
    [value, value_p] = max(eco_T_centroids(:,2) .* (eco_T_centroids(:,2) < round(img_size_eco_y * 0.5)));
    %ajuste = round(eco_T_extrema(value_p,2)) + 1;
    ajuste = round(eco_T_centroids(value_p,2) * 0.8);
    
    %Eliminar partes brillantes que no sean parte del músculo
    eco_T_centroids_delete = eco_T_centroids .* (eco_T_centroids(:,2) > round(img_size_eco_y * 0.6));
    eco_T_centroids_delete = eco_T_centroids_delete .* (eco_T_centroids(:,1) > round(img_size_eco_x * 0.5));
    eco_C_delete = zeros(img_size_eco);
    value_p = find(eco_T_centroids_delete(:,1) > 0);
    CC = bwconncomp(BW2, 8);
    L = labelmatrix(CC);
    for  k = 1:length(value_p)
        eco_C_delete = eco_C_delete + ismember(L, find(eco_T_area == eco_T_area(value_p(k)))); 
    end
    eco_C_delete = eco_C_delete > 0;
    se90 = strel('line',20,90); 
    se0 = strel('line',20,0);
    eco_C_delete = imdilate(eco_C_delete,[se90 se0]);
    
    
    eco_C = eco_C .* (eco_C_delete < 1);
    eco_C(1:ajuste,:) = 1;
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    if length([S.Area]) >= 3
        eco_C = bwareaopen(eco_C,Areas(3));
    else 
        eco_C = bwareaopen(eco_C,Areas(length([S.Area])));
    end
%     se90 = strel('line',5,90); 
%     se0 = strel('line',30,0);
%     eco_C = imdilate(eco_C,[se90 se0]);
    eco_C = imfill(eco_C,'holes');%Imagen rellena espacios libres dentro de un elemento 


%     eco_C = findLargestArea(eco_C);
%     centroid_y = regionprops(logical(sum(eco_C,2)),'Centroid');%calculo del centroide en y 
%     centroid_y = cat(1,centroid_y.Centroid);
%     centroid_y = round(centroid_y);

    seD = strel('rectangle',[3 3]); 
    eco_C = imerode(eco_C,seD); 
    eco_C = imerode(eco_C,seD);

    
    eco_C(1:ajuste,:) = 1;
    
    S = regionprops(eco_C,'Extrema','Centroid');
    numObj = numel(S); 
    eco_T_centroids = zeros(numObj,2);
    eco_T_extrema = zeros(numObj,2);
    for k = 1 : numObj
        eco_T_centroids(k,:) = [S(k).Centroid(1), S(k).Centroid(2)]; 
        eco_T_extrema(k,:) = [S(k).Extrema(2,1), S(k).Extrema(2,2)]; 
    end
    vectordeprueba = round(eco_T_extrema .* (eco_T_centroids(:,2)< round(img_size_eco_y * 0.6)));
    for k = 1 : numObj
        if vectordeprueba(k,2) > 0
            eco_C(1:vectordeprueba(k,2),vectordeprueba(k,1)) = 1;%vectordeprueba ayuda a unir partes pequeñas (cambiar de nombre)
        end
    end
        
    eco_C = eco_C(1:img_size_eco(1),1:img_size_eco(2));
    
    eco_C = findLargestArea(eco_C);

    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);
    col_start = col(1);
    col_end = col(end);
    vector = zeros(col_end - col_start + 1,2);
    index = 0;
    %Análisis por columna
    for j = col_start:col_end
        index = index + 1;
        vector(index,:) = [j find(eco_C(:,j),1,'last')];
    end
    x_InfApo = vector(:,1);
    y_InfApo = vector(:,2);
    y_InfApo = smooth(vector(:,1),y_InfApo,0.2,'rloess'); %Use a span of 10% of the total number of data points.
end



