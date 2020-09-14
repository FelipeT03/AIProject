function [eco_memory, memoria_fascia_sup_inf, Results] = Measure()
    %% Pruebas con videos
    %Lista de Toolbox:
    %- Computer Vision System Toolbox 
    %- Image Processing Toolbox 
    %- Curve Fitting Toolbox
    %% Limpieza del área de trabajo
    clear
    clc
    close all

    %% Parameters 
    [video_name,path_v] = uigetfile('*.*','Select Video File');
    %En caso de cancelar la acción el programa se deja de ejecutar 
    if video_name == 0
        return
    end
    cut_area = [30 25 595 455];%área de análisis [30 25 595 487]
    v = VideoReader(strcat(path_v,video_name));
    memoria_distancia = zeros(round(v.FrameRate * v.Duration),2);
    movimiento = zeros(round(v.FrameRate * v.Duration),2);
    param = ScaleFactor(readFrame(v));
    %param = 0.0966;%0.121[mm/pixels] - (eco)D5.91cm - Factor de escalamiento // 0.0966[mm/pixels] - (eco)D4.44cm
    

    %% Detectar movimiento
    App_Status = waitbar(0,'Processing video...','Name','Wait');
    %fprintf('Processing video... \nWait...\n');
    v.CurrentTime = 0;  
    opticFlow = opticalFlowHS;
    frame  = 0;
    while hasFrame(v)
        frame = frame + 1;
        frameRGB = readFrame(v);
        frameGray = rgb2gray(frameRGB);
        flow = estimateFlow(opticFlow,frameGray);
        movimiento(frame,1) = frame;
        movimiento(frame,2) = sum([flow.Magnitude],'all');
        memoria_distancia(frame,1) = frame;
        memoria_distancia(frame,2) = v.CurrentTime;
    end

    movimiento(1:10,:) = []; %Se genera un pico dentro del primer frame ya que se detecta un cambio.
    [pks,locs_1] = findpeaks(movimiento(:,2),movimiento(:,1),'SortStr','descend','MinPeakDistance',5);
    locs_1 = sort(locs_1(1:2));
    [pks,locs_2] = findpeaks(-movimiento(:,2),movimiento(:,1),'SortStr','descend','MinPeakDistance',4);
    locs_2 = [locs_2 ; locs_1];
    locs_2 = sort(locs_2);
    before_stimulation_end_frame = locs_2(find(locs_2 == locs_1(1)) - 1);
    after_stimulation_start_frame = locs_2(find(locs_2 == locs_1(1)) + 1);
    after_stimulation_end_frame = locs_2(find(locs_2 == locs_1(2)) - 1);


    %Se toma el frame más estático dentro de cada sección
    [value_b,before_f] = min(movimiento(1:locs_1(1),2));
    before_f = before_f + 10;
    [value_a,after_f] = min(movimiento((locs_1(1) + 1):(locs_1(2) - 5),2));
    after_f = after_f + 10 + locs_1(1);

    %% Selección de los frames
    waitbar(0.2,App_Status,'Selecting the best frames...');
    %fprintf('Selecting the best frames... \n');
    v.CurrentTime = 0;
    %Frame en escala de grises y con rango de 0 a 1
    eco = readFrame(v);
    eco = rgb2gray(eco);
    eco = imcrop(eco,cut_area);
    eco = imadjust(eco);
    eco = double(eco);
    eco = eco / max(eco,[],'all'); % range(0-1)

    %Punto medio en x & y del musculo
    [muscle_x, muscle_y, muscle_x_min, muscle_x_max, muscle_y_max] = muscle_x_y(eco);
    cut_area(1) = cut_area(1) + muscle_x_min - 1;
    cut_area(3) = muscle_x_max - muscle_x_min - 1;
    %cut_area(4) = muscle_y_max;


    %Se realizan dos entrenamientos en dos frames diferentes, se toma el frame
    %más estático dentro de la zona sin estimulación y de la zona con
    %estimulación. Con esto logramos obtener los centroides de luminancia
    %válidos para cada sección


    %Before stimulation
    v.CurrentTime = memoria_distancia(before_f - 1,2);
    eco_b = readFrame(v);
    eco_b = rgb2gray(eco_b);
    eco_b = imcrop(eco_b,cut_area);
    eco_b = imadjust(eco_b);
    eco_b = double(eco_b);
    eco_b = eco_b / max(eco_b,[],'all'); % range(0-1)

    %After Stimulation
    v.CurrentTime = memoria_distancia(after_f - 1,2);
    eco_a = readFrame(v);
    eco_a = rgb2gray(eco_a);
    eco_a = imcrop(eco_a,cut_area);
    eco_a = imadjust(eco_a);
    eco_a = double(eco_a);
    eco_a = eco_a / max(eco_a,[],'all'); % range(0-1)



    %% Training y cálculo de la máscara
    %Entrenamiento para frames sin estimulación
    % Centroides para Aponeurosis Inferior
    [centroidsInfApo_b, area_delete_b] = findCentrInfApo(eco_b((muscle_y+1):end,:));

    % Centroides para Aponeurosis Superior
    centroidsSupApo_b = findCentrSupApo(eco_b(1:muscle_y,:));

    %Entrenamiento para frames con estimulación
    % Centroides para Aponeurosis Inferior
    [centroidsInfApo_a, area_delete_a] = findCentrInfApo(eco_a((muscle_y+1):end,:));
    area_delete_a = area_delete_a | area_delete_b; %el area despues de la estimulacion no puede ser mas pequeña por lo que se suman ambas para asegurar que mínimo se tiene el mismo tamaño de área
    % Centroides para Aponeurosis Superior
    centroidsSupApo_a = findCentrSupApo(eco_a(1:muscle_y,:));


    %% Results
    %Uso de los centroides del primer frame en todos los frames del video
    waitbar(0.4,App_Status,'Processing results frame by frame...');
    %fprintf('Processing results frame by frame... \nWait... \n');
    v.CurrentTime = 0;%Rewind to the beginning

    frame = 0;

    memoria_fascia_sup_inf = zeros(round(v.FrameRate * v.Duration),size(eco_b,2),2);
    eco_memory = zeros(size(eco_b,1),size(eco_b,2),round(v.FrameRate * v.Duration));
    area_delete = area_delete_b;
    while hasFrame(v)
        pause(0.001)
        frame = frame + 1;
        if frame == locs_1(1)
            area_delete = area_delete_a;
        end
        if frame == locs_1(2)
            area_delete = area_delete_b;
        end
        eco = readFrame(v);
        eco = imcrop(eco,cut_area);
        eco = rgb2gray(eco);
        eco = imadjust(eco);
        eco = double(eco);
        eco = eco / max(eco,[],'all');
        eco_memory(:,:,frame) = eco;
        %Vector con los valores, en pixeles, de los límites a medir
        [x_InfApo,y_InfApo] = findInfAponeurosis((eco(muscle_y+1:end ,:) .* area_delete),centroidsInfApo_b);
        y_InfApo = y_InfApo + muscle_y; 
        [x_SupApo,y_SupApo] = findSupAponeurosis(eco(1:muscle_y,:),centroidsSupApo_b);
        %Cálculo de la distancia en [mm] 
        x_InfApo = param * x_InfApo;
        y_InfApo = param * y_InfApo;
        y_SupApo = param * y_SupApo;

        memoria_fascia_sup_inf(frame,:,1) = y_SupApo;
        memoria_fascia_sup_inf(frame,:,2) = y_InfApo;
    end
    
    
 %% Optimizing results   
    waitbar(0.7,App_Status,{'Optimizing results.', 'It may take a few seconds...'});
    %fprintf('Optimizing results... \nIt may take a few seconds... \n');
    %Optimización en el tiempo
    for x_value_time = 1:size(memoria_fascia_sup_inf,2)
        if x_value_time < before_stimulation_end_frame 
            memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,1),0.1,'rloess');
            memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(1:before_stimulation_end_frame - 1,x_value_time,2),0.3,'rloess');
        elseif x_value_time < after_stimulation_start_frame
            memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,1),0.1,'rloess');
            memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(before_stimulation_end_frame:after_stimulation_start_frame - 1,x_value_time,2),0.3,'rloess');
        elseif x_value_time < after_stimulation_end_frame
            memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,1) = smooth(memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,1),0.1,'rloess');
            memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,2) = smooth(memoria_fascia_sup_inf(after_stimulation_start_frame:after_stimulation_end_frame - 1,x_value_time,2),0.3,'rloess');
        elseif x_value_time >= after_stimulation_end_frame
            memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,1) = smooth(memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,1),0.1,'rloess');
            memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,2) = smooth(memoria_fascia_sup_inf(after_stimulation_end_frame:end,x_value_time,2),0.3,'rloess');
        end
    end
    waitbar(0.8,App_Status,{'Optimizing results.', 'It may take a few seconds...'});
    %Optimización en el espacio
    for frame = 1:size(memoria_fascia_sup_inf,1)
        memoria_fascia_sup_inf(frame,:,1) = smooth(memoria_fascia_sup_inf(frame,:,1),0.1,'rloess');
        memoria_fascia_sup_inf(frame,:,2) = smooth(memoria_fascia_sup_inf(frame,:,2),0.1,'rloess');
    end
    
    
    
    
    memoria_distancia(:,3) = (memoria_fascia_sup_inf(:,muscle_x,2) - memoria_fascia_sup_inf(:,muscle_x,1));
    frame_time = memoria_distancia(:,2);
    
    waitbar(1,App_Status,'Finishing');
    %% MT vs length
    %Cálculo de los valores para los mejores frames
    y_SupApo_b = memoria_fascia_sup_inf(before_f,:,1);
    y_InfApo_b  = memoria_fascia_sup_inf(before_f,:,2);
    muscle_thickness_b = y_InfApo_b - y_SupApo_b;
    
    y_SupApo_a = memoria_fascia_sup_inf(after_f,:,1);
    y_InfApo_a  = memoria_fascia_sup_inf(after_f,:,2);
    muscle_thickness_a = y_InfApo_a - y_SupApo_a;
    %% Plot Results
    close(App_Status)
    
