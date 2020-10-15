function SaveResults(memoria_fascia_sup_inf, eco_memory, Results, MT_value, video_name,path_save_results)
    App_Status = waitbar(0,'Saving...','Name','Wait');
    path_results = strcat(path_save_results,'/',video_name,'_results');
    waitbar(0.2,App_Status,'Saving Results');  
    mkdir(path_results)
    waitbar(0.3,App_Status,'Saving Results');  
    save(strcat(path_results,'/memoria_fascia_sup_inf.mat'),'memoria_fascia_sup_inf')
    waitbar(0.4,App_Status,'Saving Results');  
    save(strcat(path_results,'/eco_memory.mat'),'eco_memory')
    waitbar(0.6,App_Status,'Saving Results');  
    save(strcat(path_results,'/Results.mat'),'Results')
    waitbar(0.7,App_Status,'Saving Results');  
    thickness = array2table(MT_value,'VariableNames',{'Frame','Second','Millimeters'});
    writetable(thickness,strcat(path_results,'/Thickness.csv'))
    waitbar(0.8,App_Status,'Saving Results');  
    Results_table = struct2table(Results);
    waitbar(0.9,App_Status,'Saving Results');  
    writetable(Results_table,strcat(path_results,'/Summary.csv'))
    waitbar(1,App_Status,'Saving Results');  
    fileID = fopen(strcat(path_results,'/README.txt'),'w');
    fprintf(fileID,'eco_memory.mat: It contains all the frames of the video. It is used by the GUI. \r\n');
    fprintf(fileID,'memoria_fascia_sup_inf.mat: It contains the locations of both fascias in millimeters. \r\n');
    fprintf(fileID,'Results.mat: It contains a summary of the analysis results. If you change parameters in the GUI these values will change. \r\n');
    fprintf(fileID,'Summary.csv: It contains all the information on Results.mat in .csv format. \r\n');
    fprintf(fileID,'Thickness.csv: It contains all the information on the Muscle Thickness plot. \r\n');
    fclose(fileID);
    close(App_Status)
end