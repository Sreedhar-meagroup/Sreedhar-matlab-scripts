%21_11_06
%burst detection for a simple data set, either with or without
%stimulation.
%do this for several channel at once
%the burst information is stored in a cell
%burst_detection{1,i}{burst_no,burst_information}
%where:
% i: channel number (hw) (note: this is hw_channel+1, since hw_channel starts with 0)
%
% burst_no: kind of obsolete, but cycles from the first throughthe last
% burst onthis electrode, used to have different entries for each burst
%
%burst_information: currently there are four entries: 1)burst_no, 2)length
%of burst, 3)spiketimes of the spikes in the burst, 4) indices in ls of the
%involved spikes

MAX_INTERVAL_LENGTH_1ST=0.05;                                                         %length of first interval
MAX_INTERVAL_LENGTH=0.15;
MIN_NO_SPIKES=3;                                                                               %min no of spikes in a burst that must be there



burst_detection=cell(1,61);
for channel=32%0:60;
    channel
    channel_spikes_ind=find(ls.channel==channel);
    channel_spike_times=ls.time(channel_spikes_ind);
    no_spikes=length(channel_spikes_ind);
    %calculate the ISIs first
    %the ith entry in channel_spike_isi belongs to the interval between the
    %spikes i+1 and i
    channel_spike_isi=zeros(1,no_spikes-1);
    channel_spike_isi= diff(channel_spike_times);
    
    %HERE COMES the burst detection
    bursts_detected=0;
    j=1;
    while j < no_spikes-(MIN_NO_SPIKES-2)
        if(channel_spike_isi(j) < MAX_INTERVAL_LENGTH_1ST & channel_spike_isi(j+(1:(MIN_NO_SPIKES-2))) < MAX_INTERVAL_LENGTH);   %the condition for a burst
       
           bursts_detected=bursts_detected+1;
           
           burst_end = find(channel_spike_isi(j:end) > MAX_INTERVAL_LENGTH);                                                  %find all the intervals which are larger than the max_interval allowed and choose the first one that was found as the end of the burst
                                                                                                        
           if ~isempty(burst_end) 
               burst_end=burst_end+(j-1);                                                                                       %because we start our index search at j, we have to add at the end to get absolute values for the index 
               burst_end_isi=channel_spike_isi(burst_end(1)-1);                                                                  %i.e. burst_end_isi is the last isi that still belongs to the burst, burst_end(1) is the index in current_trial_isi that is the first interval after the burst
           else                                                                                                                 %if we are at the end of all spikes, there is no isi anymore that is longer than the max_intervalallowed, so we  take the last isi as the end automatically
               burst_end=length(channel_spike_isi)+1;                                                                            %here I add one because this burst end is the end that still belongs to the burst, in the upper case this is not the case. To make the following code consistent, this is necessary
               burst_end_isi=channel_spike_isi(end);
           end
           
         
          isi_in_burst_indices = find(channel_spike_isi(j:burst_end(1)-1));
          isi_in_burst_indices = isi_in_burst_indices+(j-1);                                                                  %because we start our index search at j but want to have absolute values of the index, we have to add j at the end again
          burst_length=length(isi_in_burst_indices)+1;                                                                         %plus 1 because we deal with isis but want to have the actual no. of spikes in the burst
          
          spike_in_burst_indices = [isi_in_burst_indices isi_in_burst_indices(end)+1];                                          %all the indices for the isis and the next one
          spike_in_burst_times(1:burst_length) = channel_spike_times(spike_in_burst_indices);
          burst_detection{1,channel+1}{bursts_detected,1} = bursts_detected;                                                             %create a nested cell array burst_detection{1,trial_no}{burst_no-in_trial,information}
          burst_detection{1,channel+1}{bursts_detected,2} = burst_length;
          burst_detection{1,channel+1}{bursts_detected,3} = spike_in_burst_times;
          burst_detection{1,channel+1}{bursts_detected,4} = channel_spikes_ind(spike_in_burst_indices);                                                      %save also the indices in the ls structure for each spike in the burst
          j = j + length(isi_in_burst_indices);
          
        else
            j = j+1;
            continue                                                                                     %continue with the next isi check
        end
        clear isi_in_burst_indices
        clear spike_in_burst_indices
        clear spike_in_burst_times
       
     end                                                                                                %end the current trial, go on to the next one
      clear channel_spike_isi
      clear channel_spikes_ind
      clear channel_spike_times
      
      %be sure that even if no burst was detected, there is a cell for
      %that channel (that is empty, however)
      if ~bursts_detected
          burst_detection{1,channel+1}=[];
      end
end;%end for all the channels


