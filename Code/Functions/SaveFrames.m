function SaveFrames(eco_memory,measure_point,video_name,path_frames, scale_factor)
    App_Status = waitbar(0,'Saving...','Name','Wait');
    Waitbar_value = 1/size(eco_memory,3);
    path_images = strcat(path_frames,'/',video_name,'_frames');
    mkdir(path_images);
    str = [num2str(scale_factor) '[mm/px]'];
    triangle_down = [1 1 1 1 1 1 1;...
                     0 1 1 1 1 1 0;...
                     0 0 1 1 1 0 0;...
                     0 0 0 1 0 0 0];
    eco_memory(2:5,measure_point - 3:measure_point + 3,:) = triangle_down + zeros(1,1,size(eco_memory,3));
    for k = 1:size(eco_memory,3)
        RGB = insertText(eco_memory(:,:,k),[0 0],compose(num2str(k)+"\n"+str)); %print frame# and scale on picture
        imwrite(RGB,strcat(path_images,'\',num2str(k),'.jpg'));
        waitbar(k*Waitbar_value,App_Status,'Saving Frames...');
    end 
    waitbar(1,App_Status,'Complete');
    close(App_Status)
end