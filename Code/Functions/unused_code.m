%% Carpeta con secciones de código que ya no se utilizan
    %% MT vs length
%     % Before Stimulation
%     [x_InfApo_b,y_InfApo_b] = findInfAponeurosis((eco_b(muscle_y+1:end ,:) .* area_delete_b),centroidsInfApo_b);
%     y_InfApo_b = y_InfApo_b + muscle_y; 
%     [x_SupApo_b,y_SupApo_b] = findSupAponeurosis(eco_b(1:muscle_y,:),centroidsSupApo_b);
%     %Cálculo de la distancia en [mm] 
%     muscle_thickness_b = y_InfApo_b - y_SupApo_b;
%     measure_y_inf_b = y_InfApo_b(x_InfApo_b == muscle_x);
%     measure_y_sup_b = y_SupApo_b(x_SupApo_b == muscle_x);
%     %Escalamineto de los límites de las fascias de pixeles a [mm]
%     muscle_thickness_b = param * muscle_thickness_b;
%     x_InfApo_b = param * x_InfApo_b;
%     y_InfApo_b = param * y_InfApo_b;
%     x_SupApo_b = param * x_SupApo_b;
%     y_SupApo_b = param * y_SupApo_b;
%     measure_y_inf_b = param * measure_y_inf_b;
%     measure_y_sup_b = param * measure_y_sup_b;
% 
%     % After Stimulation
%     [x_InfApo_a,y_InfApo_a] = findInfAponeurosis((eco_a(muscle_y+1:end ,:) .* area_delete_a),centroidsInfApo_a);
%     y_InfApo_a = y_InfApo_a + muscle_y; 
%     [x_SupApo_a,y_SupApo_a] = findSupAponeurosis(eco_a(1:muscle_y,:),centroidsSupApo_a);
%     %Cálculo de la distancia en [mm] 
%     muscle_thickness_a = y_InfApo_a - y_SupApo_a;
%     measure_y_inf_a = y_InfApo_a(x_InfApo_a == muscle_x);
%     measure_y_sup_a = y_SupApo_a(x_SupApo_a == muscle_x);
%     %Escalamineto de los límites de las fascias de pixeles a [mm]
%     muscle_thickness_a = param * muscle_thickness_a;
%     x_InfApo_a = param * x_InfApo_a;
%     y_InfApo_a = param * y_InfApo_a;
%     x_SupApo_a = param * x_SupApo_a;
%     y_SupApo_a = param * y_SupApo_a;
%     measure_y_inf_a = param * measure_y_inf_a;
%     measure_y_sup_a = param * measure_y_sup_a;

    %%   ---- eco + plot ----
%         figure
%         set(gcf, 'Position', get(0, 'Screensize'));
%         subplot(1, 2, 1)
%             imshow(eco,imref2d(size(eco),param,param))
%             title(sprintf('Frame: %d ', frame))
%             hold on 
%             plot(x_InfApo,y_InfApo,'r--','LineWidth',3) 
%             plot(x_SupApo,y_SupApo,'r--','LineWidth',3) 
%             plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'yo','LineWidth',3)
%             plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'y-','LineWidth',3)
%             hold off
%             xlabel('[mm]')
%             ylabel('[mm]')
%         
%         subplot(1, 2, 2)
%             plot(medfilt1(memoria_distancia(:,3),3),'LineWidth',2) %medfilt1 quitamos picos 
%             hold on 
%             xline(locs(1),'--','LineWidth',2);
%             xline(locs(2),'--','LineWidth',2);
%             hold off
%             title(strcat('Stimulation Video: ', video_name))
%             xlabel('Frame')
%             ylabel('[mm]')
%             grid minor    
%% Une secciones de fascia pequeñas con la fascia más grande
%     eco_C(1:ajuste,:) = 1;
    
%     S = regionprops(eco_C,'Extrema','Centroid');
%     numObj = numel(S); 
%     eco_T_centroids = zeros(numObj,2);
%     eco_T_extrema = zeros(numObj,2);
%     for k = 1 : numObj
%         eco_T_centroids(k,:) = [S(k).Centroid(1), S(k).Centroid(2)]; 
%         eco_T_extrema(k,:) = [S(k).Extrema(2,1), S(k).Extrema(2,2)]; 
%     end
%     vectordeprueba = round(eco_T_extrema .* (eco_T_centroids(:,2)< round(img_size_eco_y * 0.8)));
%     for k = 1 : numObj
%         if vectordeprueba(k,2) > 0
%             eco_C(1:vectordeprueba(k,2),vectordeprueba(k,1)) = 1;%vectordeprueba ayuda a unir partes pequeñas (cambiar de nombre)
%         end
%     end