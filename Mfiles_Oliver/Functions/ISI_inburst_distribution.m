% %function ISI_inburst_distribution;
% 
% 
% %plot a simple ISI distribution for all spikes in bursts, for a given set
% %of electrodes
% 
% % input:
% %
% %datname:                 dataset name
% %
% % burst_detection:       the cell array with all the information about the bursts
% % 
% % 
% % bursting_channels    an array with the specified MEA channels
% % 
% 
% 
% %output:
% % A figure showing the ISI distribution for spikes in bursts, for all the bursts stored in burst_detection,
% %     for all the given channels


function ISI_inburst_distribution(datname,burst_detection,bursting_channels_mea)


bursting_channels      = cr2hw(bursting_channels_mea)+1;
no_bursting_ch         = length(bursting_channels);
no_columns             = ceil(sqrt(no_bursting_ch));
no_rows                =  ceil(no_bursting_ch/no_columns);


%the isi_inburst_distribution{1,j}{k,1}(l) cell holds the isi between spike l+1 and l, for the kth burst on the active channel j 
for j = 1:no_bursting_ch
    active_ch = bursting_channels(j)
    for k = 1:size([burst_detection{1,active_ch}],1) %cycles through all burst in this channel
        for l = 1:length([burst_detection{1,active_ch}{k,3}])-1  %cycles through the spike times
            isi_inburst_distribution{1,j}{k,1}(l) = (burst_detection{1,active_ch}{k,3}(l+1) - burst_detection{1,active_ch}{k,3}(l) );  
        end
    end
end

%first catenate the isis for all bursts for each channel seperately,
%then make a histogram for the different interval lengths
isi_distr_subfig=figure
for j = 1:no_bursting_ch
    active_ch=bursting_channels(j);
    isi_cat=[];
    isi_cat=cat(1,isi_cat,[isi_inburst_distribution{1,j}{:,1}]');
    isi_cat=isi_cat.*1000;                                                   %to obtain msec values
    total_isis(j)=length([isi_inburst_distribution{1,j}{:,:}]);
    n=hist(isi_cat,0:max(isi_cat));
    max_occurrence(j)=max(n);
    hsub(j)=subplot(no_columns, no_rows,j);
    bar(0:max(isi_cat),n);
    xlabel(['ISI length [msec]'],'FontSize',12);
    ylabel(['occurrences'],'Fontsize',12);
    title(['channel ',num2str(hw2cr(active_ch-1))],'FontSize',12);
    xlim([-10 100]);
end
title(hsub(1),{['dataset: ',datname];['InterSpikeInterval length distribution for spikes in bursts']; ...
    ['channel ',num2str(hw2cr(bursting_channels(1)-1))]},'FontSize',12,'Interpreter','none');  

%scale the ylimits according to the number of occured isi
  max_count = max(max_occurrence);
%   
%       for i=1:no_bursting_ch
%           set(hsub(i),'ylim',([0 1.1*max_count]));
%       end


