%% to generate figure of NB initiation alone (+sum of cfp) with HW channels (1-60)
% figure(2)
%subplot(1,2,1)
datRoot = {'130311_4198'};
datName = [dat_root{1}, '_spontaneous.spike'];
ls=loadspike(datName,2,25);
burst_detection = burst_detection_all_ch(ls);
[bursting_channels_mea, network_burst, network_burst_onset] = Networkburst_detection(datName,ls,burst_detection,10);
close all
[Delay_hist_fig nr_starts, EL_return] = NB_sequences(datName,network_burst, 0,1,bursting_channels_mea);
%datRoot = {'130311_4105', '130311_4106', '130311_4108', '130312_4096', '130313_4107', '130313_4104'};
for count = 1:size(datRoot,2)
    dat_NBs = [datRoot{count},'_NBStarts.mat'];
    load(dat_NBs);
    bar(EL_array,nr_starts(sort_ind))
    set(gca,'XTick',1:length(sort_ind),'xtickLabel',num2str(active_EL(EL_array((sort_ind)))'+1));
    xlabel(' electrode' )
    ylabel(' Nr. of NB starts' );
    title(['total of ', num2str(nr_NB),' NBs detected'])
    close all, clearvars -except datRoot count
end