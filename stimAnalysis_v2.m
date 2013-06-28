% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site
% Here, I shall use the methodology described by Samora.
% Author: Sreedhar S Kumar
% Date: 27.06.2013
%--------------------------------------------------------------------------------------
% MATLAB Version 7.12.0.635 (R2011a)
% MATLAB License Number: 97144
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% MATLAB                                                Version 7.12       (R2011a)
% Simulink                                              Version 7.7        (R2011a)
% Data Acquisition Toolbox                              Version 2.18       (R2011a)
% Fixed-Point Toolbox                                   Version 3.3        (R2011a)
% Image Processing Toolbox                              Version 7.2        (R2011a)
% MATLAB Compiler                                       Version 4.15       (R2011a)
% Neural Network Toolbox                                Version 7.0.1      (R2011a)
% Parallel Computing Toolbox                            Version 5.1        (R2011a)
% Signal Processing Toolbox                             Version 6.15       (R2011a)
% Statistics Toolbox                                    Version 7.5        (R2011a)
% Wavelet Toolbox                                       Version 4.7        (R2011a)
%--------------------------------------------------------------------------------------

datName = '130625_4205_stimEfficacy.spike';
spikes=loadspike(datName,2,25);

%% Global rate
% sliding window; bin width = 1s
[counts,timeVec] = hist(spikes.time,[0:ceil(max(spikes.time))]);
figure(1); bar(timeVec,counts);
axis tight; xlabel('Time (s)'); ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Stimulus locations and time
%Splitting spikes and stim info into channels and analog cells.
for ii=0:63
    if ii<60
        inAChannel{ii+1,1} = spikes.time(spikes.channel==ii);
    else
        inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
    end
end
% the following info must be automatically gathered from the log file...
% working on that script stim_efficacy.m
nStimSites = 5;
stimSites = cr2hw([35, 21, 46, 41, 58]);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end

%% Measuring pre-stimulus inactivity

















for ii=0:63
    if ii<60
        inAChannel{ii+1,1} = spike2.time(spike2.channel==ii);
    else
        inAnalog{ii-59,1} = spike2.time(spike2.channel==ii);
    end
end
% stim site text filil undu; in this case it was 35 cr
nStimSites = 5;
stimSites = cr2hw([35, 21, 46, 41, 58]);
for ii = 0:59
    for jj = 1: length(inAnalog{2})
    periStim{ii+1,jj} = inAChannel{ii+1}(and(inAChannel{ii+1}>inAnalog{2}(jj)-0.05, inAChannel{ii+1}<inAnalog{2}(jj)+0.5));
    end
end


figure(1); 
for ii = 1:60
    plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.','linewidth',1)
    hold on
end
line([inAnalog{2}(1:5:length(inAnalog{2})) ;inAnalog{2}(1:5:length(inAnalog{2}))],repmat([0;60],size(inAnalog{2}(1:15))),'Color','r','LineWidth',1)
line([inAnalog{2}(2:5:length(inAnalog{2})) ;inAnalog{2}(2:5:length(inAnalog{2}))],repmat([0;60],size(inAnalog{2}(1:15))),'Color','g','LineWidth',1)
line([inAnalog{2}(3:5:length(inAnalog{2})) ;inAnalog{2}(3:5:length(inAnalog{2}))],repmat([0;60],size(inAnalog{2}(1:15))),'Color','c','LineWidth',1)
line([inAnalog{2}(4:5:length(inAnalog{2})) ;inAnalog{2}(4:5:length(inAnalog{2}))],repmat([0;60],size(inAnalog{2}(1:15))),'Color','k','LineWidth',1)
line([inAnalog{2}(5:5:length(inAnalog{2})) ;inAnalog{2}(5:5:length(inAnalog{2}))],repmat([0;60],size(inAnalog{2}(1:15))),'Color','m','LineWidth',1)
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot indicating stimulation at channels [',num2str(stimSites+1),'] (hw1)']);

for ii = 1:nStimSites
    stimResp{ii}= periStim(:,ii:5:length(inAnalog{2}));
    stimTimes{ii} = inAnalog{2}(ii:5:length(inAnalog{2}));
end

nSpikesInEachChannel = cellfun(@length,stimResp{1});
sumOfSpikesInEachChannel = sum(nSpikesInEachChannel,2);
[sortedSumOfSpikes, sortedIndx] = sort(sumOfSpikesInEachChannel,'descend');

%%
bins = -50: 10: 500;
for st = 1:5
    figure(st+1)
    for ch = 1:12
        count = 0;
        frsum = zeros(size(bins));
        for ii = 1:15
            spikes = stimResp{st}{sortedIndx(ch),ii}-stimTimes{st}(ii);
            if ~isempty(spikes)
                fr = zeros(size(bins));
                for jj = 1:length(bins)-1
                    fr(jj) = length(spikes(and(spikes>=bins(jj)*1e-3,spikes<(bins(jj+1)*1e-3))));
                end
                frsum = frsum+ fr;
                count = count + 1;
            end
        end
        subplot(3,4,ch)
        plot(bins,frsum/count,'k','linewidth',2)
        axis([-50 500 0 2])
        line([0 0],[0 max(2,max(frsum/count))],'Color','r');
        if ch == 1
           set(gca,'XTickLabel',[]);
           ylabel('sp/bin')
        elseif ch == 12
            set(gca,'YTickLabel',[]);
            xlabel('time [ms]')
        else
            set(gca,'XTickLabel',[]);
            set(gca,'YTickLabel',[]);
        end
    end
 end
