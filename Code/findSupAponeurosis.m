function [x_SupApo,y_SupApo] = findSupAponeurosis(eco, centroids)
    K = 2;
    C = eye(K);
    img_size_eco = size(eco);
    idx_eco = findClosestCentroids(eco(:), centroids);
    C_K = C(:,K);
    eco_C = C_K(idx_eco,:);
    eco_C = reshape(eco_C, img_size_eco(1), img_size_eco(2), 1);
    eco_C = imfill(eco_C,'holes');
    eco_C = findLargestArea(eco_C);

    seD = strel('rectangle',[3 3]); 
    eco_C = imerode(eco_C,seD); 
    eco_C = imerode(eco_C,seD);
    eco_C = findLargestArea(eco_C);

%     eco_C_outline = bwperim(eco_C); 
%     Segout_eco = eco;  
%     Segout_eco(eco_C_outline) = 1;  

    [row,col] = find(eco_C);

    col_start = col(1);
    col_end = col(end);
    vector = zeros(col_end - col_start + 1,2);
    index = 0;
    for j = col_start:col_end
        index = index + 1;
        vector(index,:) = [j find(eco_C(:,j),1,'first')];
    end
    x_SupApo = vector(:,1);
    y_SupApo = vector(:,2);
    y_SupApo = smooth(x_SupApo,y_SupApo,0.2,'rloess'); %Use a span of 10% of the total number of data points.
end 