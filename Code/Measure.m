%% Pruebas con videos
%Lista de Toolbox:
%- Image Processing Toolbox 
%- Curve Fitting Toolbox
%% Limpieza del �rea de trabajo
clear
clc
close all

%% Parameters 
param = 0.121;%Factor de escalamiento
[video_name,path_v] = uigetfile('*.*','Select Video File');
cut_area = [30 25 595 487];%�rea de an�lisis
v = VideoReader(strcat(path_v,video_name));
memoria_distancia = zeros(round(v.FrameRate * v.Duration),1);% ->length of memoria_distancia
movimiento = zeros(round(v.FrameRate * v.Duration),2);

%% Training
%Se entrena el modelo utilizando el primer frame del video, con esto
%logramos obtener los centroides de luminancia v�lidos para todo el video

%Frame en escala de grises y con rango de 0 a 1
eco = readFrame(v);
eco = rgb2gray(eco);
eco = imcrop(eco,cut_area);
eco = double(eco);
eco = eco / max(eco,[],'all'); % range(0-1)

%Punto medio en x & y del musculo
[muscle_x, muscle_y, muscle_x_min, muscle_x_max] = muscle_x_y(eco);
imshow(eco)
prompt = 'Punto m�s alto de fascia inferior ';
x = input(prompt);
ajuste = round((x- muscle_y) * 0.9);

% Centroides para Aponeurosis Inferior
centroidsInfApo = findCentrInfApo(eco(muscle_y+1:end,:));

% Centroides para Aponeurosis Superior
centroidsSupApo = findCentrSupApo(eco(1:muscle_y,:));
%% Detectar movimiento
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
end
movimiento(1:10,:) = [];
[pks,locs] = findpeaks(movimiento(:,2),movimiento(:,1),'SortStr','descend');

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
    %Vector con los valores, en pixeles, de los l�mites a medir
    [x_InfApo,y_InfApo] = findInfAponeurosis(eco(muscle_y+1:end ,:),centroidsInfApo,ajuste,muscle_x_min, muscle_x_max);
    y_InfApo = y_InfApo + muscle_y; 
    [x_SupApo,y_SupApo] = findSupAponeurosis(eco(1:muscle_y,:),centroidsSupApo);
    %C�lculo de la distancia en [mm] 
    measure_y_inf = y_InfApo(x_InfApo == muscle_x);
    measure_y_sup = y_SupApo(x_SupApo == muscle_x);
    memoria_distancia(frame) = (measure_y_inf - measure_y_sup) * param;
    %Escalamineto de los l�mites de las fascias de pixeles a [mm]
    x_InfApo = param * x_InfApo;
    y_InfApo = param * y_InfApo;
    x_SupApo = param * x_SupApo;
    y_SupApo = param * y_SupApo;
    measure_y_inf = param * measure_y_inf;
    measure_y_sup = param * measure_y_sup;
%%   ---- eco + plot ----
    subplot(1, 2, 1)
    imshow(eco,RI)
    title(sprintf('Frame: %d ', frame))
    hold on 
    plot(x_InfApo,y_InfApo,'r--','LineWidth',3) 
    plot(x_SupApo,y_SupApo,'r--','LineWidth',3) 
    plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'yo','LineWidth',3)
    plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'y-','LineWidth',3)
    hold off
    xlabel('[mm]')
    ylabel('[mm]')
    
    subplot(1, 2, 2)
    plot(memoria_distancia,'LineWidth',2)
    hold on 
    xline(locs(1),'--','LineWidth',2);
    xline(locs(2),'--','LineWidth',2);
    hold off
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
% En esta versi�n se debe corregir el momento de hacer el plot porque la
% fascia superior esta dise�ada para estar en todo x pero al aumentar la
% zona de corte esto ya no es posible. Se debe realizar el mismo
% procedimiento que la fascia inferior que no est� en todo x. No se corrige
% en este momento porque se plane cambiar el algoritmo de detecci�n
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
