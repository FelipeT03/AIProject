function [x_InfApo,y_InfApo] = findInfAponeurosis(eco,t_centroids)
%Encuentra el límite inferior de la fascia inferior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    eco_C = eco > t_centroids;
    img_size_eco = size(eco);
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    eco_C = bwareaopen(eco_C,1);%400
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    if length([S.Area]) >= 5
        eco_C = bwareaopen(eco_C,Areas(5));
    else 
        eco_C = bwareaopen(eco_C,Areas(length([S.Area])));
    end
       
    eco_C = eco_C(1:img_size_eco(1),1:img_size_eco(2));
    

    %% Encontrar los puntos que delimitan la figura
    [row,col] = find(eco_C);
    [C,IA] = unique(col,'last');
    vector = [C row(IA)];
    ajuste = mean(vector(round(end*0.6):round(end*0.9),2));
    x_InfApo = 1:size(eco,2);
    y_InfApo = zeros(size(eco,2),1) + ajuste;
    y_InfApo(vector(:,2) > (0.8*ajuste)) = vector(vector(:,2) > (0.8*ajuste),2);
    y_InfApo = medfilt1(y_InfApo,3);
end



