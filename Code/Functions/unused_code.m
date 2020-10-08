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

%% Eliminar valores que no son parte de la fascia inferior
    
    
    % Crear la base donde se va a formar la fascia inferior
%     T = graythresh(eco);
%     eco_T_r = imbinarize(eco,T);
%     eco_T_r = bwareaopen(eco_T_r,100);
%     D = bwdist(eco_T_r);
%     DL = watershed(D);
%     eco_T_r = DL > 0;
    
   
%     S = regionprops(eco_T_r,'Area','Centroid');
%     numObj = numel(S); 
%     eco_T_centroids = (reshape([S.Centroid],[2 numObj]))';
%     eco_T_area = ([S.Area])';
%     img_size_eco_x = img_size_eco(2);
%     img_size_eco_y = img_size_eco(1);

    
    %Eliminar partes brillantes que no sean parte del músculo
%     eco_T_centroids_delete = eco_T_centroids .* (eco_T_centroids(:,2) > round(img_size_eco_y * 0.8));
%     eco_T_centroids_delete = eco_T_centroids_delete .* (eco_T_centroids(:,1) > round(img_size_eco_x * 0.4));
%     
%     eco_C_delete = zeros(img_size_eco);
%     value_p = find(eco_T_centroids_delete(:,1) > 0);
%     CC = bwconncomp(eco_T_r, 8);
%     L = labelmatrix(CC);
%     for  k = 1:length(value_p)
%         eco_C_delete = eco_C_delete | ismember(L, find(eco_T_area == eco_T_area(value_p(k)))); 
%     end
%     se90 = strel('line',20,90); 
%     se0 = strel('line',20,0);
%     eco_C_delete = imdilate(eco_C_delete,[se90 se0]);
    
%     
%     eco_C = eco_C .* (eco_C_delete < 1);

%% Optimizar resultados 
%     for x_value_time = 1:size(memoria_fascia_sup_inf,2)
%         if x_value_time < before_stimulation_end_frame 
%             memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,1),0.1,'rloess');
%             memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,2),0.3,'rloess');
%         elseif x_value_time < after_stimulation_start_frame
%             memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,1),0.1,'rloess');
%             memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,2),0.3,'rloess');
%         elseif x_value_time < after_stimulation_end_frame
%             memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,1),0.1,'rloess');
%             memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,2),0.3,'rloess');
%         elseif x_value_time >= after_stimulation_end_frame
%             memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,1) = smooth(memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,1),0.1,'rloess');
%             memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,2) = smooth(memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,2),0.3,'rloess');
%         end
%     end
%% Fascia superior
%     se90 = strel('line',5,90); 
%     se0 = strel('line',40,0);
%     eco_C = imdilate(eco_C,[se90 se0]);
%     eco_C = eco_C .* ~filterRegions(eco_C > 0);
%     eco_C = bwareaopen(eco_C,2000);
%     eco_C = imfill(eco_C,'holes');%Imagen rellena espacios libres dentro de un elemento 
%     %Eliminación de bordes irregulares de la figura
%     seD = strel('rectangle',[3 3]); 
%     eco_C = imerode(eco_C,seD); 
%     eco_C = imerode(eco_C,seD);
% 
%     %Encuentra las dos areas mas grandes
%     CC = bwconncomp(eco_C, 8);
%     S = regionprops(CC, 'Area');
%     Areas = sort([S.Area],'descend');
%     if length([S.Area]) >= 2
%         eco_C = bwareaopen(eco_C,Areas(2));
%     else 
%         eco_C = bwareaopen(eco_C,Areas(length([S.Area])));
%     end
% 
%     %Encuentra el area mas cercana al centro
%     CC = bwconncomp(eco_C, 8);
%     S = regionprops(CC, 'Centroid','Area');
%     centroid_y = [S(1).Centroid;S(2).Centroid];
%     centroid_y = centroid_y(:,2);
%     [~,nArea] = max(centroid_y);
%     Areas = [S.Area];
%     L = labelmatrix(CC);
%     eco_C = ismember(L, find([S.Area] == Areas(nArea))); 