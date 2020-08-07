function  muscle = findMuscle(idx_eco,Centroids,img_size)
    C_K = Centroids(:,end-1);
    eco_C = C_K(idx_eco,:);
    eco_C = reshape(eco_C, img_size(1), img_size(2), 1);
    muscle = findLargestArea(eco_C);
end 