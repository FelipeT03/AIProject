function LArea = findLargestArea(Area)
%05/08/2020 FT
%find the largest area inside Area
%here we use Image Processing Toolbox 
    CC = bwconncomp(Area, 8);
    S = regionprops(CC, 'Area');
    LArea = bwareaopen(Area,max([S.Area]));
end 