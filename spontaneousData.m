%   function varargout = spontaneousData(datName,pathName)
%% Look for data if you dont find the datName
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(5,'NetControl');
end
    datRoot = datName(1:strfind(datName,'.')-1);
    spikes=loadspike([pathName,datName],2,25);
    thresh  = extract_thresh([pathName, datName, '.desc']);
% thresh = 7;

%% Cleaning spikes, getting them into channels
off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
spikes_oc = spikes;
spikes_oc.context = off_corr_contexts;
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts
% [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
%% Fig 1a: global firing rate
%bin width = 100ms
[counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
gfr_rstr_h = figure('name', 'Spontaneous activity','NumberTitle','off');
handles(1) = gfr_rstr_h;
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes');
title(['Global firing rate (bin= 100 ms)            data:',datRoot],'Interpreter','none');
set(gca,'TickDir','Out');
%% Burst detection part
burst_detection = burstDetAllCh_sk(spks);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spks,burst_detection,10);
% harking back 50ms from the current NB onset definition and redefining onset boundaries.
mod_NB_onsets = zeros(length(NB_onsets),1);
for ii = 1:length(NB_onsets)
    if ~isempty(find(spks.time>NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2), 1))
        mod_NB_onsets(ii) = spks.time(find(spks.time >...
            NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2),1,'first'));
    else
        mod_NB_onsets(ii) = NB_onsets(ii,2);
    end
end
NB_slices = cell(length(mod_NB_onsets),1);
inNB_time =[];
inNB_channel =[];
for ii = 1: length(mod_NB_onsets)
    NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    inNB_time = [inNB_time, NB_slices{ii}.time];
    inNB_channel = [inNB_channel, NB_slices{ii}.channel];
end
[outNB_time, outIndices] = setdiff(spks.time, inNB_time);
outNB_channel = spks.channel(outIndices);


%% Computing the channels to ignore (in hw+1)
ch2ignore= [];
% % in network burst channel wise
% spikesInNBbyChannel = cell(60,1);
% for ii=0:59
%     spikesInNBbyChannel{ii+1,1} = inNB_time(inNB_channel==ii);
% end
% 
% % outside network bursts - channel wise
% spikesOutNBbyChannel = cell(60,1);
% for ii=0:59
%     spikesOutNBbyChannel{ii+1,1} = outNB_time(outNB_channel==ii);
% end
% 
% %Note: this analysis is per channel
% nSpikesInNBbyChannel = cellfun(@length, spikesInNBbyChannel);
% nSpikesOutNBbyChannel = cellfun(@length, spikesOutNBbyChannel);
% nSpikesTotal = cellfun(@length,inAChannel);
% pcSpikesOutNB = nSpikesOutNBbyChannel./nSpikesTotal*100;
% [sortedpc, sortedIdx] = sort(pcSpikesOutNB,'descend');
% ii = 1;
% ch2ignore = [];
% while 1
%     if nSpikesTotal(sortedIdx(ii)) > 0.05*max(nSpikesTotal)
%         if sortedpc(ii) > 20 
%             ch2ignore = [ch2ignore, sortedIdx(ii)];
%         else
%             break;
%         end
%     end
%     ii = ii + 1;
% end
% marking ignored channels in red in the raster
%     figure(handles(1)); subplot(3,1,2:3)
%     hold on;
%     line(repmat([0;spks.time(end)],size(ch2ignore)),[ch2ignore; ch2ignore],'Color','k','LineWidth',.1);    
%     igspks = [];
%     igchnnls = [];
%     for ii = 1: size(ch2ignore,2)
%         igspks = horzcat(igspks, spks.time(spks.channel==ch2ignore(ii)));
%         igchnnls = horzcat(igchnnls,ch2ignore(ii)*ones(1,length(spks.time(spks.channel==ch2ignore(ii)))));
%        %plot(inAChannel{ch2ignore(ii)},ones(size(inAChannel{ch2ignore(ii)}))*ch2ignore(ii),'.r');
%     end
% %     rasterplot_so(igspks,igchnnls-1,'r-')
%     hold off

