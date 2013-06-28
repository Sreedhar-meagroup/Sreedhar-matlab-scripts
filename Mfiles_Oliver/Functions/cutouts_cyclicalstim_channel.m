% function cutouts_cyclicalstim_channel(datname,ls,cutout_start_times,Stim_channels,nr_cutouts)
%
%In cyclical stim experiments (or others), check to cutouts of the               
% stimulated electrodes, because I want to see if eventually a high
% amplitude at the stimulated site (i.e. close to electrode, close contact)
% could predict that stimulating there could give responses
% 
% define the time periods for cutouts, the channel nr, and use
% the fct artifact_check to plot the cutouts for 
% each stimulated channel
% 
% 
% 
% 
% 
function cutouts_cyclicalstim_channel(datname,ls,cutout_start_times,Stim_channels,nr_cutouts)

nr_ch          = length(Stim_channels);

nr_subplot_row = ceil(sqrt(nr_ch));
nr_subplot_col = ceil(nr_ch/nr_subplot_row); 

cutout_fig = screen_size_fig();
for ii=1:nr_ch
    start_time = cutout_start_times(ii);
    %end_time   = start_time+0.1;
    spike_nr_start = find(ls.time > start_time*3600 & ls.time<(start_time+0.1)*3600);
    spike_nr_start = spike_nr_start(1);
    %read a couple of cutouts, say 80000 spikes
    ls_cutout = loadspike_seq_cutouts(datname,2,25,spike_nr_start,spike_nr_start+80000);
    
    subplot(nr_subplot_row,nr_subplot_col,ii);
    artifact_check(ls_cutout,Stim_channels(ii),nr_cutouts,0)
end