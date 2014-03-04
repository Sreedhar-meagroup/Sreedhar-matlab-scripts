if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(3,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike([pathName,datName],2,25);
thresh  = extract_thresh([pathName, datName, '.desc']);


%% Stimulus locations and time
%Get stim info into analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
% I do this before cleaning the spikes because I do not want to clean off
% the stim times in the analog channels.

inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end


% the following info shall in future versions automatically gathered from the log file...
% working on that script stim_efficacy.m


% rawText = fileread('C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\NetControl\PID317_CID4346\session_1_4346\session_1_4346.log');
% 
% stimSitePattern = 'The choice of the Stimulating: recording pair was made as (\d\d):(\d\d))';
% [matchedPattern matchedPatternIdx_start matchedPatternIdx_end ...
%     token_idx token_data] = regexp(rawText, stimSitePattern, 'match');
% stimSites = str2num(cell2mat(strtrim(token_data{1}))) % cr
if ~exist('stimSite','var')
    str = inputdlg('Enter the stimulation site (in cr)');
    stimSite = str2num(str{1}); % in cr
    str = inputdlg('Enter the recording site (in cr)'); % in cr
    recSite = str2num(str{1});
end
stimTimes = inAnalog{2};

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells

off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
spikes_oc = spikes;
spikes_oc.context = off_corr_contexts;
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
spks = blankArtifacts(spks,stimTimes,1);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3);
% spks = spikes;
spks.stimTimes = stimTimes;
spks.stimSites = repmat(stimSite,size(stimTimes));
spks.recSite = recSite;
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end

%% Fig 1a: global firing rate
% % sliding window; bin width = 100ms
[counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
figure(1); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Fig 1b: General raster
gfr_rstr_h = figure(1); 
handles(1) = gfr_rstr_h;
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
%line([stimTimes ;stimTimes], repmat([0;60],size(stimTimes)),'Color','r','LineWidth',0.1);
patch([stimTimes ;stimTimes], repmat([0;60],size(stimTimes)), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
plot(stimTimes,cr2hw(stimSite)+1,'r*');

% code for the tiny rectangle
Xcoords = [stimTimes;stimTimes;stimTimes+0.5;stimTimes+0.5];
Ycoords = 60*repmat([0;1;1;0],size(stimTimes));
patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.2);

rasterplot_so(spks.time,spks.channel,'b-');
response.time = spks.time(spks.channel == cr2hw(recSite));
response.channel = spks.channel(spks.channel == cr2hw(recSite));
rasterplot_so(response.time,response.channel,'r-');
hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot indicating stimulation:recording at channel [',num2str(stimSite),'/'...
    ,num2str(cr2hw(stimSite)+1),':',num2str(recSite),'/',num2str(cr2hw(recSite)+1),'(cr/hw^{+1})']);
zoom xon;
pan xon;
%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell structure.
% Layer 1 is a 60x1 cell, each corresponding to a channel
% Layer 2 is a nx1 cell, holding the periStim (-50 ms to +500 ms)spike stamps corresponding to each of the n stimuli.
periStim = cell(60,1);
for jj = 1: size(stimTimes,2)
    for kk = 1:60
        periStim{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes(jj)-0.05, inAChannel{kk}<stimTimes(jj)+0.5));
    end
end


%% Measuring pre-stimulus inactivity/periods of silence at the recording site
% silence_s has a matrix in a cell structure.
% Layer 1 (outer) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x50 matrix, each row corresponding to a channel and column
% corresponding to the 50 individual stimuli.

silence_s = zeros(size(stimTimes));
for jj = 1: size(stimTimes,2)
    previousTimeStamp = inAChannel{cr2hw(recSite)+1}(find(inAChannel{cr2hw(recSite)+1}<stimTimes(jj),1,'last'));
    if isempty(previousTimeStamp), previousTimeStamp = 0; end
    silence_s(jj) = (stimTimes(jj) - previousTimeStamp);
end

%% Response lengths (in no: of spikes)

periStimAtRecSite = periStim{cr2hw(recSite)+1};
respLengths_n = zeros(size(stimTimes));
for ii = 1: size(stimTimes,2)
    respLengths_n(ii) =  length(find(periStimAtRecSite{ii}>stimTimes(ii)));
end

%% Response lengths (in time)
respBurst = cell(size(stimTimes));
respLengths_ms = zeros(size(stimTimes));
for ii = 1:size(stimTimes,2)
    temp = periStimAtRecSite{ii};
    if isempty(temp), continue; end
    
    ISI = diff(temp);
    breach = find(ISI>=0.1,1,'first');
    if isempty(breach)
        respBurst{ii} = temp;
    else
        respBurst{ii} = temp(1:breach);
        if ISI(breach)<= 0.2
            respBurst{ii}(end+1) = temp(breach+1);
        end
    end
    respLengths_ms(ii) =  (respBurst{ii}(end) - stimTimes(ii))*1e3;
end
%% peristim long at recording site
periStimAtRecSite_long = periStim{cr2hw(recSite)+1};


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

