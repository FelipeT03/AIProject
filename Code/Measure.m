%Pruebas con videos
clear
clc

%Parameters 
K = 4;%3 %try different values
max_iters = 20; 
%  Load stimulation video
video_name = '1.mp4';%'stimulation video.avi';
path_v = 'C:/Users/ftosc/Documents/Tohoku University/Videos/06.17/'; %04.21/';
v = VideoReader(strcat(path_v,video_name));

A = read(v,1);
frame = imcrop(A,[177 30 283 481]);%[177 30 283 481]
A = double(rgb2gray(frame));
A = A / 255; % range(0-1)
img_size_A = size(A);

X_A = reshape(A, img_size_A(1) * img_size_A(2), 1);

centroids = NaN;

while(length(find(isnan(centroids)))>0)
    initial_centroids = kMeansInitCentroids(X_A, K);
    [centroids, idx] = runkMeans(X_A, initial_centroids, max_iters);
end
centroids  = sort(centroids,1);

% Find closest cluster members
idx_A = findClosestCentroids(X_A, centroids);

C = eye(K);


%Mostrar todos los frames uno a uno utilizando
v = VideoReader(strcat(path_v,video_name));
figure
set(gcf, 'Position', get(0, 'Screensize'));

while hasFrame(v)
    A = readFrame(v);
    frame = imcrop(A,[177 30 283 481]);
    
    A = double(rgb2gray(frame));
    A = A / 255; % range(0-1)
    img_size_A = size(A);
    X_A = reshape(A, img_size_A(1) * img_size_A(2), 1);
    idx_A = findClosestCentroids(X_A, centroids);
    
    subplot(1, K, 1);
    imagesc(frame); 
    
    for j = 2:K
        C_K = C(:,j);
        A_C = C_K(idx_A,:);
        A_C = reshape(A_C, img_size_A(1), img_size_A(2), 1);
        A_C(:,:,2) = A_C(:,:,1);
        A_C(:,:,3) = A_C(:,:,1);
        A_C = bwareaopen(A_C,1000);
        
        subplot(1, K, j);
        imagesc(A_C);
    end 

    pause(0.001)
    
end

