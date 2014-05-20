function h = plotTimeSlice(spks,startTime,stopTime,varargin)
% pass 'NB', mod_NB_onsets, NB_ends to plot also the NBs
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
binSize = 0.05;
[counts,timeVec] = hist(timeStamps,0:binSize:ceil(max(timeStamps)));
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts/binSize);
axis tight; ylabel('Global firing rate [Hz]'); title(['Binwidth = ',num2str(binSize*1e3),'ms']);
box off;
set(gca,'TickDir','Out');

%% Fig 1b: General raster

fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
% line([stimTimesSlice; stimTimesSlice], repmat([0;61],size(stimTimesSlice)),'Color','g','LineWidth',0.1);
% patch([stimTimesSlice; stimTimesSlice], repmat([0;61],size(stimTimesSlice)),'g', 'EdgeColor','g', 'EdgeAlpha', 0.35, 'FaceColor', 'none');
plot(stimTimesSlice, cr2hw(stimSitesSlice)+1,'r.');
hold on;
for ii = 1:length(stimTimesSlice)
    Xcoords = [stimTimesSlice(ii);stimTimesSlice(ii);stimTimesSlice(ii)+0.5;stimTimesSlice(ii)+0.5];
    Ycoords = 61*[0;1;1;0];
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.2);
end
% % code for the tiny rectangle
% Xcoords = [stimTimesSlice; stimTimesSlice; stimTimesSlice+0.5; stimTimesSlice+0.5];
% Ycoords = 61*repmat([0;1;1;0],size(stimTimesSlice));
% patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.2);

rasterplot_so(timeStamps,channels,'b-');

if nargin >= 6
    if nargin == 7
        response.time = timeStamps(channels == cr2hw(spks.recSite));
        response.channel = repmat(cr2hw(spks.recSite),size(response.time));
        rasterplot_so(response.time,response.channel,'r-');
    end
    %% patching network events
    mod_NB_onsets = varargin{2};
    temp1 = mod_NB_onsets(mod_NB_onsets>startTime & mod_NB_onsets<stopTime);
    NB_ends = varargin{3};
    temp2 = NB_ends(mod_NB_onsets>startTime & mod_NB_onsets<stopTime);
    mod_NB_onsets = temp1;
    NB_ends = temp2;
    Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
    Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
    patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.35);

end

hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title('Raster plot');
pan xon;
zoom xon;
end