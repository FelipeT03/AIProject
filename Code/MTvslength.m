function  [measure_apo_s,measure_apo_i] =  MTvslength(idx_eco,Centroids,img_size,centroid_muscle_y,measure_x,previous_measure,frame)

    C_K = Centroids(:,end);
    eco_C = C_K(idx_eco,:);
    eco_C = reshape(eco_C, img_size(1), img_size(2), 1);
    apo_superior = findLargestArea(eco_C); 
    [row,col] = find(apo_superior);
    apo_superior_start = col(1);
    apo_superior_end = col(end);
    measure_apo_s = zeros(apo_superior_end - apo_superior_start + 1,2);  
    index = 0;
    for j = apo_superior_start:apo_superior_end
        index = index + 1;
        measure_apo_s(index,1) = j;
        measure_apo_s(index,2) = find(apo_superior(:,j),1,'last');
    end
    
    apo_inferior = eco_C - apo_superior;
    apo_inferior = apo_inferior(centroid_muscle_y(:,2):end,:);
    apo_inferior = findLargestArea(apo_inferior);
    
    [row,col] = find(apo_inferior);
    apo_inferior_start = col(1);
    apo_inferior_end = col(end);
    measure_apo_i = zeros(apo_inferior_end - apo_inferior_start + 1,2); 
    
    index = 0;
    for j = apo_inferior_start:apo_inferior_end
        index = index + 1;
        measure_apo_i(index,1) = j;
        measure_apo_i(index,2) = find(apo_inferior(:,j),1,'first');
    end 

    measure_apo_i(:,2) = measure_apo_i(:,2) + centroid_muscle_y(:,2) - 1;

    aponeurosis = apo_superior;
    aponeurosis(centroid_muscle_y(:,2):end,:) = logical(aponeurosis(centroid_muscle_y(:,2):end,:) + apo_inferior);%logical replace any number > 1 with 1
    
end 

%calcular la distancia entre los puntos de y para cada x, para un frame
%dado

    
