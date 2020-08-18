%% Pruebas con videos
%Lista de Toolbox:
%- Image Processing Toolbox 
%- Curve Fitting Toolbox
%% Limpieza del área de trabajo
clear
clc
close all

%% Parameters 
%K = 5;
%numberOfK_muscle = 2;
threshold = 1/100;%Porcentaje para treshold
%max_iters = 100; %Iteraciones para el entrenamiento
param = 0.121;%Factor de escalamiento
%measure_x = 290;%value of x (coordinate)
%measure_y = [];
%C = eye(K);
%centroids = NaN;
[video_name,path_v] = uigetfile('*.*','Select Video File');
cut_area = [30 25 595 487];%área de análisis
v = VideoReader(strcat(path_v,video_name));
memoria_distancia = zeros(round(v.FrameRate * v.Duration),1);% ->length of memoria_distancia

%% Training
%Se entrena el modelo utilizando el primer frame del video, con esto
%logramos obtener los centroides de luminancia válidos para todo el video

%Frame en escala de grises y con rango de 0 a 1
eco = readFrame(v);
eco = rgb2gray(eco);
eco = imcrop(eco,cut_area);
eco = double(eco);
eco = eco / max(eco,[],'all'); % range(0-1)

%Punto medio en x & y del musculo
[muscle_x, muscle_y] = muscle_x_y(eco);

% Centroides para Aponeurosis Inferior
centroidsInfApo = findCentrInfApo(eco);

% Centroides para Aponeurosis Superior
centroidsSupApo = findCentrSupApo(eco);


%% Results
%Uso de los centroides del primer frame en todos los frames del video

v.CurrentTime = 0;%Rewind to the beginning

figure
set(gcf, 'Position', get(0, 'Screensize'));
RI = imref2d(size(eco),param,param);
frame = 0;


while hasFrame(v)
    pause(0.001)
    frame = frame + 1;
    eco = readFrame(v);
    eco = imcrop(eco,cut_area);
    eco = rgb2gray(eco);
    eco = double(eco);
    eco = eco / max(eco,[],'all');
    %Vector con los valores, en pixeles, de los límites a medir
    [x_InfApo,y_InfApo] = findInfAponeurosis(eco,centroidsInfApo);
    [x_SupApo,y_SupApo] = findSupAponeurosis(eco,centroidsSupApo);
    %Cálculo de la distancia en [mm] 
    memoria_distancia(frame) = (y_InfApo(x_InfApo == muscle_x) - y_SupApo(x_SupApo == muscle_x)) * param;
    %Escalamineto de los límites de las fascias de pixeles a [mm]
    x_InfApo = param * x_InfApo;
    y_InfApo = param * y_InfApo;
    x_SupApo = param * x_SupApo;
    y_SupApo = param * y_SupApo;
%%   ---- eco + plot ----
    subplot(1, 2, 1)
    imshow(eco,RI)
    title(sprintf('Frame: %d ', frame))
    hold on 
    plot(x_InfApo,y_InfApo,'r-','LineWidth',3) 
    plot(x_SupApo,y_SupApo,'y-','LineWidth',3) 

    hold off
    xlabel('[mm]')
    ylabel('[mm]')
    
    subplot(1, 2, 2)
    plot(memoria_distancia,'LineWidth',2)
    title(strcat('Stimulation Video: ', video_name))
    xlabel('Frame')
    ylabel('[mm]')
    grid minor    
end



% memoria_distancia(:,2) = memoria_distancia(:,2); %156 pixels / 2cm
% toc% figure
% plot(memoria_distancia(:,2),'LineWidth',2)
% title(strcat('Stimulation Video: ', video_name))
% xlabel('Frame')
% ylabel('Pixels')
% grid minor 

%% MT vs length
% En esta versión se debe corregir el momento de hacer el plot porque la
% fascia superior esta diseñada para estar en todo x pero al aumentar la
% zona de corte esto ya no es posible. Se debe realizar el mismo
% procedimiento que la fascia inferior que no está en todo x. No se corrige
% en este momento porque se plane cambiar el algoritmo de detección
% primero. 
% [value_min, frame_min] = min(memoria_distancia(:,2));
% [value_max, frame_max] = max(memoria_distancia(:,2));
% 
% if (frame_min-1) > 0
%     v.CurrentTime = memoria_distancia((frame_min-1),1);
% else 
%     v.CurrentTime = 0;
% end
% eco = readFrame(v); 
% eco = imcrop(eco,cut_area);
% eco = rgb2gray(eco);
% eco = double(eco)/ 255;
% data_eco = eco(:);
% idx_eco = findClosestCentroids(data_eco, centroids);
% [SUPERIOR,INFERIOR] = MTvslength(idx_eco,C,img_size_eco,centroid_muscle_y,measure_x,measure_y,frame);
% figure
% plot(INFERIOR(:,1),(INFERIOR(:,2) - SUPERIOR(find(SUPERIOR(:,1) == INFERIOR(1)):INFERIOR(end,1),2)) .* param)
% title('Before')
% grid minor
% 
% v.CurrentTime = memoria_distancia((frame_max-1),1);
% eco = readFrame(v);    
% eco = rgb2gray(eco);
% eco = imcrop(eco,cut_area);
% eco = double(eco)/ 255;
% data_eco = eco(:);
% idx_eco = findClosestCentroids(data_eco, centroids);
% [SUPERIOR,INFERIOR] = MTvslength(idx_eco,C,img_size_eco,centroid_muscle_y,measure_x,measure_y,frame);
% figure
% plot(INFERIOR(:,1),(INFERIOR(:,2) - SUPERIOR(find(SUPERIOR(:,1) == INFERIOR(1)):INFERIOR(end,1),2)) .* param)
% title('After')
% grid minor
% 
% fprintf('%.4f %d \n',value_min, frame_min)
% fprintf('%.4f %d \n',value_max, frame_max)
