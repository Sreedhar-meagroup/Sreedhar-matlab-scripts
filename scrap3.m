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
%131010_4346_StimEfficacy2.spike (26, 58, 60)
%130625_4205_StimEfficacy.spike (13, 25, 17), st:3
%131011_4350_stimEfficacy1 (36, 45, 48), st: 5
summed_effect = cell(5,1);
count = 1;
stimNo = 3;
for kk =  [10 15 20 25]; %
    h2 = figure();
    binSize = kk;
    binned = -50:binSize:500;
    c = colorGradient([0 0 0], [1 0 0],50);
    for jj = 1:50
        coords = zeros(3,length(binned));
        resps = [periStim{stimNo}{[13, 25, 17]}];
        for ii = 1:3
            shifted_ms = (resps{jj,ii}- stimTimes{stimNo}(jj))*1e3;
            [counts,timeVec] = hist(shifted_ms,binned);
%              counts(find(counts)) = 1; % counts could be anything
            coords(ii,:) = counts;
        end
        trialsmooth_mod;
        summed_effect{count}(:,:,jj) = sy;
    end
    count = count + 1;
    set(gca,'FontSize',14);
    title(['Trajectories with bin-size = ', num2str(kk),'ms'], 'FontSize',14);
     saveas(h2,['C:\Users\duarte\Desktop\fig_traj\130625_4205\trajFWHM8_',num2str(kk),'ms.eps'], 'psc2');
     close(h2);
end

%% Isolation score
% without offset correction
nSelSpikes = size(selIdx,2);
nRejSpikes = size(rejIdx,2);
k = 1000;
shuffle = randperm(nSelSpikes);
spikeCluster = spikes.context(:,selIdx(shuffle(1:k)))';
spikeCluster_oc = spikes_oc.context(:,selIdx(shuffle(1:k)))';
shuffle = randperm(nRejSpikes);
noiseCluster = spikes.context(:,rejIdx(shuffle(1:k)))';
noiseCluster_oc = spikes_oc.context(:,rejIdx(shuffle(1:k)))';
[score, errorResults] = isolationScore(spikeCluster, noiseCluster)
[score_oc, errorResults_oc] = isolationScore(spikeCluster_oc, noiseCluster_oc)
% with offset correction


newSel = find(mean(spks.context(50:51,:)) <= mean(mean(spks.context(50:51,:))));
nNewSel = size(newSel,2);
shuffle = randperm(nNewSel);
spikeCluster_big = spks.context(:,newSel(shuffle(1:k)))';
[score_big, errorResults_big] = isolationScore(spikeCluster_big, noiseCluster_oc)