%     MTvsFrame = figure;
%     
%     figure(MTvsFrame)
%     Pause_t = 1/v.FrameRate;
%     set(gcf, 'Position', get(0, 'Screensize'));
%     
%         for frame = 1:size(memoria_fascia_sup_inf,1)
%             subplot(1, 2, 1)
%                 imshow(eco_memory(:,:,frame),imref2d(size(eco_memory(:,:,1)),param,param))
%                 title(sprintf('Frame: %d ', frame))
%                 hold on
%                 plot([muscle_x muscle_x] * param,[memoria_fascia_sup_inf(frame,muscle_x,2) memoria_fascia_sup_inf(frame,muscle_x,1)],'yo','LineWidth',3)
%                 plot([muscle_x muscle_x] * param,[memoria_fascia_sup_inf(frame,muscle_x,2) memoria_fascia_sup_inf(frame,muscle_x,1)],'y-','LineWidth',3)
%                 plot((1:size(eco_memory(:,:,1),2)) .* param, memoria_fascia_sup_inf(frame,:,1),'r--','LineWidth',3)
%                 plot((1:size(eco_memory(:,:,1),2)) .* param, memoria_fascia_sup_inf(frame,:,2),'r--','LineWidth',3)
%                 hold off
%                 xlabel('[mm]')
%                 ylabel('[mm]')
%             
%             subplot(1, 2, 2)
%                 plot(memoria_distancia(1:frame,1),memoria_distancia(1:frame,3),'LineWidth',2) %medfilt1 quitamos picos 
%                 hold on 
%                 xline(before_stimulation_end_frame,'--','LineWidth',2);
%                 xline(after_stimulation_start_frame,'--','LineWidth',2);
%                 xline(after_stimulation_end_frame,'--','LineWidth',2);
% %                 xline(locs_1(1),'--','LineWidth',2);
% %                 xline(locs_1(2),'--','LineWidth',2);
%                 hold off
%                 title(strcat('Stimulation Video: ', video_name))
%                 xlabel('Frame')
%                 ylabel(sprintf('Muscle Thickness [mm] (Longitudinal Axis = %.2f [mm])', muscle_x * param))
%                 grid minor 
% 
%            
%             pause(Pause_t)
%         end

    
    %plot before and after stimulation
    %fprintf('Results for the best frames \n');
    MTvsLength = figure;
    figure(MTvsLength)
    subplot(1,2,1)
        imshow(eco_b,imref2d(size(eco_b),param,param))
        title(sprintf('At Rest - Frame: %d ', before_f))
        hold on 
        plot(x_InfApo,y_InfApo_b,'r--','LineWidth',3) 
        plot(x_InfApo,y_SupApo_b,'r--','LineWidth',3) 
        ylabel('[mm]')
        yyaxis right
        plot(x_InfApo,muscle_thickness_b,'LineWidth',3)
        ylabel('Muscle Thickness [mm]')
        xlabel('Longitudinal Axis [mm]')
        hold off
    subplot(1,2,2)
        imshow(eco_a,imref2d(size(eco_a),param,param))
        title(sprintf('Under Stimulation - Frame: %d ', after_f))
        hold on 
        plot(x_InfApo,y_InfApo_a,'r--','LineWidth',3) 
        plot(x_InfApo,y_SupApo_a,'r--','LineWidth',3) 
        ylabel('[mm]')
        yyaxis right
        plot(x_InfApo,muscle_thickness_a,'LineWidth',3)
        ylabel('Muscle Thickness [mm]')
        xlabel('Longitudinal Axis [mm]')
        hold off

   
    %% Procesamiento de Resultados
    %fprintf('Saving results \n');
    thickness = array2table(memoria_distancia,'VariableNames',{'Frame','Second','Millimeters'});

    Results.Name = video_name;
    Results.Duration = v.Duration;
    Results.Frame_rate = v.FrameRate;
    Results.Scale_factor = param;
    Results.Muscle_x_pixel = muscle_x;
    Results.Before_stimulacion_frame = before_f;
    Results.After_stimulation_frame = after_f; %añadir unidades 
    Results.Motion_frame_detection_1 = locs_1(1); 
    Results.Motion_frame_detection_2 = locs_1(2);
    Results.Before_stimulation_mean_mm = mean(memoria_distancia(1:before_stimulation_end_frame - 1,3));
    Results.Before_stimulation_variance_mm2 = std(memoria_distancia(1:before_stimulation_end_frame - 1,3)) ^ 2;
    Results.After_stimulation_mean_mm = mean(memoria_distancia(after_stimulation_start_frame:after_stimulation_end_frame - 1,3));
    Results.After_stimulation_variance_mm2 = std(memoria_distancia(after_stimulation_start_frame:after_stimulation_end_frame - 1,3)) ^ 2;    
    %% Mostrar y guardar los resultados    
    %Mostrando Resultados
    %disp(Results)

    %Guardando Resultados
    mkdir(strcat(video_name,'_results'))
    save(strcat(video_name,'_results/','memoria_fascia_sup_inf.mat'),'memoria_fascia_sup_inf')
    save(strcat(video_name,'_results/','frame_time.mat'),'frame_time')
    save(strcat(video_name,'_results/','eco_memory.mat'),'eco_memory')
    save(strcat(video_name,'_results/','Results.mat'),'Results')
    writetable(thickness,strcat(video_name,'_results/','Thickness.csv'))
    Results_table = struct2table(Results);
    writetable(Results_table,strcat(video_name,'_results/','Summary.csv'))
    %Imágenes
%     saveas(MTvsFrame,strcat(video_name,'_results/','MTvsFrame.png'))
    saveas(MTvsLength,strcat(video_name,'_results/','MTvsLength.png'))
end 