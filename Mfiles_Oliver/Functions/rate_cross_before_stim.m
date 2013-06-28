
%A function that searches for detected rate crossings that happen after the start of a burst,
% and before a stimulation is applied. This special type of information is necessary to calculate PSTHs alligned on rate crossings
% for spikes swhich are not affected by the stimulation.
%The detected rate crossings are the allignement times 
% 
% 


%input:
%
%thresh_cross:           A cell that holds the times when rate-thresholds
%                        are crossed on each  channel 
%
%stim_times:             The stimulation times of ALL trials
%
%
%
%burst_dur_stim:         A cell that holds information gathered from
%                        find_burst_in_random_stim. It stores the trial nr in which a burst occurs,
%                        the respective stim nr and the burst nr. for that channel
%
%burst_detetction:       The usual cell that holds the info about bursts on
%                        channels
%
%
%channel_vec:            A vector of channels (MEA coord.) for which the
%                        analysis is done




%output:
%
%
%thresh_cross_time:      A cell (for each channel) that holds various information:
%                        Column1: the sequential nr
%                        Column2: The burst start time
%                        Column3: The actual rate crossing time
%                        Column4: The stimulation time
%                        Column5: The difference between column3 and column4 
%                        Column6: The (stimulation) trial nr. in which this all happens




function thresh_cross_time=rate_cross_before_stim(thresh_cross,stim_times,burst_dur_stim, burst_detection,channel_vec);



hw_ch             = cr2hw(channel_vec)+1;
thresh_cross_time = cell(1,length(channel_vec));


for ch_nr=1:length(channel_vec)
    burstnr_in_trial = burst_dur_stim{ch_nr}(:,3);
    stim_nr_in_trial = burst_dur_stim{ch_nr}(:,2);

    burst_cases = length(burstnr_in_trial);

    for ii=1:burst_cases
        burst_start(ii)      = burst_detection{1,hw_ch(ch_nr)}{burstnr_in_trial(ii),3}(1); 
        stim_start(ii)       = stim_times(stim_nr_in_trial(ii));
    end
    

    crossings     = 0;
    for jj=1:burst_cases
        cross_ind = find(thresh_cross{ch_nr} >burst_start(jj) & thresh_cross{ch_nr}<stim_start(jj));
        
        if (~isempty(cross_ind))
            crossings                      = crossings+1;
            thresh_cross_time{ch_nr}(crossings,1) = crossings;   %chronological index
            thresh_cross_time{ch_nr}(crossings,2) = burst_start(jj);  %this is the burst start time
            thresh_cross_time{ch_nr}(crossings,3) = thresh_cross{ch_nr}(cross_ind(1));  %this is the actual rate crossing time
            thresh_cross_time{ch_nr}(crossings,4) = stim_start(jj);       %this  gives the start time of the stim
            thresh_cross_time{ch_nr}(crossings,5) = thresh_cross{ch_nr}(cross_ind(1))-stim_start(jj);  %this gives relative times for plotting ina raster
            thresh_cross_time{ch_nr}(crossings,6) = jj;  %this is the stim trial nr, when there is a burst and a crossing during stim
        end
        
    end
    
    
end
    
    
    
    
    