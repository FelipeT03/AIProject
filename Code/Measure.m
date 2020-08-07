%Pruebas con videos
clear
clc

%% Parameters 
K = 5;%3 %try different values
max_iters = 100; 
measure_x = 100;%value of x (coordinate)
C = eye(K);
centroids = NaN;
memoria_distancia = []; %v.NumberOfFrames ->length of memoria_distancia
video_name = '1.mp4';
path_v = 'C:/Users/ftosc/Documents/Tohoku University/Videos/06.17/';%04.21/'

%% Entrenamiento

v = VideoReader(strcat(path_v,video_name));

eco = readFrame(v);

eco = rgb2gray(eco);
eco = imcrop(eco,[177 30 283 481]);%[177 30 283 481]
eco = double(eco);
eco = eco / 255; % range(0-1)
img_size_eco = size(eco);

data_eco = eco(:);


while sum(isnan(centroids),'all')
    initial_centroids = kMeansInitCentroids(data_eco, K);
    [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
end
centroids  = sort(centroids,1);

%% Resultado

v.CurrentTime = 0;%Rewind to the beginning

figure
set(gcf, 'Position', get(0, 'Screensize'));
RI = imref2d(size(eco));
Frame = 0;


while hasFrame(v)
    pause(0.001)
    Frame = Frame + 1;
    eco = readFrame(v);
    
    eco = rgb2gray(eco);
    eco = imcrop(eco,[177 30 283 481]);
    eco = double(eco);
    eco = eco / 255; % range(0-1)
    img_size_eco = size(eco);
    
    data_eco = eco(:);
    idx_eco = findClosestCentroids(data_eco, centroids);
    
    for j = K-1:K

        C_K = C(:,j);
        eco_C = C_K(idx_eco,:);
        eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
        eco_C_L = findLargestArea(eco_C);
        
        if j == K-1 && Frame == 1
            centroids_muscle = regionprops(logical(sum(eco_C_L,2)),'Centroid');%calculo del centroide en y 
            centroids_muscle = cat(1,centroids_muscle.Centroid);
        elseif j == K
            pmeasure = find(eco_C_L(:,measure_x)==1);
            measure(1) = pmeasure(end);
            apo_inferior = eco_C - eco_C_L;
            apo_inferior = apo_inferior(centroids_muscle(:,2):end,:);
            apo_inferior = findLargestArea(apo_inferior);
            pmeasure = find(apo_inferior(:,measure_x)==1);
            if isempty(pmeasure)
                pmeasure = previous_pmeasure;
                fprintf('No se detecta aponeurosis inferior. Frame: %d \n',Frame)
            end
            previous_pmeasure = pmeasure;
            measure(2) = pmeasure(1) + centroids_muscle(:,2) - 1;
            distancia = round(double(measure(2)-measure(1)));
            memoria_distancia(Frame) = distancia;
            eco_C_L(centroids_muscle(:,2):end,:) = eco_C_L(centroids_muscle(:,2):end,:) + apo_inferior;
        end
        
        eco_C = imfill(eco_C_L,'holes'); %Rellena la figura
        %A_C = imerode(imerode(A_C,strel('diamond',1)),strel('diamond',1));%quita detalles en los bordes
        
        subplot(1, 3, j-2);
        imshow(eco_C,RI);
        if K == j
            title(sprintf('Aponeurosis: %d pixels ', distancia))
            hold on 
            plot([measure_x measure_x],[measure(2) measure(1)],'r-','LineWidth',3) 
            hold off
        else
            hold on 
            plot(centroids_muscle(:,1),centroids_muscle(:,2),'b*') 
            hold off
        end
    end 

    subplot(1, 3, 1);
    imshow(eco,RI); 
    title(sprintf('Frame: %d ', Frame))
    hold on 
    plot([measure_x measure_x],[measure(2) measure(1)],'r-','LineWidth',3) 
    hold off
    

end

figure
plot(memoria_distancia)
title(strcat('Stimulation Video: ', video_name))
xlabel('Frame')
ylabel('Pixels')
grid minor 