%% `Patch'ing the network event
figure(handles(1)); subplot(3,1,2:3)
hold on;
%line([mod_NB_onsets' ; mod_NB_onsets'], repmat([0;60],size(mod_NB_onsets')),'Color',[0,0,0]+0.7,'LineWidth',0.1);
Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);
hold off;
%% Fig 1b: General raster
figure(handles(1));
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
rasterplot_so(spks.time,spks.channel,'b-');
% for ii = 1:60 
%     plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.','markersize',6);
%     axis tight;
% end
hold off;
set(gca,'TickDir','Out');
set(gca,'YMinorGrid','On');
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot of spontaneous activity          ', num2str(length(network_burst)), ' NBs']);
zoom xon;
pan xon;

%% Visualizing rejected spikes
figure(handles(1));subplot(3,1,2:3)
hold on;
badspikes = spikes.time(rejIdx);
badchannels = spikes.channel(rejIdx);
bad_h = rasterplot_so(badspikes, badchannels,'r-');
hold off;
set(bad_h, 'Visible','off');

%% Plotting the IBI distribution
IBIs = zeros(size(mod_NB_onsets));
IBIs(1) = mod_NB_onsets(1);
IBIs(2:end) = mod_NB_onsets(2:end) - NB_ends(1:end-1);
[counts, timeVec] = hist(IBIs,0:0.5:max(IBIs));
figure('name', 'IBI statistics', 'NumberTitle', 'off');
% subplot(1,2,1)
bar(timeVec, counts/length(IBIs),'EdgeColor','None','FaceColor','k');
box off;
% axis square; axis tight;
set(gca, 'FontSize', 16)
ylabel('probability')
xlabel('IBI [s]')

% subplot(1,2,2)
% %plot(IBIs); hold on; plot(mean(IBIs)*ones(size(IBIs)),'r--');
% shadedErrorBar(1:length(IBIs),IBIs,std(IBIs)*ones(size(IBIs)),{'b','linewidth',0.5},0);
% hold on;
% plot(mean(IBIs)*ones(size(IBIs)),'r.', 'MarkerSize',3);
% axis square; axis tight
% set(gca, 'FontSize', 14)
% ylabel('time [s]')
% xlabel('IBI number')
% 
% suptitle('Inter-Burst Interval(IBI) statistics');
%% when used as a function, what variables are to be returned
varargout{1} = ch2ignore;
varargout{2} = [mod_NB_onsets, NB_ends];
varargout{3} = NB_slices;
%%
% IBIs_4350_s2_post = IBIs;
myfun = @(x) size(x.time,2);
nSpikesPerNB = cellfun(@(x) myfun(x),NB_slices);
% nSpikesPerNB_4350_s2_post = nSpikesPerNB;
% BDuration_s_4350_s2_post = NB_ends - mod_NB_onsets;

%%
% clearvars -except IBIs_4346_s1_pre  nSpikesPerNB_4346_s1_pre  BDuration_s_4346_s1_pre ... 
%                   IBIs_4346_s2_pre  nSpikesPerNB_4346_s2_pre  BDuration_s_4346_s2_pre ...
%                   IBIs_4346_s1_post nSpikesPerNB_4346_s1_post BDuration_s_4346_s1_post ...
%                   IBIs_4346_s2_post nSpikesPerNB_4346_s2_post BDuration_s_4346_s2_post ...
%                   IBIs_4350_s2_pre  nSpikesPerNB_4350_s2_pre  BDuration_s_4350_s2_pre ...
%                   IBIs_4350_s2_post nSpikesPerNB_4350_s2_post BDuration_s_4350_s2_post 

%% 
% inRec = inAChannel{cr2hw(84)+1};
% figure(handles(1)); hold on;
% subplot(3,1,2:3)
% plot(inRec,ones(size(inRec))*31,'g.','markersize',5); hold off;
% Rec_s2_4350.after = length(inRec)/(max(spks.time) - min(spks.time))

                  