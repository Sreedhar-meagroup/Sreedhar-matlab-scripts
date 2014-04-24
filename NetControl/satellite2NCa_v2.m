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

% No: of spikes per single channel burst
allLengths = cellfun(@length, burst_recSite{recSite_in_hwpo});
nSpikesperBurst_pre = allLengths(:,3);

% Single channel IBI plot
IBI_RecCh = zeros(size(burstsInRecCh.onsets.time));
IBI_RecCh(1) = burstsInRecCh.onsets.time(1);
IBI_RecCh(2:end) = burstsInRecCh.onsets.time(2:end) - burstsInRecCh.ends.time(1:end-1);

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
title('pre')

% Single channel ISI plot
Steps = 10.^[-5:.05:1.5];
HistogramISIn(pre_spont.InAChannel{recSite_in_hwpo},2,Steps);
title('pre');
line([200,200],[10^-5, 10^-1]);
set(gca,'FontSize',12);
% Adding to the spont raster plot
% plt_gfrWithRaster(pre_spont);
% hold on
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.onsets.idx))','k-');
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.ends.idx))','r-');
% hold off;

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
nSpikesperBurst_post = allLengths(:,3);

IBI_RecCh = zeros(size(burstsInRecCh.onsets.time));
IBI_RecCh(1) = burstsInRecCh.onsets.time(1);
IBI_RecCh(2:end) = burstsInRecCh.onsets.time(2:end) - burstsInRecCh.ends.time(1:end-1);

timeVec = 0:0.5:max(IBI_RecCh);
counts = histc(IBI_RecCh,timeVec);

figure();
bar_h = bar(timeVec,counts/length(IBI_RecCh),'histc');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
set(gca, 'FontSize', 14)
ylabel('probability')
xlabel('IBI in recording channel [s]')
title('post');

% Single channel ISI plot
Steps = 10.^[-5:.05:1.5];
HistogramISIn(post_spont.InAChannel{recSite_in_hwpo},2,Steps);
title('post');
line([200,200],[10^-5, 10^-1]);
set(gca,'FontSize',12);
% Adding to the spont raster plot
% plt_gfrWithRaster(post_spont);
% hold on
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.onsets.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.onsets.idx))','k-');
% rasterplot_so(pre_spont.Spikes.time(burstsInRecCh.ends.idx),(recSite_in_hwpo-1)*ones(size(burstsInRecCh.ends.idx))','r-');
% hold off;


%%
% main_vector = nSpikesperBurst_pre;
% grps = zeros(size(nSpikesperBurst_pre));
arg1_bwerr = std(nSpikesperBurst_pre);
arg2_bwerr = mean(nSpikesperBurst_pre);
for ii = 1:nSessions
    respL_n_swise{ii} = respLengths_n(session_vector(ii):session_vector(ii+1));
    arg1_bwerr(ii+1) = std(respL_n_swise{ii});
    arg2_bwerr(ii+1) = mean(respL_n_swise{ii});
end
arg1_bwerr(end+1) = std(nSpikesperBurst_pre);
arg2_bwerr(end+1) = mean(nSpikesperBurst_pre);

figure();
barwitherr(arg1_bwerr,arg2_bwerr,'g','EdgeColor','None');
% barwitherr([std(nSpikesperBurst_pre),std(respL_n_swise{1}),std(respL_n_swise{2}),std(respL_n_swise{3}), ...
%     std(respL_n_swise{4}), std(respL_n_swise{5}), std(respL_n_swise{6}), std(nSpikesperBurst_post)], ...
%     [mean(nSpikesperBurst_pre),mean(respL_n_swise{1}),mean(respL_n_swise{2}),mean(respL_n_swise{3}), ...
%     mean(respL_n_swise{4}), mean(respL_n_swise{5}), mean(respL_n_swise{6}), mean(nSpikesperBurst_post)]);
box off;
set(gca,'FontSize',12);
set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3','Post'});
% set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3',...
%     'Train4','Test4','Train5','Test5','Train6','Test6','Post'});

ylabel('No. of spikes');
xticklabel_rotate;

%% resp length distribution

    figure();
    num = hist(nSpikesperBurst_pre,0:max(nSpikesperBurst_pre));
    dist_spon(1) = subplot(2,1,1);
    semilogx(0:max(nSpikesperBurst_pre),num/length(nSpikesperBurst_pre),'k-','LineWidth',2);
    box off;
    title('Pre-session');
    grid on;
    num = hist(nSpikesperBurst_post,0:max(nSpikesperBurst_post));
    dist_spon(1) = subplot(2,1,2);
    semilogx(0:max(nSpikesperBurst_post),num/length(nSpikesperBurst_post),'k-','LineWidth',2);
    box off;
    title('Post-session');
    grid on;
    [ax1,h1]=suplabel('Response length');
    [ax2,h2]=suplabel('probability','y');
    set(h1,'FontSize',12);
    set(h2,'FontSize',12);