function [x_InfApo,y_InfApo] = findInfAponeurosis(eco,t_centroids)
%Encuentra el límite inferior de la fascia inferior y devuelve su posición
%en un vector(x,y) utilizando los centroides de luminancia proporcionados
    eco_C = eco > t_centroids;
    %% Tratamiento de la imagen hasta conseguir una sola figura 
    eco_C = bwareaopen(eco_C,400);%400
    CC = bwconncomp(eco_C, 8);
    S = regionprops(CC, 'Area');
    Areas = sort([S.Area],'descend');
    eco_C = bwareaopen(eco_C,round(Areas(1) * 0.3));

    %% Encontrar los puntos que delimitan la figura
    %0.8 del promedio, debe superar este valor para ser considerado como
    %parte de la fascia, si es inferior a este valor se asigna el valor
    %promedio.
    eco_C(1,:) = 1;
    [row,col] = find(eco_C);
    [C,IA] = unique(col,'last');
    vector = [C row(IA)];
    ajuste = mean(vector(round(end*0.2):round(end*0.8),2));
    x_InfApo = 1:size(eco,2);
    y_InfApo = zeros(size(eco,2),1) + ajuste;
    y_InfApo(vector(:,2) > (0.5*ajuste)) = vector(vector(:,2) > (0.5*ajuste),2);
    y_InfApo = medfilt1(y_InfApo,3);
end



