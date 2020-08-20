function [muscle_x, muscle_y, muscle_x_min, muscle_x_max] = muscle_x_y(eco)
%Encuentra en los centroides para el cálculo de la Apo inferior
    %% Parameters
    K = 2;

    %% Tratamiento de datos
    I = im2single(eco);
    
    %% Training
    L = imsegkmeans(I,K);
    
    %% Results
    eco_C = L == K;
    eco_C = findLargestArea(eco_C);
    [row,col] = find(eco_C);
    muscle_y = round((min(row) + max(row)) / 2);
    muscle_x = round((min(col) + max(col)) / 2);
    muscle_x_min = min(col);
    muscle_x_max = max(col);
    muscle_x = muscle_x -  muscle_x_min; %Al recortar la imagen se debe ajustar el centro
end 