%% Pruebas con videos

clear
clc
close all

%% Parameters 
K = 5;%3 %try different values
numberOfK_muscle = 2;
threshold = 1/100;%Porcentaje para treshold
max_iters = 100; 
measure_x = 290;%value of x (coordinate)
measure_y = [];
C = eye(K);
centroids = NaN;
[video_name,path_v] = uigetfile('*.*','Select Video File');
cut_area = [30 25 595 487];
param = 0.121;

%% Training

v = VideoReader(strcat(path_v,video_name));
memoria_distancia = zeros(round(v.FrameRate * v.Duration),1);% ->length of memoria_distancia

eco = readFrame(v);
eco = rgb2gray(eco);
eco = imcrop(eco,cut_area);
eco = double(eco);
eco = eco / max(eco,[],'all'); % range(0-1)

%% Aponeurosis Inferior

centroidsInfApo = findCentrInfApo(eco);

%% Aponeurosis Superior


centroidsSupApo = findCentrSupApo(eco);



%% Results

v.CurrentTime = 0;%Rewind to the beginning

figure
set(gcf, 'Position', get(0, 'Screensize'));
RI = imref2d(size(eco));
frame = 0;


while hasFrame(v)
    pause(0.001)
    frame = frame + 1;
    eco = readFrame(v);
    eco = imcrop(eco,cut_area);
    eco = rgb2gray(eco);
    eco = double(eco);
    eco = eco / max(eco,[],'all');
    
    [x_InfApo,y_InfApo] = findInfAponeurosis(eco,centroidsInfApo);
    [x_SupApo,y_SupApo] = findSupAponeurosis(eco,centroidsSupApo);
    
    memoria_distancia(frame) = (y_InfApo(x_InfApo == measure_x) - y_SupApo(x_SupApo == measure_x))*param;
    
%     data_eco = eco(:);
%     idx_eco = findClosestCentroids(data_eco, centroids);
%     
%     muscle = findMuscle(idx_eco,C,img_size_eco,numberOfK_muscle); 
%     if frame == 1
%         centroid_muscle_y = regionprops(logical(sum(muscle,2)),'Centroid');%calculo del centroide en y 
%         centroid_muscle_y = cat(1,centroid_muscle_y.Centroid);
%         centroid_muscle_y = round(centroid_muscle_y);
%     end
%     muscle_image = imfill(muscle,'holes'); %Rellena la figura
% 
%     [aponeurosis, measure_y] = findAponeurosis(idx_eco,C,img_size_eco,centroid_muscle_y,measure_x,measure_y,frame);
%     memoria_distancia(frame,1) = v.CurrentTime;  
%     memoria_distancia(frame,2) = round(double(measure_y(2)-measure_y(1))) * param;
%     aponeurosis_image = imfill(aponeurosis,'holes'); %Rellena la figura
    

%     subplot(1, 3, 1);%Eco 
%     imshow(eco,RI)
%     title(sprintf('Frame: %d ', frame))
%     
%     subplot(1, 3, 2);%Muscle
%     imshow(muscle_image,RI);
%     title('Muscle')
%     
%     subplot(1, 3, 3);%Aponeurosis
%     imshow(aponeurosis_image,RI);
%     title(sprintf('Aponeurosis: %f [cm] ', memoria_distancia(frame,2))) 
    
%   ---- eco + plot ----
    subplot(1, 2, 1)
    imshow(eco,RI)
    title(sprintf('Frame: %d ', frame))
    hold on 
    plot(x_InfApo,y_InfApo,'r-','LineWidth',3) 
    plot(x_SupApo,y_SupApo,'y-','LineWidth',3) 
    hold off
    
    subplot(1, 2, 2)
    plot(memoria_distancia,'LineWidth',2)
    title(strcat('Stimulation Video: ', video_name))
    %ylim([60 120])
    xlabel('Frame')
    ylabel('[mm]')
    grid minor 
end
%toc
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
