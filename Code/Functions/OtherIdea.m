clc
close all
%load eco_memory
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);
objectFrame = eco_memory(:,:,1);
figure; 
imshow(objectFrame);
objectRegion=round(getPosition(imrect));
points = detectMinEigenFeatures(objectFrame,'ROI',objectRegion);
tracker = vision.PointTracker('MaxBidirectionalError',1);
initialize(tracker,points.Location,objectFrame);
for j = 1:size(eco_memory,3)
      frame = eco_memory(:,:,j);
      [points,validity] = tracker(frame);
      out = insertMarker(frame,points(validity, :),'+');
      videoPlayer(out);
end
release(videoPlayer);