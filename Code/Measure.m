%% Pruebas con videos
clear
clc

%% Parameters 
K = 5;%3 %try different values
max_iters = 100; 
measure_x = 100;%value of x (coordinate)
measure_y = [];
C = eye(K);
centroids = NaN;
%video_name = '3.mp4';
%path_v = 'C:/Users/ftosc/Documents/Tohoku University/Videos/06.17/';%04.21/'
[video_name,path_v] = uigetfile('*.*','Select Video File');
cut_area = [177 30 283 481];
numberOfK_muscle = 2;

%% Training

v = VideoReader(strcat(path_v,video_name));
memoria_distancia = zeros(round(v.FrameRate * v.Duration),1);% ->length of memoria_distancia

eco = readFrame(v);

eco = rgb2gray(eco);
eco = imcrop(eco,cut_area);
eco = double(eco);
eco = eco / 255; % range(0-1)
img_size_eco = size(eco);

data_eco = eco(:);


while sum(isnan(centroids),'all')
    initial_centroids = kMeansInitCentroids(data_eco, K);
    [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
end
centroids  = sort(centroids,1);

%% Results

v.CurrentTime = 0;%Rewind to the beginning

figure
set(gcf, 'Position', get(0, 'Screensize'));
RI = imref2d(size(eco));
frame = 0;
tic

while hasFrame(v)
    pause(0.001)
    frame = frame + 1;
    eco = readFrame(v);
    
    eco = rgb2gray(eco);
    eco = imcrop(eco,cut_area);
    eco = double(eco);
    eco = eco / 255; % range(0-1)
    img_size_eco = size(eco);
    
    data_eco = eco(:);
    idx_eco = findClosestCentroids(data_eco, centroids);
    
    muscle = findMuscle(idx_eco,C,img_size_eco,numberOfK_muscle); 
    if frame == 1
        centroid_muscle_y = regionprops(logical(sum(muscle,2)),'Centroid');%calculo del centroide en y 
        centroid_muscle_y = cat(1,centroid_muscle_y.Centroid);
        centroid_muscle_y = round(centroid_muscle_y);
    end
    muscle_image = imfill(muscle,'holes'); %Rellena la figura

    [aponeurosis, measure_y] = findAponeurosis(idx_eco,C,img_size_eco,centroid_muscle_y,measure_x,measure_y,frame);
    memoria_distancia(frame) = round(double(measure_y(2)-measure_y(1)));
    aponeurosis_image = imfill(aponeurosis,'holes'); %Rellena la figura
    

    subplot(1, 3, 1);%Eco 
    imshow(eco,RI)
    title(sprintf('Frame: %d ', frame))
    hold on 
    plot([measure_x measure_x],[measure_y(2) measure_y(1)],'r-','LineWidth',3) 
    hold off
    
    subplot(1, 3, 2);%Muscle
    imshow(muscle_image,RI);
    title('Muscle')
    hold on 
    plot(centroid_muscle_y(:,1),centroid_muscle_y(:,2),'b*') 
    hold off
    
    subplot(1, 3, 3);%Aponeurosis
    imshow(aponeurosis_image,RI);
    title(sprintf('Aponeurosis: %d pixels ', memoria_distancia(frame)))
    hold on 
    plot([measure_x measure_x],[measure_y(2) measure_y(1)],'r-','LineWidth',3) 
    hold off 

%     subplot(1, 2, 1)
%     imshow((labeloverlay(eco,aponeurosis_image)),RI); 
%     title(sprintf('Frame: %d ', frame))
%     hold on 
%     plot([measure_x measure_x],[measure_y(2) measure_y(1)],'r-','LineWidth',3) 
%     hold off
%     
%     subplot(1, 2, 2)
%     plot(memoria_distancia,'LineWidth',2)
%     title(strcat('Stimulation Video: ', video_name))
%     %ylim([60 120])
%     xlabel('Frame')
%     ylabel('Pixels')
%     grid minor 
end

memoria_distancia = memoria_distancia * 0.0121; %156 pixels / 2cm
toc
figure
plot(memoria_distancia,'LineWidth',2)
title(strcat('Stimulation Video: ', video_name))
xlabel('Frame')
ylabel('Pixels')
grid minor 
