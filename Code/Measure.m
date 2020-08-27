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
param = 0.121;%[mm/pixels] - (eco)D5.91cm - Factor de escalamiento
[video_name,path_v] = uigetfile('*.*','Select Video File');
cut_area = [30 25 595 455];%área de análisis [30 25 595 487]
v = VideoReader(strcat(path_v,video_name));
memoria_distancia = zeros(round(v.FrameRate * v.Duration),2);% ->length of memoria_distancia
movimiento = zeros(round(v.FrameRate * v.Duration),2);


%% Detectar movimiento
fprintf('Processing video... \nWait...\n');
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
    memoria_distancia(frame,1) = v.CurrentTime;
end

movimiento(1:10,:) = []; %Se genera un pico dentro del primer frame ya que se detecta un cambio.
[pks,locs] = findpeaks(movimiento(:,2),movimiento(:,1),'SortStr','descend','MinPeakDistance',5);
locs = sort(locs(1:2));     


%Se toma el frame más estático dentro de cada sección
[value_b,before_f] = min(movimiento(1:locs(1),2));
before_f = before_f + 10;
[value_a,after_f] = min(movimiento((locs(1) + 1):(locs(2) - 5),2));
after_f = after_f + 10 + locs(1);

%% Selección de los frames
fprintf('Selecting the best frames... \n');
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
cut_area(4) = muscle_y_max;


%Se realizan dos entrenamientos en dos frames diferentes, se toma el frame
%más estático dentro de la zona sin estimulación y de la zona con
%estimulación.Con esto logramos obtener los centroides de luminancia
%válidos para cada sección


%Before stimulation
v.CurrentTime = memoria_distancia(before_f - 1);
eco_b = readFrame(v);
eco_b = rgb2gray(eco_b);
eco_b = imcrop(eco_b,cut_area);
eco_b = imadjust(eco_b);
eco_b = double(eco_b);
eco_b = eco_b / max(eco_b,[],'all'); % range(0-1)

%After Stimulation
v.CurrentTime = memoria_distancia(after_f - 1);
eco_a = readFrame(v);
eco_a = rgb2gray(eco_a);
eco_a = imcrop(eco_a,cut_area);
eco_a = imadjust(eco_a);
eco_a = double(eco_a);
eco_a = eco_a / max(eco_a,[],'all'); % range(0-1)



%% Training
%Entrenamiento para frames sin estimulación
% Centroides para Aponeurosis Inferior
[centroidsInfApo_b, area_delete_b] = findCentrInfApo(eco_b(muscle_y+1:end,:));

% Centroides para Aponeurosis Superior
centroidsSupApo_b = findCentrSupApo(eco_b(1:muscle_y,:));

%Entrenamiento para frames con estimulación
% Centroides para Aponeurosis Inferior
[centroidsInfApo_a, area_delete_a] = findCentrInfApo(eco_a(muscle_y+1:end,:));
area_delete_a = area_delete_a | area_delete_b; %el area despues de la estimulacion no puede ser mas pequeña por lo que se suman ambas para asegurar que mínimo se tiene el mismo tamaño de área
% Centroides para Aponeurosis Superior
centroidsSupApo_a = findCentrSupApo(eco_a(1:muscle_y,:));


%% Results
%Uso de los centroides del primer frame en todos los frames del video
fprintf('Processing results frame by frame... \nWait... \n');
v.CurrentTime = 0;%Rewind to the beginning

% figure
% set(gcf, 'Position', get(0, 'Screensize'));
frame = 0;

memoria_fascia_sup_inf = zeros(round(v.FrameRate * v.Duration),size(eco_b,2),3);

while hasFrame(v)
    pause(0.001)
    frame = frame + 1;
    eco = readFrame(v);
    eco = imcrop(eco,cut_area);
    eco = rgb2gray(eco);
    eco = imadjust(eco);
    eco = double(eco);
    eco = eco / max(eco,[],'all');
    %Vector con los valores, en pixeles, de los límites a medir
    [x_InfApo,y_InfApo] = findInfAponeurosis((eco(muscle_y+1:end ,:) .* area_delete_b),centroidsInfApo_b);
    y_InfApo = y_InfApo + muscle_y; 
    [x_SupApo,y_SupApo] = findSupAponeurosis(eco(1:muscle_y,:),centroidsSupApo_b);
    %Cálculo de la distancia en [mm] 
    measure_y_inf = y_InfApo(x_InfApo == muscle_x);
    measure_y_sup = y_SupApo(x_SupApo == muscle_x);
    memoria_distancia(frame,2) = (measure_y_inf - measure_y_sup) * param;
    %Escalamineto de los límites de las fascias de pixeles a [mm]
    x_InfApo = param * x_InfApo;
    y_InfApo = param * y_InfApo;
    x_SupApo = param * x_SupApo;
    y_SupApo = param * y_SupApo;
    measure_y_inf = param * measure_y_inf;
    measure_y_sup = param * measure_y_sup;
    
    memoria_fascia_sup_inf(frame,:,1) = y_SupApo;
    memoria_fascia_sup_inf(frame,:,2) = y_InfApo;
