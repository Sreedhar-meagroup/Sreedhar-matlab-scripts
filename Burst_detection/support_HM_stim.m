 stimAnalysis_v3;

rankList = cell(1,nStimSites);
timeList = cell(1,nStimSites);
matWithRanks = cell(1,nStimSites);
matWithTimes = cell(1,nStimSites);

for ii = 1:nStimSites
    matWithRanks{ii} = zeros(60,length(resp_slices{ii}));
    matWithTimes{ii} = zeros(60,length(resp_slices{ii}));
    for jj = 1:length(resp_slices{ii})
        rankList{ii}{jj} =  unique_us(resp_slices{ii}{jj}.channel)+1; % in 1-60 ch
        for kk = 1:size(rankList{ii}{jj},2)
            timeList{ii}{jj}(kk) = resp_slices{ii}{jj}.time(find(resp_slices{ii}{jj}.channel==rankList{ii}{jj}(kk)-1,1,'first'));
        end
        if isempty(kk)
            timeList{ii}{jj} = [];
        else
            timeList{ii}{jj} = timeList{ii}{jj} - timeList{ii}{jj}(1) + 0.01;
        end
        matWithRanks{ii}(rankList{ii}{jj},jj) = 1:length(rankList{ii}{jj});
        matWithTimes{ii}(rankList{ii}{jj},jj) = timeList{ii}{jj};
    end
end



[LCEachResp, ~] = find(matWithRanks{1}==1); % LC stands for leading channel (channel with rank 1 in each burst)
nRepsOfLC = hist(LCEachResp,1:60);
[~,LCsorted] = sort(nRepsOfLC,'descend');

% Responses starting from the leading channels (LCsorted(1)...)
RespsfromHS = matWithRanks{1}(:,LCEachResp == LCsorted(1)); % HS stands for hot-spot; defining LCsorted(1) as the hot-spot

figure(); % cross-correlation matrix of the hotspot initiated bursts
imagesc(corrcov(cov(RespsfromHS)));
colormap(gray);
colorbar; box off; set(gca,'TickDir','Out');

RespsMost2least = []; % this part will arrange the idices of the NBs from hotspots outwards.
for ii = 1:length(LCsorted)
    RespsMost2least = [RespsMost2least,find(matWithRanks{1}(LCsorted(ii),:) == 1)]; 
end

figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
imagesc(corrcov(cov(matWithTimes{1}(:,RespsMost2least))));
colormap(gray);
colorbar;box off; set(gca,'TickDir','Out');
