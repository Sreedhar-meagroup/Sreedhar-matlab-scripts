%% Pre cell

RecChannel_pre = bursts_at_RecSite(NetControlData.Pre_spontaneous.Spikes,[0.2,0.2,3],recSite_in_hwpo);
IBI_rec_ch_pre_h = plt_IBIdist(RecChannel_pre.IBIs,dt,'Rec channel, pre');
Steps = 10.^[-5:.05:1.5];
HistogramISIn(NetControlData.Pre_spontaneous.InAChannel{recSite_in_hwpo},2,Steps);
title('pre');
line([200,200],[10^-5, 10^-1]);
set(gca,'FontSize',12);

% Comment in/out to see these bursts on a raster plot (Might be buggy)

% plt_gfrWithRaster(NetControlData.Pre_spontaneous);
% hold on
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.onsets.idx))','k-');
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.ends.idx))','r-');
% hold off;

%% post spont cell


RecChannel_post = bursts_at_RecSite(NetControlData.Post_spontaneous.Spikes,[0.2,0.2,3],recSite_in_hwpo);
IBI_rec_ch_post_h = plt_IBIdist(RecChannel_post.IBIs,dt,'Rec channel, post');

HistogramISIn(NetControlData.Post_spontaneous.InAChannel{recSite_in_hwpo},2,Steps);
title('post');
line([200,200],[10^-5, 10^-1]);
set(gca,'FontSize',12);

% Comment in/out to see these bursts on a raster plot (Might be buggy)


% plt_gfrWithRaster(NetControlData.Post_spontaneous);
% hold on
% rasterplot_so(pre_spont.Spikes.time(RecChannel_post.burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(RecChannel_pre.burstsInRecCh.onsets.idx))','g-');
% rasterplot_so(pre_spont.Spikes.time(RecChannel_post.burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(RecChannel_pre.burstsInRecCh.ends.idx))','r-');
% hold off;

 %% nSp_diff_cases
 NCa_v2_spikesInResp;

%% Spikes in spont burst pre-post distribution
spon_dist_h = figure();
num = hist(RecChannel_pre.nSpikesperBurst,0:max(RecChannel_pre.nSpikesperBurst));
dist_spon(1) = subplot(2,1,1);
semilogx(0:max(RecChannel_pre.nSpikesperBurst),num/length(RecChannel_pre.nSpikesperBurst),'k-','LineWidth',2);
box off;
title('Pre-session');
grid on;
num = hist(RecChannel_post.nSpikesperBurst,0:max(RecChannel_post.nSpikesperBurst));
dist_spon(1) = subplot(2,1,2);
semilogx(0:max(RecChannel_post.nSpikesperBurst),num/length(RecChannel_post.nSpikesperBurst),'k-','LineWidth',2);
box off;
title('Post-session');
grid on;
[ax1,h1]=suplabel('Response length');
[ax2,h2]=suplabel('probability','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);