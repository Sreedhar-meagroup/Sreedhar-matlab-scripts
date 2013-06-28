function createNBSMat(datRoot)
datName = [datRoot,'_spontaneous.spike'];
spikes=loadspike(datName,2,25);
filepath = 'C:\Sreedhar\Mat_work\Closed_loop\NBS_CFP_mats\';
%NBS mat
burst_detection = burstDetAllCh_sk(spikes);
save([filepath,datRoot,'_singleChannelBursts'],'burst_detection');
[bursting_channels_mea, network_burst, network_burst_onset] = Networkburst_detection(datName,spikes,burst_detection,10);
[Delay_hist_fig nr_starts, EL_return] = NB_sequences_sk(datRoot,network_burst, 0,1,bursting_channels_mea);
close all
end
