addpath(strcat(pwd,'\Functions'))
[frame_time,eco_memory,memoria_fascia_sup_inf,Results] = Measure();
% pause()
% Scale_factor = Results.Scale_factor;
% 
% Pause_t = 1/Results.Frame_rate;
% figure
% 
% for k = 1:size(memoria_fascia_sup_inf,1)
%     imshow(eco_memory(:,:,k),imref2d(size(eco_memory(:,:,1)),Scale_factor,Scale_factor))
%     hold on
%     plot([1:size(eco_memory(:,:,1),2)] .* Scale_factor, memoria_fascia_sup_inf(k,:,1),'r--','LineWidth',3)
%     plot([1:size(eco_memory(:,:,1),2)] .* Scale_factor, memoria_fascia_sup_inf(k,:,2),'r--','LineWidth',3)
%     hold off
%     pause(Pause_t)
% end
