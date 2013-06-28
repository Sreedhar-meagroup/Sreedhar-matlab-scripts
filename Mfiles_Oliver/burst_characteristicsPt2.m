%make even more analysis on burst characteristics,
%followingthe calculations in burst_characteristics.m


%how is the ISI distribution different for long vs. short bursts?
%therefore find the indices for long and short bursts respectively and plot
%their ISIs. "long" and " short" has to be defined according to some
%threshold. e.g. "long" is when there are at least x spikes x=45 or so
%for now, threshold for a log burst is set separatly for each channel

long_short_bursting_MEA=[47 45 23 76];
long_short_bursting_hw=cr2hw(long_short_bursting_MEA);
long_short_bursting=long_short_bursting_hw+1  %this is done for referencing in burst_detection, because index 0 doesn't exist
long_thresh=[54 44 28 90];
short_thresh=11;
%a short threshold can be set generally, i.e. everyting smaller than 8 (or
%10 ) spikes


%we have already a vector that stores the isi in burst distribution, namely
%isi_inbursts_distribution{1,i}{k,1}(l) for ch i, burst k, spikenterval l
for i = 1:length(long_short_bursting);
    active_ch=long_short_bursting(i);
    ch_index=find(active_ch==bursting_channels);                         %this is necessary to find the iindex in bursting_channels which is used in isi_inbursts_distribution
    long_burst_indices  = find([burst_detection{1,active_ch}{:,2}] > long_thresh(i));
    short_burst_indices = find([burst_detection{1,active_ch}{:,2}] < short_thresh);
    for j = 1:length(long_burst_indices)
    long_bursts_isi{1,i}{j,1}  = isi_inburst_distribution{1,ch_index}{long_burst_indices(j),1};
    end
    for k= 1:length(short_burst_indices)
    short_bursts_isi{1,i}{k,1}= isi_inburst_distribution{1,ch_index}{short_burst_indices(k),1};
    end
    all_long{1,i}{1}         = cat(1,[],[long_bursts_isi{1,i}{:,1}]);                      %all_long{1,i} saves all the long burstisi for channel i
    long_burst_hist{1,i}  = hist(all_long{1,i}{1},0:0.005:MAX_INTERVAL_LENGTH);
    all_short{1,i}{1}        = cat(1,[],[short_bursts_isi{1,i}{:,1}]);
    short_burst_hist{1,i} = hist(all_short{1,i}{1},0:0.005:MAX_INTERVAL_LENGTH);
    if max([long_burst_hist{1,i}]) > max([short_burst_hist{1,i}])
        max_hist_occurrence(i) = max([long_burst_hist{1,i}]);
    else
        max_hist_occurrence(i) = max([short_burst_hist{1,i}]);
    end
end


l_s_subplot_col=2;
l_s_subplot_row=length(long_short_bursting);
l_s_subfig=figure

for i=1:length(long_short_bursting)
    hsub(1+(i-1)*2)=subplot(l_s_subplot_row, l_s_subplot_col, 1+(i-1)*2)
    bar([0:0.005:(MAX_INTERVAL_LENGTH)].*1000,short_burst_hist{1,i})
    title([' channel ', num2str(long_short_bursting_MEA(i)),' ( < ',num2str(short_thresh),' spikes in burst)'],'Fontsize',12)
    xlabel(['ISI length [ms]'],'FontSize',12);
    ylabel(['occurrences'],'Fontsize',12)
     ylim([0 1.2*max_hist_occurrence(i)]);
    hsub(2*i)=subplot(l_s_subplot_row, l_s_subplot_col,2*i)
     bar([0:0.005:MAX_INTERVAL_LENGTH].*1000,long_burst_hist{1,i})
    title([' channel ', num2str(long_short_bursting_MEA(i)),' ( > ',num2str(long_thresh(i)),' spikes in burst)'],'Fontsize',12)
    xlabel(['ISI length [ms]'],'FontSize',12);
    ylabel(['occurrences'],'Fontsize',12)
    ylim([0 1.2*max_hist_occurrence(i)]);
   
end
title(hsub(1),{['dataset: ',datname,', recording length: ',num2str(recording_length_hrs),', start at ',num2str(starttime_hrs) ' hrs'];['ISI distribution in bursts']; ...
    ['short bursts'];['channel ', num2str(long_short_bursting_MEA(1)),' ( < ',num2str(short_thresh),' spikes in burst)']},'FontSize',12,'Interpreter','none');
title(hsub(2),{['long bursts'];['channel ',num2str(long_short_bursting_MEA(1)),' ( > ',num2str(long_thresh(1)),' spikes)']},'FontSize',12)








%%%%%%%%
%   look how the burst length depends on the Interburst interval, i.e. are
%   there longer bursts after a longer period of silence (long Interburst
%   Interval)

