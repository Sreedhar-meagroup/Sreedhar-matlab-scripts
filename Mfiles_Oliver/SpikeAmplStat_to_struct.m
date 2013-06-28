  %create a structure that saves all the information gained from the spike
  %amplitude ananlysis
   
  spike_ampl_stat=struct('datname',{}, 'recording_hrs',{},'recording_periods',{},'timeperiod',{},'no_of_pos_spikes_time',{},' pos_spike_channels' ,{},'pos_ampl_mean',{},'pos_ampl_std',{},'pos_center',{},...
                   'pos_spikes_time_hist',{},'no_of_neg_spikes_time',{},' neg_spike_channels' ,{},'neg_ampl_mean',{},'neg_ampl_std',{},'neg_center',{},...
                   'neg_spikes_time_hist',{});
  load spike_ampl_stat    %the saved mat file should have the same name
  struct_size=size(spike_ampl_stat);
  access_element=struct_size(2)+1;   %for this 1xn dimensional structure, n beingthe entries already there
  
  
               
               
  spike_ampl_stat(access_element).datname = datname;
   spike_ampl_stat(access_element).recording_hrs = recording_hrs;
   spike_ampl_stat(access_element).recording_periods = recording_periods;
    spike_ampl_stat(access_element).timeperiod = timeperiod;
     spike_ampl_stat(access_element).no_of_pos_spikes_time=no_of_pos_spikes_time;
     spike_ampl_stat(access_element).pos_spike_channels = pos_spike_channels;
      spike_ampl_stat(access_element).pos_ampl_mean = pos_ampl_mean;
       spike_ampl_stat(access_element).pos_ampl_std = pos_ampl_std;
        spike_ampl_stat(access_element).pos_center = pos_center;
         spike_ampl_stat(access_element).pos_spikes_time_hist = pos_spikes_time_hist;
          spike_ampl_stat(access_element).no_of_neg_spikes_time = no_of_neg_spikes_time;
          spike_ampl_stat(access_element).neg_spike_channels = neg_spike_channels;
           spike_ampl_stat(access_element).neg_ampl_mean = neg_ampl_mean;
            spike_ampl_stat(access_element).neg_ampl_std = neg_ampl_std;
             spike_ampl_stat(access_element).neg_center = neg_center;
              spike_ampl_stat(access_element).neg_spikes_time_hist = neg_spikes_time_hist;
  
              save spike_ampl_stat spike_ampl_stat