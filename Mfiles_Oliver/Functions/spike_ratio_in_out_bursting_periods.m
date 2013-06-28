%function  ratio_spikes = spike_ratio_in_out_bursting_periods(datname,ls,burst_detection,network_burst,CHANNELS,time_start,time_end)
% 
%This function calculates the ratio of spikes inside and outside bursting
%periods, i.e looking at the on- and off times of NBs and calculating the
%nr. of spikes from each channel, comparing this with the totak nr. of
%spikes gives an estimate how many spikes from a particular electrode
%fall outside NB periods. Of course this ratio is usually very high,
%however an deviation from 1 might indicate a unit that is active during
%period soutside NBs and therfore might play an important role as seen e.g.
%in dataset 21_09_07_764, where a stimulation on such a unit stopped
%superbursts
% 
% input:
% 
% 
% 
% 
% 
% 
% 
%
function ratio_spikes = spike_ratio_in_out_bursting_periods(datname,ls,burst_detection,network_burst,CHANNELS,time_start,time_end)


nr_ch = length(CHANNELS);
hw_ch = cr2hw(CHANNELS);

nr_NB = size(network_burst,1);
for jj=1:nr_NB
     NB_on_off_times(jj,1)  = network_burst{jj,2}(1);
     NB_on_off_times(jj,2)  = max([network_burst{jj,5}]);
end



for ii=1:nr_ch
    %burst_spikes           = find([burst_detection{1,hw_ch(ii)+1}{:,3}]> time_start*3600 & [burst_detection{1,hw_ch(ii)+1}{:,3}]<time_end*3600);
    total_spikes_bursting_periods = 0;
    ch_spikes = ls.time(find(ls.channel==hw_ch(ii) & ls.time>time_start*3600 &ls.time<time_end*3600));
    
    %cycle through each NB and check if the current electrode has spikes
    %there
    for jj=1:nr_NB
        burst_spikes_temp             = length(find(ch_spikes >NB_on_off_times(jj,1) & ch_spikes < NB_on_off_times(jj,2)));
        total_spikes_bursting_periods = total_spikes_bursting_periods + burst_spikes_temp;
    end
    
    %nr_spikes_in_burst(ii) = length(burst_spikes);
    nr_spikes_in_burst(ii) = total_spikes_bursting_periods;
    
    nr_spikes_all(ii)      = length(ch_spikes);
    
    ratio_spikes(ii,1)     = nr_spikes_in_burst(ii)/nr_spikes_all(ii);
    ratio_spikes(ii,2)     = nr_spikes_in_burst(ii);
    ratio_spikes(ii,3)     = nr_spikes_all(ii);
    ratio_spikes(ii,4)     = hw_ch(ii);
    %the MEA electrode nr
    ratio_spikes(ii,5)     = CHANNELS(ii);
end


[ch_sort sort_ind] = sort(ratio_spikes(:,5),'ascend');
ratio_spikes(:,1:4)  = ratio_spikes(sort_ind,1:4);

ratio_spikes(:,5)  = ch_sort;

ratio_spikes_fig = screen_size_fig();
text_label       = strcat(num2str(ratio_spikes(:,2)),'/',num2str(ratio_spikes(:,3)));
bar(ratio_spikes(:,5),ratio_spikes(:,1));
text(ratio_spikes(:,end),ratio_spikes(:,1)+0.1,text_label);
xlabel('MEA electrode');
ylabel('ratio of spikes in burst/all spikes');
ylim([0 1.5]);
title({['datname: ', datname];['From hr ', num2str(time_start),' to ', num2str(time_end), ' of recording'];...
    ['Calculating the ratio spikes during NB periods vs. all spikes, shown are the resp. numbers']},'interpreter', 'none');