%%   ---- eco + plot ----
%     subplot(1, 2, 1)
%         imshow(eco,imref2d(size(eco),param,param))
%         title(sprintf('Frame: %d ', frame))
%         hold on 
%         plot(x_InfApo,y_InfApo,'r--','LineWidth',3) 
%         plot(x_SupApo,y_SupApo,'r--','LineWidth',3) 
%         plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'yo','LineWidth',3)
%         plot([muscle_x muscle_x] * param,[measure_y_inf measure_y_sup],'y-','LineWidth',3)
%         hold off
%         xlabel('[mm]')
%         ylabel('[mm]')
%     
%     subplot(1, 2, 2)
%         plot(medfilt1(memoria_distancia(:,2),4),'LineWidth',2) %medfilt1 quitamos picos 
%         hold on 
%         xline(locs(1),'--','LineWidth',2);
%         xline(locs(2),'--','LineWidth',2);
%         hold off
%         title(strcat('Stimulation Video: ', video_name))
%         xlabel('Frame')
%         ylabel('[mm]')
%         grid minor    
end
memoria_distancia(:,2) = medfilt1(memoria_distancia(:,2),4);


%% MT vs length
fprintf('Results for the best frames \n');
% Before Stimulation
[x_InfApo_b,y_InfApo_b] = findInfAponeurosis((eco_b(muscle_y+1:end ,:) .* area_delete_b),centroidsInfApo_b);
y_InfApo_b = y_InfApo_b + muscle_y; 
[x_SupApo_b,y_SupApo_b] = findSupAponeurosis(eco_b(1:muscle_y,:),centroidsSupApo_b);
%Cálculo de la distancia en [mm] 
muscle_thickness_b = y_InfApo_b - y_SupApo_b;
measure_y_inf_b = y_InfApo_b(x_InfApo_b == muscle_x);
measure_y_sup_b = y_SupApo_b(x_SupApo_b == muscle_x);
%Escalamineto de los límites de las fascias de pixeles a [mm]
muscle_thickness_b = param * muscle_thickness_b;
x_InfApo_b = param * x_InfApo_b;
y_InfApo_b = param * y_InfApo_b;
x_SupApo_b = param * x_SupApo_b;
y_SupApo_b = param * y_SupApo_b;
measure_y_inf_b = param * measure_y_inf_b;
measure_y_sup_b = param * measure_y_sup_b;

% After Stimulation
[x_InfApo_a,y_InfApo_a] = findInfAponeurosis((eco_a(muscle_y+1:end ,:) .* area_delete_a),centroidsInfApo_a);
y_InfApo_a = y_InfApo_a + muscle_y; 
[x_SupApo_a,y_SupApo_a] = findSupAponeurosis(eco_a(1:muscle_y,:),centroidsSupApo_a);
%Cálculo de la distancia en [mm] 
muscle_thickness_a = y_InfApo_a - y_SupApo_a;
measure_y_inf_a = y_InfApo_a(x_InfApo_a == muscle_x);
measure_y_sup_a = y_SupApo_a(x_SupApo_a == muscle_x);
%Escalamineto de los límites de las fascias de pixeles a [mm]
muscle_thickness_a = param * muscle_thickness_a;
x_InfApo_a = param * x_InfApo_a;
y_InfApo_a = param * y_InfApo_a;
x_SupApo_a = param * x_SupApo_a;
y_SupApo_a = param * y_SupApo_a;
measure_y_inf_a = param * measure_y_inf_a;
measure_y_sup_a = param * measure_y_sup_a;
%% Plot Results
%plot before and after stimulation

figure
subplot(1,2,1)
    imshow(eco_b,imref2d(size(eco_b),param,param))
    title(sprintf('Before Stimulation - Frame: %d ', before_f))
    hold on 
    plot(x_InfApo_b,y_InfApo_b,'r--','LineWidth',3) 
    plot(x_SupApo_b,y_SupApo_b,'r--','LineWidth',3) 
    plot([muscle_x muscle_x] * param,[measure_y_inf_b measure_y_sup_b],'yo','LineWidth',3)
    plot([muscle_x muscle_x] * param,[measure_y_inf_b measure_y_sup_b],'y-','LineWidth',3)
    ylabel('[mm]')
    yyaxis right
    plot(x_InfApo,muscle_thickness_b,'LineWidth',3)
    ylabel('Muscle Thickness [mm]')
    xlabel('Longitudinal Axis [mm]')
    hold off
subplot(1,2,2)
    imshow(eco_a,imref2d(size(eco_a),param,param))
    title(sprintf('After Stimulation - Frame: %d ', after_f))
    hold on 
    plot(x_InfApo_a,y_InfApo_a,'r--','LineWidth',3) 
    plot(x_SupApo_a,y_SupApo_a,'r--','LineWidth',3) 
    plot([muscle_x muscle_x] * param,[measure_y_inf_a measure_y_sup_a],'yo','LineWidth',3)
    plot([muscle_x muscle_x] * param,[measure_y_inf_a measure_y_sup_a],'y-','LineWidth',3)
    ylabel('[mm]')
    yyaxis right
    plot(x_InfApo,muscle_thickness_a,'LineWidth',3)
    ylabel('Muscle Thickness [mm]')
    xlabel('Longitudinal Axis [mm]')
    hold off
    
figure
    plot(10:9 + length(memoria_distancia(10:end,2)),memoria_distancia(10:end,2),'LineWidth',2) %medfilt1 quitamos picos 
    hold on 
    xline(locs(1),'--','LineWidth',2);
    xline(locs(2),'--','LineWidth',2);
    hold off
    title(strcat('Stimulation Video: ', video_name))
    xlabel('Frame')
    ylabel('[mm]')
    grid minor    
    
Results.title = video_name;
Results.duration = v.Duration;
Results.before_stimulation_mean = mean(memoria_distancia(10:locs(1),2));
Results.before_stimulation_variance = std(memoria_distancia(10:locs(1),2)) ^ 2;
Results.after_stimulation_mean = mean(memoria_distancia(locs(1):locs(2),2));
Results.after_stimulation_variance = std(memoria_distancia(locs(1):locs(2),2)) ^ 2;
disp(Results)