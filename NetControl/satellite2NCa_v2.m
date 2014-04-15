% Satellite to NetControl Analysis v2
recSite_in_hwpo = cr2hw(recSite) + 1;
spks_recSite_pre  = pre_spont.InAChannel{recSite_in_hwpo};
spks_recSite_post = post_spont.InAChannel{recSite_in_hwpo};

%% Pre cell

% 1-ch Burst detection (200 ms ISI with 3 spikes)
burst_recSite = burstDetAllCh_sk(pre_spont.Spikes,0.2,0.2,3);

burstsInRecCh.onsets.time = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.onsets.idx  = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.ends.time  = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.ends.idx   = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.indices = [];
for ii = 1:length(burst_recSite{recSite_in_hwpo})
    burstsInRecCh.onsets.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(1);
    burstsInRecCh.ends.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(end);

    burstsInRecCh.onsets.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(1);
    burstsInRecCh.ends.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(end);
    
    burstsInRecCh.indices = [burstsInRecCh.indices; burst_recSite{recSite_in_hwpo}{ii,4}(:)];
end

% No: of spikes per NB
allLengths = cellfun(@length, burst_recSite{recSite_in_hwpo});
nSpikesperBurst_pre = allLengths(:,3);

% Single channel IBI plot
IBI_RecCh = zeros(size(burstsInRecCh.onsets));
IBI_RecCh(1) = burstsInRecCh.onsets(1);
IBI_RecCh(2:end) = burstsInRecCh.onsets(2:end) - burstsInRecCh.ends(1:end-1);

timeVec = 0:0.5:max(IBI_RecCh);
counts = histc(IBI_RecCh,timeVec);

figure();
bar_h = bar(timeVec,counts/length(IBI_RecCh),'histc');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
set(gca, 'FontSize', 16)
ylabel('probability')
xlabel('IBI in recording channel [s]')

% Single channel ISI plot
Steps = 10.^[-5:.05:1.5];
HistogramISIn(pre_spont.InAChannel{recSite_in_hwpo},2,Steps);

% Adding to the spont raster plot
plt_gfrWithRaster(pre_spont);
hold on
rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.onsets.idx))','k-');
rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.ends.idx))','r-');
hold off;

%% post spont cell

% 1-ch Burst detection (200 ms ISI with 3 spikes)
burst_recSite = burstDetAllCh_sk(post_spont.Spikes,0.2,0.2,3);

burstsInRecCh.onsets.time = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.onsets.idx  = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.ends.time  = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.ends.idx   = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.indices = [];
for ii = 1:length(burst_recSite{recSite_in_hwpo})
    burstsInRecCh.onsets.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(1);
    burstsInRecCh.ends.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(end);

    burstsInRecCh.onsets.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(1);
    burstsInRecCh.ends.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(end);
    
    burstsInRecCh.indices = [burstsInRecCh.indices; burst_recSite{recSite_in_hwpo}{ii,4}(:)];
end

% No: of spikes per NB
allLengths = cellfun(@length, burst_recSite{recSite_in_hwpo});
nSpikesperBurst_pre = allLengths(:,3);

% Single channel IBI plot
IBI_RecCh = zeros(size(burstsInRecCh.onsets));
IBI_RecCh(1) = burstsInRecCh.onsets(1);
IBI_RecCh(2:end) = burstsInRecCh.onsets(2:end) - burstsInRecCh.ends(1:end-1);

timeVec = 0:0.5:max(IBI_RecCh);
counts = histc(IBI_RecCh,timeVec);

figure();
bar_h = bar(timeVec,counts/length(IBI_RecCh),'histc');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
set(gca, 'FontSize', 16)
ylabel('probability')
xlabel('IBI in recording channel [s]')

% Single channel ISI plot
Steps = 10.^[-5:.05:1.5];
HistogramISIn(pre_spont.InAChannel{recSite_in_hwpo},2,Steps);

% Adding to the spont raster plot
plt_gfrWithRaster(pre_spont);
hold on
rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.onsets.idx))','k-');
rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.ends.idx))','r-');
hold off;