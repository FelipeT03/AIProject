function  muscle = findMuscle(idx_eco,Centroids,img_size,numberOfK)
%Find muscle area: idx_eco = centroid value index 
%                  Centroids = centroids values
%                  img_size = size of the muscel image
%                  numberOfK = number of centroids assigned to the muscle 
    muscle = zeros(img_size);
    for j = 1:numberOfK
        C_K = Centroids(:,end-j);
        eco_C = C_K(idx_eco,:);
        eco_C = reshape(eco_C, img_size(1), img_size(2), 1);
        muscle = muscle + findLargestArea(eco_C);
    end 
    muscle = findLargestArea(muscle);

end 