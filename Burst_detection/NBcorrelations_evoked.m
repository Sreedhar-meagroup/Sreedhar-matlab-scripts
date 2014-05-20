 stimAnalysis_v3;

rankList         = cell(1,nStimSites);
timeList         = cell(1,nStimSites);
matWithRanks     = cell(1,nStimSites);
matWithTimes     = cell(1,nStimSites);
inv_matWithRanks = cell(1,nStimSites);
LCsorted         = cell(1,nStimSites);
LCEachResp       = cell(1,nStimSites);
nRepsOfLC        = cell(1,nStimSites);
sortednResps     = cell(1,nStimSites);
RespsMost2least  = cell(1,nStimSites);

for ii = 1:nStimSites
    matWithRanks{ii} = zeros(60,length(resp_slices{ii}));
    matWithTimes{ii} = zeros(60,length(resp_slices{ii}));
    matWithRanks{ii}(cr2hw(stimSites(ii))+1,:) = 1;
    for jj = 1:length(resp_slices{ii})
        rankList{ii}{jj} =  unique_us(resp_slices{ii}{jj}.channel)+1; % in 1-60 ch
        for kk = 1:size(rankList{ii}{jj},2)
            timeList{ii}{jj}(kk) = resp_slices{ii}{jj}.time(find(resp_slices{ii}{jj}.channel==rankList{ii}{jj}(kk)-1,1,'first'));
        end
        if isempty(kk)
            timeList{ii}{jj} = 0;
        else
            timeList{ii}{jj} = timeList{ii}{jj} - timeList{ii}{jj}(1);
        end
        matWithRanks{ii}(rankList{ii}{jj},jj) = 2:length(rankList{ii}{jj})+1; % because the stim site was considered rank1
        matWithTimes{ii}(rankList{ii}{jj},jj) = timeList{ii}{jj};
    end
    
    inv_matWithRanks{ii} = matWithRanks{ii}/max(matWithRanks{ii}(:));
    target_ind = find(inv_matWithRanks{ii});
    inv_matWithRanks{ii}(target_ind) = 1 - inv_matWithRanks{ii}(target_ind);
    
    [LCEachResp{ii}, ~] = find(matWithRanks{ii}==1); % LC stands for leading channel (channel with rank 1 in each burst)
    nRepsOfLC{ii} = hist(LCEachResp{ii},1:60);
    [sortednResps{ii},LCsorted{ii}] = sort(nRepsOfLC{ii},'descend');

    RespsMost2least{ii} = []; % this part will arrange the indices of the NBs from hotspots outwards.
    for mm = 1:length(LCsorted{ii})
        RespsMost2least{ii} = [RespsMost2least{ii},find(matWithRanks{ii}(LCsorted{ii}(mm),:) == 1)]; 
    end
end



% [LCEachResp, ~] = find(matWithRanks{1}==1); % LC stands for leading channel (channel with rank 1 in each burst)
% nRepsOfLC = hist(LCEachResp,1:60);
% [sortednResps,LCsorted] = sort(nRepsOfLC,'descend');
% 
% % modifying and rescaling the matWithRanks
% % First modification: 1 - rank values/max(rank values) = inv_matWithRanks;
% for ii = 1:nStimSites
%     inv_matWithRanks{ii} = matWithRanks{ii}/max(matWithRanks{ii}(:));
%     target_ind = find(inv_matWithRanks{ii});
%     inv_matWithRanks{ii}(target_ind) = 1 - inv_matWithRanks{ii}(target_ind);
% end


% Responses starting from the leading channels (LCsorted(1)...)


% RespsMost2least = []; % this part will arrange the indices of the resps from hotspots outwards.
% for ii = 1:length(LCsorted)
%     RespsMost2least = [RespsMost2least,find(matWithRanks{1}(LCsorted(ii),:) == 1)]; 
% end

%% figures_old
RespsfromHS = matWithRanks{1}(:,LCEachResp{1} == LCsorted{1}(1)); % HS stands for hot-spot; defining LCsorted(1) as the hot-spot


figure(); % cross-correlation matrix of the hotspot initiated bursts
imagesc(corrcov(cov(RespsfromHS)));
colormap(gray);
colorbar; box off; set(gca,'TickDir','Out');

figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
imagesc(corrcov(cov(matWithTimes{1}(:,RespsMost2least{1}))));
colormap(gray);
colorbar;box off; set(gca,'TickDir','Out');


%% figures_new

RespsfromHS_inv = inv_matWithRanks{1}(:,LCEachResp{1} == LCsorted{1}(1)); % HS stands for hot-spot; defining LCsorted(1) as the hot-spot

figure(); % cross-correlation matrix of the hotspot initiated bursts
% imagesc(corrcov(cov(RespsfromHS_inv)));
imagesc(corrcov(cov(inv_matWithRanks{2})));
colormap(gray);
axis square;
colorbar; box off; set(gca,'TickDir','Out');
title('inv');
title(['Evoked bursts from channel:',num2str(LCsorted{2}(1))],'FontSize',14);
set(gca,'FontSize',14);

% figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
% imagesc(corrcov(cov(inv_matWithRanks{1}(:,RespsMost2least{1}))));
% colormap(gray);
% axis square;
% colorbar;box off; set(gca,'TickDir','Out');
% title(['Evoked bursts from channel:',num2str(LCsorted{1}(1))],'FontSize',14);
% set(gca,'FontSize',14);

%%
Ev_corr.data = datRoot;
Ev_corr.sortednResps = sortednResps;
Ev_corr.LCsorted =  LCsorted;
Ev_corr.matWithRanks = matWithRanks;
Ev_corr.inv_matWithRanks = inv_matWithRanks;

%% Another figure comparing spont and evoked

figure(); % cross-correlation matrix of the all NBs, sorted from hotspot outwards.
combined_invRankMat = [Sp_corr.inv_matWithRanks(:,Sp_corr.LCEachBurst==Sp_corr.LCsorted(2))...
                        ,Ev_corr.inv_matWithRanks{2}];
imagesc(corrcov(cov(combined_invRankMat)));
colormap(gray);
axis square;
colorbar;box off; set(gca,'TickDir','Out');
title(['Spontaneous and evoked bursts from channel: ', num2str(LCsorted{2}(1))]...
    ,'FontSize',14);
set(gca,'FontSize',14);

