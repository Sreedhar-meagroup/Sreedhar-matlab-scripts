function h = plotTimeSlice(spks,startTime, stopTime)

slice = find(spks.time >= startTime & spks.time <= stopTime);
timeStamps  = spks.time(slice);
channels    = spks.channel(slice);
stimTimesVec = [spks.stimTimes{:}];
stimTimesSlice = stimTimesVec(stimTimesVec >= startTime & stimTimesVec <= stopTime);
stimSitesSlice = spks.stimSites(stimTimesVec >= startTime & stimTimesVec <= stopTime);

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

line([stimTimesSlice; stimTimesSlice], repmat([0;60],size(stimTimesSlice)),'Color','g','LineWidth',0.1);
patch([stimTimesSlice; stimTimesSlice], repmat([0;60],size(stimTimesSlice)), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
plot(stimTimesSlice, cr2hw(stimSitesSlice)+1,'r*');

% code for the tiny rectangle
Xcoords = [stimTimesSlice; stimTimesSlice; stimTimesSlice+0.5; stimTimesSlice+0.5];
Ycoords = 60*repmat([0;1;1;0],size(stimTimesSlice));
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