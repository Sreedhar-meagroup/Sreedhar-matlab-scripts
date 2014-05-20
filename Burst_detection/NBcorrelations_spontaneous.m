% run spontaneousData prior to running this file
spont_data = spontaneousData;
%getting spontaneous burst start and end times from the data structure.
mod_NB_onsets = spont_data.NetworkBursts.NB_extrema(:,1);
NB_ends = spont_data.NetworkBursts.NB_extrema(:,2);
NB_slices = spont_data.NetworkBursts.NB_slices;
NB_widths = NB_ends - mod_NB_onsets;

% initializing cells to store rank order and temporal order respectively

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
[sortednNBs,LCsorted] = sort(nRepsOfLC,'descend');

NBmost2least = []; % this part will arrange the indices of the NBs from hotspots outwards.
for ii = 1:length(LCsorted)
    NBmost2least = [NBmost2least,find(matWithRanks(LCsorted(ii),:) == 1)]; 
end


% modifying and rescaling the matWithRanks
% First modification: 1 - rank values/max(rank values) = inv_matWithRanks;
inv_matWithRanks = matWithRanks/max(matWithRanks(:));
target_ind = find(inv_matWithRanks);
inv_matWithRanks(target_ind) = 1 - inv_matWithRanks(target_ind);


% second modification: an exponential kernel
% inv_kernel_matWithRanks = inv_matWithRanks.*(1-exp(-inv_matWithRanks/2*mean(inv_matWithRanks(:))));



%% figures_old
% % NBs starting from the leading channels (LCsorted(1)...)
% NBsfromHS = matWithRanks(:,LCEachBurst == LCsorted(1)); % HS stands for hot-spot; defining LCsorted(1) as the hot-spot
% 
% % figure 1: corrcov without modifications/rescaling
% figure(); % cross-correlation matrix of the hotspot initiated bursts
% imagesc(corrcov(cov(NBsfromHS)));
% colormap(gray);
% colorbar; box off; set(gca,'TickDir','Out');
% 
% % figure 2: all NBs, without any modifications/rescaling.
% figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
% imagesc(corrcov(cov(matWithTimes(:,NBmost2least))));
% colormap(gray);
% colorbar;box off; set(gca,'TickDir','Out');
% 

%% figures_new
NBsfromHS_inv = inv_matWithRanks(:,LCEachBurst == LCsorted(1));

% figure 1: corrcov with modifications/rescaling
figure(); % cross-correlation matrix of the hotspot initiated bursts
imagesc(corrcov(cov(NBsfromHS_inv)));
colormap(gray);
colorbar; box off; set(gca,'TickDir','Out');
axis square;
title('NBs from same hotspot (1-normalized rank)');


% figure 2: all NBs, with modifications/rescaling.
figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
imagesc(corrcov(cov(inv_matWithRanks(:,NBmost2least))));
colormap(gray);
colorbar;box off; set(gca,'TickDir','Out');
axis square;
title('All bursts (1-normalized rank)');


%% Data to retain

Sp_corr.data = spont_data;
Sp_corr.sortednNBs = sortednNBs;
Sp_corr.LCsorted =  LCsorted;
Sp_corr.LCEachBurst =  LCEachBurst;
Sp_corr.matWithRanks = matWithRanks;
Sp_corr.inv_matWithRanks = inv_matWithRanks;


%% run this

% clearvars -except Sp_corr