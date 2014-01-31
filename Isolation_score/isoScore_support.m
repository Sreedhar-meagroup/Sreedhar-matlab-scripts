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

