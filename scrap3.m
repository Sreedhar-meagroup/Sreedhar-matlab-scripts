channelList = NB_slices{1}.channel;
dummy = zeros(10,6);
h=imagesc(dummy);
colormap(gray); colorbar;
set(gca, 'clim', [0 length(channelList)], 'tickdir', 'out');
axis square;
for  ii = 1: length(channelList)
    dummy(find(ch6x10_ch8x8_60 == channelList(ii)+1)) = ii;
    set(h, 'cdata', dummy);
    drawnow; pause(0.5);
end

%%
foc_idx = find((spks.time>99.3 & spks.time< 99.4)&spks.channel == 63);

foc.time = spks.time(foc_idx);
foc.channel = spks.channel(foc_idx);
foc.height = spks.height(foc_idx);
foc.width = spks.width(foc_idx);
foc.context = spks.context(:,foc_idx);
foc.thresh = spks.thresh(foc_idx);
seeContexts(foc_idx,spks);
% cleanspikes(foc);

%% trajectory in space
%131010_4346_StimEfficacy2.spike
h2 = figure();
binSize = 1;
binned = -50:binSize:500;
for jj = 1:50
    coords = zeros(3,length(binned));
    resps = [periStim{5}{[26,58,60]}];
    for ii = 1:3
        shifted_ms = (resps{jj,ii}- stimTimes{5}(jj))*1e3;
        [counts,timeVec] = hist(shifted_ms,binned);
        counts(find(counts)) = 1;
        coords(ii,:) = counts;
    end
    trialsmooth_mod;
end