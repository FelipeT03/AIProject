function Scale_Factor = ScaleFactor(ruler)
%Scale_Factor [mm]
    ruler = imcrop(ruler,[17 20 10 size(ruler,2)]);
    ruler = rgb2gray(ruler) > (255/2);
    ruler_y = sum(ruler,2) > 0;
    stats_ruler_y = regionprops(ruler_y,'Centroid');
    ruler_centroids_y = [stats_ruler_y.Centroid];
    ruler_centroids_y = reshape(ruler_centroids_y,[2 length(ruler_centroids_y)/2])';
    ruler_centroids_y(:,1) = [];
    ruler_centroids_y = round(ruler_centroids_y);
    ruler_number = zeros(15,size(ruler,2),length(ruler_centroids_y));
    for j = 1:length(ruler_centroids_y)
        ruler_number(:,:,j) = ruler(ruler_centroids_y(j) - 7:ruler_centroids_y(j) + 7,1:end);
    end
    Scale_Factor = (2 / (ruler_centroids_y(2) - ruler_centroids_y(1))) * 10 ; 
    save('Functions\ruler_number.mat','ruler_number')
end