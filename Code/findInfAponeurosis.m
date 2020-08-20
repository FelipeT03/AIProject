function [x_InfApo,y_InfApo] = findInfAponeurosis(eco,centroids,ajuste)
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
    eco_C(1:ajuste,:) = 1;
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    if length([S.Area]) >= 3
        eco_C = bwareaopen(eco_C,Areas(3));
    else 
        eco_C = bwareaopen(eco_C,Areas(length([S.Area])));
    end
    se90 = strel('line',5,90); 
    se0 = strel('line',30,0);
    eco_C = imdilate(eco_C,[se90 se0]);
    eco_C = imfill(eco_C,'holes');%Imagen rellena espacios libres dentro de un elemento 


%     eco_C = findLargestArea(eco_C);
%     centroid_y = regionprops(logical(sum(eco_C,2)),'Centroid');%calculo del centroide en y 
%     centroid_y = cat(1,centroid_y.Centroid);
%     centroid_y = round(centroid_y);

    seD = strel('rectangle',[3 3]); 
    eco_C = imerode(eco_C,seD); 
    eco_C = imerode(eco_C,seD);

    eco_C = findLargestArea(eco_C);
   
%     CC = bwconncomp(eco_C, 8);
%     S = regionprops(CC, 'Centroid','Area');
%     centroid_y = zeros(length([S.Area]),2);
%     for j = 1:size(centroid_y)
%         centroid_y(j,:) = [S(j).Centroid];
%     end
%     centroid_y = centroid_y(:,2);
%     [c,nArea] = min(centroid_y);
%     Areas = [S.Area];
%     L = labelmatrix(CC);
%     eco_C = ismember(L, find([S.Area] == Areas(nArea))); 

%     eco_C_outline = bwperim(eco_C); 
%     Segout_eco = eco;  
%     Segout_eco(eco_C_outline) = 1;  
%     imshow(Segout_eco) 
%     title('Eco')

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