%% `Patch'ing the network events
% % green path stands for the network burst and the red one for the stim response window
% figure(handles(1)); subplot(3,1,2:3)
% hold on;
% %line([mod_NB_onsets' ; mod_NB_onsets'], repmat([0;60],size(mod_NB_onsets')),'Color',[0,0,0]+0.7,'LineWidth',0.1);
% Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
% Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
% patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.35);
% hold off;
%% spikes per channel per time
spksPerCHPerTime = length(spks.time)/(60*(max(spks.time) - min(spks.time)));
%% Figures
%% plot1: response lengths(#spikes) vs stimNo
h1 = figure();
plot(respLengths_n,'LineWidth',1);
%shadedErrorBar(1:length(respLengths_n),respLengths_n,std(respLengths_n)*ones(size(respLengths_n)),{'b','linewidth',0.5},0);
hold on;
plot(mean(respLengths_n)*ones(size(respLengths_n)),'r.', 'MarkerSize',3);
box off
% plot(mean(respLengths_n) + std(respLengths_n)*ones(size(respLengths_n)),'r-');
% plot(mean(respLengths_n) - std(respLengths_n)*ones(size(respLengths_n)),'r-');
%axis square; 
%axis tight
set(gca, 'FontSize', 14)
xlabel('Stimulus number')
ylabel('No: of spikes in response')
% saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');

%title('Response during testing');

%% plot2: Pre-stimulus inactivity vs stim number
[rl_n_sorted, rl_n_ind] = sort(respLengths_n);
cmap = varycolor(max(respLengths_n)+1);
figure();
scatter(rl_n_ind,silence_s(rl_n_ind),10,cmap(rl_n_sorted+1,:),'fill');
box off;
colormap(cmap);
hcb = colorbar;
set(gca, 'FontSize', 14);
xlabel('Stimulus number');
ylabel('Pre-stimulus inactivity [s]');
ylabel(hcb,'Response length (normalized)');

% h2 = figure();
% cmp = jet(max(respLengths_n));
% scatter(silence_s,'.','markersize',5);
% box off;
%hold on;
%plot(mean(silence_s)*ones(size(silence_s)),'r.', 'MarkerSize',3);
% plot(mean(silence_s) + std(silence_s)*ones(size(silence_s)),'r-');
% plot(mean(silence_s) - std(silence_s)*ones(size(silence_s)),'r-');
%axis square; 
%axis tight
% set(gca, 'FontSize', 14);
% xlabel('Stimulus number');
% ylabel('Pre-stimulus inactivity [s]');
%title('Response during testing');
% saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');

%% plot3: Response lengths(#spikes) vs. pre-stimulus inactivities
% Boxplot version of RL (#spikes) vs psi
[sortedSil, silInd] = sort(silence_s);
respOfSortedSil_n = respLengths_n(silInd);
dt = 0.5
disp('Did you remember to set the right dt?');
h3 = plt_respLength(sortedSil,respOfSortedSil_n,dt);
% saveas(h3,[figPath,'nSpvsSil2',session,'.eps'], 'psc2');

% Abandoned this version of plot3
% h3 = figure();
% plot(sortedSil, respOfSortedSil,'.','LineWidth',2);
% box off;
% set(gca, 'FontSize', 14);
% xlabel('Pre-stimulus inactivity [s]');
% ylabel('Response length (# spikes)');
%title('Response during testing');
% saveas(h3,[figPath,'nSpvsSil',session,'.eps'], 'psc2');

%% plot4: Response lengths(ms) vs. pre-stimulus inactivities
% Boxplot version of RL (ms) vs psi
respOfSortedSil_ms = respLengths_ms(silInd);
h4 = plt_respLength(sortedSil,respOfSortedSil_ms,dt,'ms');
% saveas(h4,[figPath,'rlvsSil2',session,'.eps'], 'psc2');

% Abandoned this version of plot4
% h4 = figure();
% [sortedSil, silInd] = sort(silence_s);
% plot(sortedSil, respLengths_ms(silInd),'.-','LineWidth',2);
% box off;
% set(gca, 'FontSize', 14);
% xlabel('Pre-stimulus inactivity [s]');
% ylabel('Response length [ms]');
%title('Response during testing');
% saveas(h4,[figPath,'respLvsSil',session,'.eps'], 'psc2');


% export_fig('C:\Sreedhar\Lat_work\Brainlinks\NetControl_results...
%\figures_317_4346_s1\rl_vs_sil','-eps','-transparent')

%% slice of a raster around a given stim number (manual -- very accurate)
% dcm_obj = datacursormode(h2);
% set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on');
% figure(h2);
% keyboard;
% c_info = getCursorInfo(dcm_obj);
% plotTimeSlice(spks,stimTimes(c_info.DataIndex)-10,stimTimes(c_info.DataIndex)+5,'nb',mod_NB_onsets,NB_ends,'resp');
% hold on;
% plot(stimTimes(c_info.DataIndex),0,'r^');
% hold off;

%% slice of a raster around a given stim number (automatic -- less accurate)
figure(h2);
set(h2, 'WindowButtonDownFcn',{@Marker2Raster,spks,stimTimes,silence_s,mod_NB_onsets,NB_ends});

%% Saving figures
% figPath = 'C:\Users\duarte\Desktop\NetControl\PID321_4411\';
figPath = 'D:\Codes\Lat_work\Closed_loop\NetControl_analysis\E3_317_4346_s1\figures\';
session = '_training';
saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');
saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');
saveas(h3,[figPath,'nSpvsSil',session,'.eps'], 'psc2');
saveas(h4,[figPath,'rlvsSil2',session,'.eps'], 'psc2');