long_short_interburst_MEA=[ 45 24 23  ];
long_short_interburst_hw=cr2hw(long_short_interburst_MEA);
long_short_interburst=long_short_interburst_hw+1  %this is done for referencing in burst_detection, because index 0 doesn't exist
long_interburst_thresh=[50 60 60]
short_interburst_thresh=2;
for i =1:length(long_short_interburst_MEA);
    active_ch=long_short_interburst(i);
    ch_index=find(active_ch==bursting_channels);                         %this is necessary to find the iindex in bursting_channels which is used in isi_inbursts_distribution
    long_interburst_indices  = find([burst_intervals_ch{1,ch_index}{:,1}] > long_interburst_thresh(i));
    short_interburst_indices = find([burst_intervals_ch{1,ch_index}{:,1}] < short_interburst_thresh);
    for j = 1:length(long_interburst_indices)-1
    long_interbursts{1,i}{j,1}  = burst_intervals_ch{1,ch_index}{long_interburst_indices(j),1};
    long_interbursts{1,i}{j,2} = burst_detection{1,active_ch}{long_interburst_indices(j)+1,2};
    end
    for k = 1:length(short_interburst_indices)-1
   short_interbursts{1,i}{k,1}  = burst_intervals_ch{1,ch_index}{short_interburst_indices(k),1};
    short_interbursts{1,i}{k,2} = burst_detection{1,active_ch}{short_interburst_indices(k)+1,2};
    end
    clear long_interburst_indices
    clear short_interburst_indices
     
    all_interburst_long{1,i}{1}         = cat(1,[],[long_interbursts{1,i}{:,2}]);                      %all_long{1,i} saves all the long burstis for channel i
    long_interburst_hist{1,i}  = hist(all_interburst_long{1,i}{1},0:1:max([all_interburst_long{1,i}{1}]));
    all_interburst_short{1,i}{1}        = cat(1,[],[short_interbursts{1,i}{:,2}]);
    short_interburst_hist{1,i} = hist(all_interburst_short{1,i}{1},0:1:max([all_interburst_short{1,i}{1}]));
end

%%%now I can plot in a 2dim way the interburst_interval (x) vs. the length
%%%of teh next burst (y)

l_s_interburst_subplot_row=length(long_short_interburst);
l_s_interburst_subplot_col=2;
interburst_subfig=figure

for i =1:length(long_short_interburst)
    hsub(1+(i-1)*2)=subplot(l_s_interburst_subplot_row, l_s_interburst_subplot_col, 1+(i-1)*2)
    plot([long_interbursts{1,i}{:,1}],[long_interbursts{1,i}{:,2}],'*')
    title([' channel ', num2str(long_short_interburst_MEA(i)),' ( IBI > ',num2str(long_interburst_thresh(i)),' ms)'],'Fontsize',12)
    xlabel(['IBI length [sec]'],'FontSize',12);
    ylabel(['burst length (spikes)'],'Fontsize',12)
    xlim([0 max([long_interbursts{1,i}{:,1}])]);
    hsub(2*i)=subplot(l_s_interburst_subplot_row, l_s_interburst_subplot_col,2*i);
    plot([short_interbursts{1,i}{:,1}],[short_interbursts{1,i}{:,2}],'*')
    title([' channel ', num2str(long_short_interburst_MEA(i)),' ( IBI < ',num2str(short_interburst_thresh),' ms)'],'Fontsize',12)
    xlabel(['IBI length [sec]'],'FontSize',12);
    ylabel(['burst length (spikes)'],'Fontsize',12)
    xlim([0 max([short_interbursts{1,i}{:,1}])]);
   
end
  

interburst_hist=figure

for i =1:length(long_short_interburst)
    hsub(1+(i-1)*2)=subplot(l_s_interburst_subplot_row, l_s_interburst_subplot_col, 1+(i-1)*2)
    bar(0:1:max([all_interburst_long{1,i}{1}]),long_interburst_hist{1,i})
    title([' channel ', num2str(long_short_interburst_MEA(i)),' ( IBI > ',num2str(long_interburst_thresh(i)),' ms)'],'Fontsize',12)
    xlabel(['burst length (spikes)'],'FontSize',12);
    ylabel(['occurrences'],'Fontsize',12)
   
    hsub(2*i)=subplot(l_s_interburst_subplot_row, l_s_interburst_subplot_col,2*i);
   bar(0:1:max([all_interburst_short{1,i}{1}]),short_interburst_hist{1,i})
    title([' channel ', num2str(long_short_interburst_MEA(i)),' ( IBI < ',num2str(short_interburst_thresh),' ms)'],'Fontsize',12)
    xlabel(['burst length (spikes)'],'FontSize',12);
    ylabel(['occurrences'],'Fontsize',12)
   
   
end


title(hsub(1),{['dataset: ',datname,', recording length: ',num2str(recording_length_hrs),', start at ',num2str(starttime_hrs) ' hrs'];['Histogram of burst lengths for bursts with long and short Interburst interval']; ...
    ['long bursts'];['channel ', num2str(long_short_interburst_MEA(1)),' ( > ',num2str(long_interburst_thresh(1)),' spikes in burst)']},'FontSize',12,'Interpreter','none');
title(hsub(2),{['Short bursts'];['channel ',num2str(long_short_interburst_MEA(1)),' ( < ',num2str(short_interburst_thresh),' spikes)']},'FontSize',12)


