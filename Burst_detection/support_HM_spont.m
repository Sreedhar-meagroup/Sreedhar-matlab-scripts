% run spontaneousData prior to running this file
% spontaneousData;
NB_widths = NB_ends - mod_NB_onsets;
rankList = cell(length(NB_slices),1);
timeList = cell(length(NB_slices),1);
matWithRanks = zeros(60,length(NB_slices));
matWithTimes = zeros(60,length(NB_slices));%+ 1+max(NB_widths);


for ii = 1:length(NB_slices)
    rankList{ii} = unique_us(NB_slices{ii}.channel)+1; % in 1-60 ch
    for jj = 1:size(rankList{ii},2)
        timeList{ii}(jj) = NB_slices{ii}.time(find(NB_slices{ii}.channel==rankList{ii}(jj)-1,1,'first'));
    end
    timeList{ii} = timeList{ii} - timeList{ii}(1); %correcting the time w.r.t to the first spike
    matWithRanks(rankList{ii},ii) = 1:length(rankList{ii});
    matWithTimes(rankList{ii},ii) = timeList{ii};
end

[LCEachBurst, ~] = find(matWithRanks==1); % LC stands for leading channel (channel with rank 1 in each burst)
nRepsOfLC = hist(LCEachBurst,1:60);
[~,LCsorted] = sort(nRepsOfLC,'descend');

% NBs starting from the leading channels (LCsorted(1)...)
NBsfromHS = matWithRanks(:,LCEachBurst == LCsorted(1)); % HS stands for hot-spot; defining LCsorted(1) as the hot-spot

figure(); % cross-correlation matrix of the hotspot initiated bursts
imagesc(corrcov(cov(NBsfromHS)));
colormap(gray);
colorbar; box off; set(gca,'TickDir','Out');

NBmost2least = []; % this part will arrange the idices of the NBs from hotspots outwards.
for ii = 1:length(LCsorted)
    NBmost2least = [NBmost2least,find(matWithRanks(LCsorted(ii),:) == 1)]; 
end

figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
imagesc(corrcov(cov(matWithTimes(:,NBmost2least))));
colormap(gray);
colorbar;box off; set(gca,'TickDir','Out');
