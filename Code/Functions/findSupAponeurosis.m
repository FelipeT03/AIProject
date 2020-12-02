function [x_SupApo,y_SupApo] = findSupAponeurosis(eco, t_centroids)
%Encuentra el límite superior de la fascia superior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    eco_C = eco > t_centroids;
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    eco_C = bwareaopen(eco_C,round(Areas(1) * 0.5)); %0.5
    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);  
    [C,IA] = unique(col,'first');
    vector = [C row(IA)];
    x_SupApo = 1:size(eco,2);
    y_SupApo = zeros(size(eco,2),1) + mean(vector(:,2));
    y_SupApo(vector(:,1)) = vector(:,2);
end 