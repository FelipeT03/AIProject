function LArea = findLargestArea(Area)
%05/08/2020 FT
%Find the largest area inside Area
    CC = bwconncomp(Area, 8);
    S = regionprops(CC, 'Area');
    LArea = bwareaopen(Area,max([S.Area]));
end 