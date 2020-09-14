function [muscle_x, muscle_y, muscle_x_min, muscle_x_max, muscle_y_max] = muscle_x_y(eco)
    %% Parameters
    K = 2;
    %% Tratamiento de datos
    I = im2single(eco);
    
    %% Training
    [L,centers] = imsegkmeans(I,K);
    
    %% Results
    [val, p_val] = max(centers); 
    eco_C = L == p_val;
    eco_C = bwareaopen(eco_C,100);
    %eco_C = findLargestArea(eco_C);
    [row,col] = find(eco_C);
    muscle_y = round((min(row) + max(row)) / 2);    muscle_x = round((min(col) + max(col)) / 2);
    muscle_x_min = min(col);
    muscle_x_max = max(col);
    muscle_x = muscle_x -  muscle_x_min; %Al recortar la imagen se debe ajustar el centro
    muscle_y_max = round(max(row) + (max(row) - muscle_y) * 0.3);
    if muscle_y_max > size(eco,1)
        muscle_y_max = size(eco,1);
    end
end 