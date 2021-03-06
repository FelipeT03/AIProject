function [eco_memory, memoria_fascia_sup_inf, Results] = Measure(video_name,path_v)
    %% Pruebas con videos
    %Lista de Toolbox:
    %- Computer Vision System Toolbox 
    %- Image Processing Toolbox 
    %- Curve Fitting Toolbox
    %- Deep Learning Toolbox
    %% Parameters 
    cut_area = [30 25 595 455];
    v = VideoReader(strcat(path_v,video_name));
    memoria_distancia = zeros(round(v.FrameRate * v.Duration),2);
    movimiento = zeros(round(v.FrameRate * v.Duration),2);
    param = ScaleFactor(readFrame(v));  

    %% Cortar el video
    App_Status = waitbar(0,'Processing video...','Name','Wait');
    
    v.CurrentTime = 0;
    %Frame en escala de grises y con rango de 0 a 1
    eco = readFrame(v);
    eco = rgb2gray(eco);
    eco = imcrop(eco,cut_area);
    eco = imadjust(eco);
    eco = double(eco);
    eco = eco / max(eco,[],'all'); % range(0-1)

    %Punto medio en x & y del musculo
    [muscle_x, muscle_y, muscle_x_min, muscle_x_max, muscle_y_min] = muscle_x_y(eco);
    cut_area(1) = cut_area(1) + muscle_x_min - 1;
    cut_area(3) = muscle_x_max - muscle_x_min - 1;
    %cut_area(4) = muscle_y_max;
    
    %Corte y procesamiento del video
    eco_memory = read(v);
    eco_memory = squeeze(eco_memory(:,:,1,:));
    eco_memory = eco_memory(cut_area(2):cut_area(2) + cut_area(4),cut_area(1):cut_area(1) + cut_area(3),:);
    eco_memory = imadjustn(eco_memory);
    eco_memory = double(eco_memory);
    eco_memory = eco_memory / max(eco_memory,[],'all');
    %% Detectar movimiento    
    waitbar(0.1,App_Status,'Selecting best frames...');
    opticFlow = opticalFlowHS;

    for frame = 1:size(eco_memory,3)
        flow = estimateFlow(opticFlow,eco_memory(:,:,frame));
        movimiento(frame,1) = frame;
        movimiento(frame,2) = sum([flow.Magnitude],'all');
        memoria_distancia(frame,2) = v.CurrentTime;
    end
    movimiento(:,1) = 1:size(eco_memory,3);
    movimiento(1:10,:) = []; %Se genera un pico dentro del primer frame ya que se detecta un cambio.
    [~,locs_1] = findpeaks(movimiento(:,2),movimiento(:,1),'SortStr','descend','MinPeakDistance',5);
    locs_1 = sort(locs_1(1:2));
    [~,locs_2] = findpeaks(-movimiento(:,2),movimiento(:,1),'SortStr','descend','MinPeakDistance',4);
    locs_2 = [locs_2 ; locs_1];
    locs_2 = sort(locs_2);
    before_stimulation_end_frame = locs_2(find(locs_2 == locs_1(1)) - 1);
    after_stimulation_start_frame = locs_2(find(locs_2 == locs_1(1)) + 1);
    after_stimulation_end_frame = locs_2(find(locs_2 == locs_1(2)) - 1);


    %Se toma el frame m�s est�tico dentro de cada secci�n
    [~,before_f] = min(movimiento(1:locs_1(1),2));
    before_f = before_f + 10;
    [~,after_f] = min(movimiento((locs_1(1) + 1):(locs_1(2) - 5),2));
    after_f = after_f + 10 + locs_1(1);

    %% Selecci�n de los frames
    waitbar(0.2,App_Status,'Selecting best frames...');

    %Se realizan dos entrenamientos en dos frames diferentes, se toma el frame
    %m�s est�tico dentro de la zona sin estimulaci�n y de la zona con
    %estimulaci�n. Con esto logramos obtener los centroides de luminancia
    %v�lidos para cada secci�n


    %Before stimulation
    eco_b = eco_memory(:,:,before_f);
    %After Stimulation
    eco_a = eco_memory(:,:,after_f);


    %% Training y c�lculo de la m�scara
    %Entrenamiento para frames sin estimulaci�n
    % Centroides para Aponeurosis Inferior
    
    %muscle_y = 230; Seccion para cambiar el valor medio del musculo
    
    [centroidsInfApo_b, area_delete_b] = findCentrInfApo(eco_b((muscle_y+1):end,:));

    % Centroides para Aponeurosis Superior
    [centroidsSupApo_b, mask_sup] = findCentrSupApo(eco_b(1:muscle_y,:),muscle_y_min);

    %Entrenamiento para frames con estimulaci�n
    % Centroides para Aponeurosis Inferior
    [~, area_delete_a] = findCentrInfApo(eco_a((muscle_y+1):end,:));
    area_delete_a = area_delete_a | area_delete_b; %el area despues de la estimulacion no puede ser mas peque�a por lo que se suman ambas para asegurar que m�nimo se tiene el mismo tama�o de �rea
    % Centroides para Aponeurosis Superior
    %centroidsSupApo_a = findCentrSupApo(eco_a(1:muscle_y,:));


    %% Results
    %Uso de los centroides del primer frame en todos los frames del video
    waitbar(0.4,App_Status,'Processing results frame by frame...');

    memoria_fascia_sup_inf = zeros(round(v.FrameRate * v.Duration),size(eco_b,2),2);
    
    %An�lisis por frames
    area_delete = area_delete_b;
    waitbar(0.5,App_Status,'Processing results frame by frame...');
 
    for frame = 1:size(eco_memory,3)
        if frame == locs_1(1)
            area_delete = area_delete_a;
        end
        if frame == locs_1(2)
            area_delete = area_delete_b;
        end
        %Vector con los valores, en pixeles, de los l�mites a medir
        [~,y_InfApo] = findInfAponeurosis((eco_memory(muscle_y+1:end ,:,frame) .* area_delete),centroidsInfApo_b);
        y_InfApo = y_InfApo + muscle_y;
        [~,y_SupApo] = findSupAponeurosis(eco_memory(1:muscle_y,:,frame).* mask_sup,centroidsSupApo_b);

        memoria_fascia_sup_inf(frame,:,1) = y_SupApo;
        memoria_fascia_sup_inf(frame,:,2) = y_InfApo;
    end
    memoria_fascia_sup_inf = memoria_fascia_sup_inf .* param;
 %% Optimizing results   
    waitbar(0.7,App_Status,{'Optimizing results.', 'It may take a few seconds...'});

    %Optimizaci�n en el tiempo
    %Fascia sup
    memoria_fascia_sup_inf(:,:,1) = filloutliers(memoria_fascia_sup_inf(:,:,1),'nearest','quartiles');
    %Fascia inf
    memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,:,2) = filloutliers(memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,:,2),'nearest','quartiles');
    memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,:,2) = filloutliers(memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,:,2),'nearest','quartiles');
    memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,:,2) = filloutliers(memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,:,2),'nearest','quartiles');
    memoria_fascia_sup_inf(after_stimulation_end_frame:end,:,2) = filloutliers(memoria_fascia_sup_inf(after_stimulation_end_frame:end,:,2),'nearest','quartiles');
    
    waitbar(0.8,App_Status,{'Optimizing results.', 'It may take a few seconds...'});
    %Optimizaci�n en el espacio
    for frame = 1:size(memoria_fascia_sup_inf,1)
        memoria_fascia_sup_inf(frame,:,1) = smooth(memoria_fascia_sup_inf(frame,:,1),'moving');
        memoria_fascia_sup_inf(frame,:,2) = smooth(memoria_fascia_sup_inf(frame,:,2),'moving');%0.1,'rloess'
    end
     
    
    memoria_distancia(:,3) = (memoria_fascia_sup_inf(:,muscle_x,2) - memoria_fascia_sup_inf(:,muscle_x,1));
    
    waitbar(1,App_Status,'Finishing...');   
    %% Procesamiento de Resultados
    Results.Name = char(video_name);
    Results.Folder = path_v;
    Results.Duration = v.Duration;
    Results.Frame_rate = v.FrameRate;
    Results.Scale_factor = param;
    Results.Muscle_x_pixel = muscle_x;
    Results.Muscle_longitudinal_middle_point = muscle_x;
    Results.Before_stimulacion_frame = before_f;
    Results.After_stimulation_frame = after_f; 
    Results.AtRest_frames = [1 (before_stimulation_end_frame - 1)]; 
    Results.AtRest_duration_s = (1 / v.FrameRate) * (Results.AtRest_frames(2) - Results.AtRest_frames(1));
    Results.AtRest_mean_mm = mean(memoria_distancia(1:before_stimulation_end_frame - 1,3));
    Results.AtRest_variance_mm2 = std(memoria_distancia(1:before_stimulation_end_frame - 1,3)) ^ 2;
    Results.Rise_frames = [before_stimulation_end_frame (after_stimulation_start_frame - 1)];
    Results.Rise_duration_s = (1 / v.FrameRate) * (Results.Rise_frames(2) - Results.Rise_frames(1));
    Results.UnderStimulation_frames = [after_stimulation_start_frame (after_stimulation_end_frame - 1)];
    Results.UnderStimulation_duration_s = (1 / v.FrameRate) * (Results.UnderStimulation_frames(2) - Results.UnderStimulation_frames(1));
    Results.UnderStimulation_mean_mm = mean(memoria_distancia(after_stimulation_start_frame:after_stimulation_end_frame - 1,3));
    Results.UnderStimulation_variance_mm2 = std(memoria_distancia(after_stimulation_start_frame:after_stimulation_end_frame - 1,3)) ^ 2;    

    close(App_Status)
end 