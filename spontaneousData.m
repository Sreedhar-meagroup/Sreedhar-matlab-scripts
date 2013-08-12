%function spontaneousData
[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\Spontaneous';
end
[datName,~]=uigetfile('*.spike','Select MEABench Data file',srcPath);
datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike(datName,2,25);

%% Cleaning spikes, getting them into channels
spks = cleanspikes(spikes);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
%% Fig 1a: global firing rate
% sliding window; bin width = 1s
[counts,timeVec] = hist(spks.time,0:ceil(max(spks.time)));
figure(1); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Fig 1b: General raster
gfr_rstr_h = figure(1); 
handles(1) = gfr_rstr_h;
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
rasterplot2(spks.time,spks.channel,'b-')
% for ii = 1:60 
%     plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.');
%     %axis tight;
% end
hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title('Raster plot of spontaneous activity');
zoom xon;

%% Burst detection part
burst_detection = burstDetAllCh_sk(spikes);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spikes,burst_detection,10);
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


%% Computing the channels to ignore
%in network burst channel wise
spikesInNB = cell(60,1);
for ii=0:59
    spikesInNB{ii+1,1} = inNB_time(inNB_channel==ii);
end

% outside network bursts - channel wise
spikesOutNB = cell(60,1);
for ii=0:59
    spikesOutNB{ii+1,1} = outNB_time(outNB_channel==ii);
end

nSpikesInNB = cellfun(@length, spikesInNB);
nSpikesOutNB = cellfun(@length, spikesOutNB);
nSpikesTotal = cellfun(@length,inAChannel);
pcSpikesOutNB = nSpikesOutNB./nSpikesTotal*100;
[sortedpc, sortedIdx] = sort(pcSpikesOutNB,'descend');
ii = 1;
ch2ignore = [];
while 1
    if nSpikesTotal(sortedIdx(ii)) > 0.05*max(nSpikesTotal)
        if sortedpc(ii) > 20 
            ch2ignore = [ch2ignore, sortedIdx(ii)];
        else
            break;
        end
    end
    ii = ii + 1;
end
% marking ignored channels in red in the raster
figure(1); subplot(3,1,2:3)
hold on;
for ii = 1: size(ch2ignore,2)
    plot(inAChannel{ch2ignore(ii)},ones(size(inAChannel{ch2ignore(ii)}))*ch2ignore(ii),'.r');
end
hold off

%% `Patch'ing the network event
figure(1); subplot(3,1,2:3)
hold on;
%line([mod_NB_onsets' ; mod_NB_onsets'], repmat([0;60],size(mod_NB_onsets')),'Color',[0,0,0]+0.7,'LineWidth',0.1);
Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
Ycoords = 60*repmat([0;1;1;0],size(NB_ends'));
patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.2);
hold off;