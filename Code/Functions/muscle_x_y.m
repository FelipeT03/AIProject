function [muscle_x, muscle_y, muscle_x_min, muscle_x_max, muscle_y_min] = muscle_x_y(eco)
    % El punto medio en y implica que se corta el video a la mitad. Para casoso donde la fascia inferior esté más arriba
    % se puede eliminar parcial o completamente.
    %% Parameters
    K = 2;
    %% Tratamiento de datos
    I = im2single(eco);
    
    %% Training
    [L,centers] = imsegkmeans(I,K);
    
    %% Results
    [~, p_val] = max(centers); 
    eco_C = L == p_val;
    eco_C = bwareaopen(eco_C,100);
    [row,col] = find(eco_C);
    muscle_y = round((min(row) + max(row)) / 2);    muscle_x = round((min(col) + max(col)) / 2);
    muscle_x_min = min(col);
    muscle_x_max = max(col);
    muscle_x = muscle_x -  muscle_x_min; %Al recortar la imagen se debe ajustar el centro
    muscle_y_min = round(min(row));
end 