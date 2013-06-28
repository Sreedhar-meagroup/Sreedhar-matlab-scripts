%
% %analysis of the burst sequence inan burst
% 
% function burst_sequence(datname,network_burst,network_burst_onset,channel_series,period_start,period_end)
% % 
% 
% 
% 
% This function calculated the position of  channels in NBs. I.e. it looks
% when a channel fires in a NB and stores its position nr (e.g. 1,2,3,...).
% In the end, a histogram for each channels is made, showing at which
% position it fires most often
% 
% input:
% datname;                 the file name
% 
% network_burst            the cell array obtained from
%                          Networkburst_detection that stores the NB
%                          information
% 
% network_burst_onset      The vector with all the NB_start times in it
% 
% channel_series           The channels thst should be considered for
%                          analysis
% 
% perid_start, period_end  Start and end time of the first resp. alst NB to
%                          be considered
% 
% 
% 
% 
%function electrode_position = burst_sequence(datname,network_burst,network_burst_onset,channel_series,period_start,period_end)


function electrode_position = burst_sequence(datname,network_burst,network_burst_onset,channel_series,period_start,period_end)

period_start       = period_start*3600;
period_end         = period_end*3600;

nr_channels        = length(channel_series);

%subplot size
nr_subplot_columns = ceil(sqrt(nr_channels));
nr_subplot_rows    = ceil(nr_channels/nr_subplot_columns);
 



%the following are all the NB indices in the respective period of time
NB_burst_nrs=find(network_burst_onset(:,2)>period_start & network_burst_onset(:,2)<period_end);
  
figure;
electrode_position = zeros(length(channel_series),1);
 
for jj=1:length(channel_series)
  
    burst_ch = cr2hw(channel_series(jj))+1;
  
    for ii=1:length(NB_burst_nrs)
        
        %take the burst nr
        burst_nr                 = NB_burst_nrs(ii);
        
        %find the position at which teh current channels pikes in the NB
        spatial_sequence         = network_burst{burst_nr,1};
        electrode_position_in_NB = find(spatial_sequence==burst_ch);
        
        
        if (electrode_position_in_NB)
            electrode_position(jj,ii)=electrode_position_in_NB(1);
        else
            electrode_position(jj,ii)=NaN;
        end
        
        
    end
    
    %in how many NB is this channel participating
    ch_in_NB_nr(jj)   = length(find(~isnan(electrode_position(jj,:))));
    
    %plot the histograms
    hsub(jj)          = subplot(nr_subplot_columns,nr_subplot_rows,jj);
    hist(electrode_position(jj,:),0:nr_channels);
    
    title(['channel ', num2str(channel_series(jj)),', (in ', num2str(ch_in_NB_nr(jj)),' NBs)']);
    ylabel('counts');
    xlabel('position in NB');
     
end
set(hsub(:),'YLim', [0 max(max(hist(electrode_position',0:nr_channels)))]);
subplot(nr_subplot_columns,nr_subplot_rows,1)
title({['datname: ', num2str(datname)];['histogram plots for position in NB for bursts on several channels'];...
       ['channel: ', num2str(channel_series(1)),', ( in ', num2str(ch_in_NB_nr(1)),' NBs)']}, 'Interpreter', 'none')  

subplot(nr_subplot_columns,nr_subplot_rows,2);
title({['taking NB between ', num2str(period_start/3600), ' and ', num2str(period_end/3600),' hrs'];...
       %['taking only those NB that always have ch ', num2str(channel_in_NB_mea),' in it'];...
       ['total nr. of NBs: ', num2str(length(NB_burst_nrs))];...
       ['channel: ', num2str(channel_series(2)),', ( in ', num2str(ch_in_NB_nr(2)),' NBs)']}, 'Interpreter', 'none')
  
  
  
  
  
  
  

