function h = plotTimeSlice(spks,startTime, stopTime)

slice = find(spks.time >= startTime & spks.time <= stopTime);
timeStamps  = spks.time(slice);
channels    = spks.channel(slice);
if iscell(spks.stimTimes)
    stimTimesVec = [spks.stimTimes{:}]; % [ch.1, ch1, ch1 ...x50 times, ch.2, ch.2,... x50 times,...]
else
    stimTimesVec = spks.stimTimes;
end 
stimTimesVec = sort(stimTimesVec); % so that the stimTimes are now in [ch.1, ch2., .. ch59., ch1., ch2., ...]
stimTimesSlice = stimTimesVec(stimTimesVec >= startTime & stimTimesVec <= stopTime);
stimSitesSlice = spks.stimSites(stimTimesVec >= startTime & stimTimesVec <= stopTime); % in cr

%% Fig 1a: global firing rate
 h = figure(); 
% sliding window; bin width = 100ms
[counts,timeVec] = hist(timeStamps,0:0.1:ceil(max(timeStamps)));
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Fig 1b: General raster

fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;

% line([stimTimesSlice; stimTimesSlice], repmat([0;61],size(stimTimesSlice)),'Color','g','LineWidth',0.1);
patch([stimTimesSlice; stimTimesSlice], repmat([0;61],size(stimTimesSlice)),'g', 'EdgeColor','g', 'EdgeAlpha', 0.35, 'FaceColor', 'none');
plot(stimTimesSlice, cr2hw(stimSitesSlice)+1,'r*');

% code for the tiny rectangle
Xcoords = [stimTimesSlice; stimTimesSlice; stimTimesSlice+0.5; stimTimesSlice+0.5];
Ycoords = 61*repmat([0;1;1;0],size(stimTimesSlice));
patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.2);

rasterplot_so(timeStamps,channels,'b-');
hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title('Raster plot');
pan xon;
zoom xon;
end