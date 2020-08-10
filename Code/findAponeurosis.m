function  [aponeurosis, measure] = findAponeurosis(idx_eco,Centroids,img_size,centroid_muscle_y,measure_x,previous_measure,frame)
    C_K = Centroids(:,end);
    eco_C = C_K(idx_eco,:);
    eco_C = reshape(eco_C, img_size(1), img_size(2), 1);
    apo_superior = findLargestArea(eco_C); 
    aponeurosis = apo_superior;
    measure(1) = find(apo_superior(:,measure_x),1,'last');
    apo_inferior = eco_C - apo_superior;
    apo_inferior = apo_inferior(centroid_muscle_y(:,2):end,:);%imprimir este dato para visualizar con ruido 
    apo_inferior = findLargestArea(apo_inferior);
    pmeasure = find(apo_inferior(:,measure_x),1,'first');
    if isempty(pmeasure)
        measure(2) = previous_measure(2);
        fprintf('No se detecta aponeurosis inferior. Frame: %d \n',frame)
    else
        measure(2) = pmeasure + centroid_muscle_y(:,2) - 1;
    end

    aponeurosis(centroid_muscle_y(:,2):end,:) = logical(aponeurosis(centroid_muscle_y(:,2):end,:) + apo_inferior);%logical replace any number > 1 with 1
    
end 