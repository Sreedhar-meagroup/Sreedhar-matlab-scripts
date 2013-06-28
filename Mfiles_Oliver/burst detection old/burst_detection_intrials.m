    
    % burst detection
    %detect bursts in the timewindow prior to stimulation (probably sth like 18
    %seconds, since response itself can be upto 2 seconds) 

    %burst_detection is a nested cell:
    %burst_detection{1,trial_no}{burst_no,burst_information}
    %burst_information consists burst_no, number of spikes in burst and
    %spiketimes

    
channel_mea=[53];   
    
%define time period where to look for bursts 
PRESTIM_BURSTWINDOW=15;
POSTSTIM_BURSTWINDOW=5;

%define a burst
MAX_INTERVAL_LENGTH_1ST=0.050;
MAX_INTERVAL_LENGTH=0.3;
MIN_NO_SPIKES=5;

%find stim times
stim_trigger=find(ls.channel==61);  %not a Schmitt-trigger, I need that to make sure that the detected burst are not the responses
stim_times=ls.time(stim_trigger); 
    
%channel_specifications
channel_hw=cr2hw(channel_mea);

%initialize datavectors
trial_spikes=cell(length(channel_mea),total_trials);
burst_detection=cell(length(channel_mea),total_trials);                      %write the burst information for each trial in this cell

for ch_ind=1:length(channel_hw);
    channel=channel_hw(ch_ind);
     channel_spikes=find(ls.channel==channel);
    channel_spike_times=ls.time(channel_spikes);
    
   
    for i=1:total_trials
        trial_no=trial_vec(i);
        timestamps=find(channel_spike_times > (stim_times(trial_no)-PRESTIM_BURSTWINDOW) & channel_spike_times < (stim_times(trial_no)+POSTSTIM_BURSTWINDOW));
        timestamps=channel_spike_times(timestamps);
        trial_spikes{ch_ind,i}=timestamps;                                  %first of all this are all the spikes in the trial windows
    end;

   
     
    for i=1:total_trials
        trial_no=trial_vec(i);
        current_trial=trial_spikes{ch_ind,i};
        bursts_detected=0;

        if length(current_trial) < MIN_NO_SPIKES                                                                               % if in this trial there are less than MIN_NO_SPIKES we automatically proceed with the next trial 
            continue
        end

        for j=1:length(current_trial)-1                                                                                        %calculate the inter spike intervals
            current_trial_isi(j)=current_trial(j+1)-current_trial(j);
        end



        j=1;
         while j < length(current_trial_isi) - (MIN_NO_SPIKES-2)   
            if( (current_trial_isi(j) < MAX_INTERVAL_LENGTH_1ST) & (current_trial_isi(j+(1:(MIN_NO_SPIKES-2))) < MAX_INTERVAL_LENGTH) & (current_trial(j) < stim_times(i)) );   %the condition for a burst, also I make sure that only burst are detected that start BEFORE the stim

               bursts_detected=bursts_detected+1;

               burst_end = find(current_trial_isi(j:end) > MAX_INTERVAL_LENGTH);                                                  %find al the intervals which are larger than the max_interval allowed and choose the first one that was found as the end of the burst

               if ~isempty(burst_end) 
                   burst_end=burst_end+(j-1);                                                                                       %because we start our index search at j, we have to add at the end to get absolute values for the index 
                   burst_end_isi=current_trial_isi(burst_end(1)-1);                                                                  %i.e. burst_end_isi is tha last isi that still belongs to the burst, burst_end(1) is the index in current_trial_isi that is the first interval after the burst
               else                                                                                                                 %if we are at the end of all spikes, there is no isi anymore that is longer than the max_intervalallowed, so we  take the last isi as the end automatically
                   burst_end=length(current_trial_isi)+1;                                                                            %here I add one because this burst end is the end that still belongs to the burst, in the upper case this is not the case. To make the following code consistent, this is necessary
                   burst_end_isi=current_trial_isi(end);
               end


              isi_in_burst_indices = find(current_trial_isi(j:burst_end(1)-1));
              isi_in_burst_indices = isi_in_burst_indices+(j-1);                                                                  %because we start our index search at j but want to have absolute values of the index, we have to add j at the end again
              burst_length=length(isi_in_burst_indices)+1;                                                                         %plus 1 because we deal with isis but want to have the actual no. of spikes in the burst

              spike_in_burst_indices = [isi_in_burst_indices isi_in_burst_indices(end)+1];                                          %all the indices for the isis and the next one
              spike_in_burst_times(1:burst_length) = current_trial(spike_in_burst_indices);
              burst_detection{ch_ind,i}{bursts_detected,1} = bursts_detected;                                                             %create a nested cell array burst_detection{1,trial_no}{burst_no-in_trial,information}
              burst_detection{ch_ind,i}{bursts_detected,2} = burst_length;
              burst_detection{ch_ind,i}{bursts_detected,3} = spike_in_burst_times;
              j = j + length(isi_in_burst_indices);

            else
                j = j+1;
                continue                                                                                     %continue with the next isi check
            end
            clear isi_in_burst_indices
            clear spike_in_burst_indices
            clear spike_in_burst_times

         end                                                                                                %end the current trial, go on to the next one
          clear current_trial_isi
    end
end                                                                                                         %end the channel cycle
          
          