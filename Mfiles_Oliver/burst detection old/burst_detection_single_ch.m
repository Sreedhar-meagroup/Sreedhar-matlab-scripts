%write a burst detection for a simple data set, either with or without
%stimulation.

%if the data is in secs, convert it to samplesteps, since this is the unit to
%be used her
FREQ_KHZ=25;
ls.time=ls.time.*FREQ_KHZ*1000;
%the conditions for a burst
MAX_INTERVAL_LENGTH_1ST=UNITLENGTH*50;
MAX_INTERVAL_LENGTH=UNITLENGTH*150;
MIN_NO_SPIKES=7;

channel_MEA=[76];
channel=cr2hw(channel_MEA);

channel_spikes_ind=find(ls.channel==channel);
channel_spike_times=ls.time(channel_spikes_ind);
no_spikes=length(channel_spikes_ind);

%calculate the ISIs first
%the ith entry in channel_spike_isi belongs to the interval between the
%spikes i+1 and i
for i =1:no_spikes-1
channel_spike_isi(i)=channel_spike_times(i+1)-channel_spike_times(i);
end;

%HERE COMES the burst detection
bursts_detected=0;
j=1;
while j < no_spikes-(MIN_NO_SPIKES-2)
    if(channel_spike_isi(j) < MAX_INTERVAL_LENGTH_1ST & channel_spike_isi(j+(1:(MIN_NO_SPIKES-2))) < MAX_INTERVAL_LENGTH);   %the condition for a burst
       
           bursts_detected=bursts_detected+1;
           
           burst_end = find(channel_spike_isi(j:end) > MAX_INTERVAL_LENGTH);                                                  %find all the intervals which are larger than the max_interval allowed and choose the first one that was found as the end of the burst
                                                                                                        
           if ~isempty(burst_end) 
               burst_end=burst_end+(j-1);                                                                                       %because we start our index search at j, we have to add at the end to get absolute values for the index 
               burst_end_isi=channel_spike_isi(burst_end(1)-1);                                                                  %i.e. burst_end_isi is tha last isi that still belongs to the burst, burst_end(1) is the index in current_trial_isi that is the first interval after the burst
           else                                                                                                                 %if we are at the end of all spikes, there is no isi anymore that is longer than the max_intervalallowed, so we  take the last isi as the end automatically
               burst_end=length(channel_spike_isi)+1;                                                                            %here I add one because this burst end is the end that still belongs to the burst, in the upper case this is not the case. To make the following code consistent, this is necessary
               burst_end_isi=channel_spike_isi(end);
           end
           
         
          isi_in_burst_indices = find(channel_spike_isi(j:burst_end(1)-1));
          isi_in_burst_indices = isi_in_burst_indices+(j-1);                                                                  %because we start our index search at j but want to have absolute values of the index, we have to add j at the end again
          burst_length=length(isi_in_burst_indices)+1;                                                                         %plus 1 because we deal with isis but want to have the actual no. of spikes in the burst
          
          spike_in_burst_indices = [isi_in_burst_indices isi_in_burst_indices(end)+1];                                          %all the indices for the isis and the next one
          spike_in_burst_times(1:burst_length) = channel_spike_times(spike_in_burst_indices);
          burst_detection{bursts_detected,1} = bursts_detected;                                                             %create a nested cell array burst_detection{1,trial_no}{burst_no-in_trial,information}
          burst_detection{bursts_detected,2} = burst_length;
          burst_detection{bursts_detected,3} = spike_in_burst_times;
          burst_detection{bursts_detected,4} = channel_spikes_ind(spike_in_burst_indices);                                                      %save also the indices in the ls structure for each spike in the burst
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

