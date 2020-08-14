function [x_InfApo,y_InfApo] = findInfAponeurosis(eco,centroids)
    K = 2;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroids);
    C_K = C(:,2);
    eco_C = C_K(idx_eco,:);
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    eco_C = imfill(eco_C,'holes');
    eco_C = findLargestArea(eco_C);

    centroid_y = regionprops(logical(sum(eco_C,2)),'Centroid');%calculo del centroide en y 
    centroid_y = cat(1,centroid_y.Centroid);
    centroid_y = round(centroid_y);

    % %% Prueba con corte
    % eco = eco_original(centroid_y(2):end,:);
    % eco = eco / max(eco,[],'all'); % range(0-1)
    % data_eco = eco(:);
    % img_size_eco = size(eco);
    % %data_eco(data_eco < threshold) = [];
    % 
    % 
    % while sum(isnan(centroids),'all')
    %     initial_centroids = kMeansInitCentroids(data_eco, K);
    %     [centroids, idx] = runkMeans(data_eco, initial_centroids, max_iters);
    % end
    % centroids  = sort(centroids,1);
    % 
    % idx_eco = findClosestCentroids(eco(:), centroids);
    % C_K = C(:,2);
    % eco_C = C_K(idx_eco,:);
    % eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    % eco_C = imfill(eco_C,'holes');
    % eco_C = findLargestArea(eco_C);
    % 


    seD = strel('rectangle',[3 3]); 
    eco_C = imerode(eco_C,seD); 
    eco_C = imerode(eco_C,seD);
    eco_C = findLargestArea(eco_C);

    eco_C_outline = bwperim(eco_C); 
    Segout_eco = eco;  
    Segout_eco(eco_C_outline) = 1;  
%     imshow(Segout_eco) 
%     title('Eco')


    [row,col] = find(eco_C);

    col_start = col(1);
    col_end = col(end);
    vector = zeros(col_end - col_start + 1,2);
    index = 0;
    for j = col_start:col_end
    index = index + 1;
    vector(index,:) = [j find(eco_C(:,j),1,'last')];
    end
    x_InfApo = vector(:,1);
    y_InfApo = vector(:,2);
    y_InfApo = smooth(vector(:,1),y_InfApo,0.2,'rloess'); %Use a span of 10% of the total number of data points.
%     hold on
%     plot(x_InfApo,y_InfApo,'r-','LineWidth',2)
%     hold off

end



