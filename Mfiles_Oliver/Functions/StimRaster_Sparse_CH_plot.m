%Metafunction that plot stimraster for specified channels.
%Several channels can be given, handles to subplots are returned
%Used with the new Stimraster function that stores sparse matrices




function [sub_h] = StimRaster_Sparse_CH_plot(StimRaster_Sparse,Nr_spikes,ELECTRODES)

Nr_channels = length(ELECTRODES);
HW_channels = cr2hw(ELECTRODES);
TRIALS      = size(Nr_spikes,2);

subplot_r = Nr_channels;
subplot_c = 1;


StimRaster_CH_plot = screen_size_fig();


for ii=1:Nr_channels
    
    sub_h(ii)  = subplot(subplot_r,subplot_c,ii)
    
    for jj=1:TRIALS
            spikes_full = full(StimRaster_Sparse{HW_channels(ii)+1}(:,jj));
            %plotted are of course only he corresp. entries nonzero
            if find(spikes_full)
                plot(spikes_full(find(spikes_full)),jj*ones(1,Nr_spikes(HW_channels(ii)+1,jj)),'ok','MarkerSize',2, 'MarkerFacecolor','k','MarkerEdgecolor','k');
            end
            %if there are no spikes in this trial, just don't plot
            hold on;
    end;
    title(['electrode ',num2str(ELECTRODES(ii))],'FontSize',16);
    ylabel('trial','FontSize',20);

end
%the last plot gets a xlabel
xlabel('post stimulus time [sec]','FontSize',20);
set(sub_h,'FontSize',14)    
    