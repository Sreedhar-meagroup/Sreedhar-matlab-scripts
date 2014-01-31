% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site
% Here, I shall look only at those stimuli that were preceded by a 1s
% pre-stim silence.

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
[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\StimRecSite\StimPolicy2';
end

[datName,~]=uigetfile('*.spike','Select MEABench Data file',srcPath);
%datName = '130627_4225_stimEfficacy.spike';
%datName = '130625_4205_stimEfficacy.spike';
%datName = '130703_PID311_CID4244_MEA15570_DIV26_stimEfficacy.spike';
datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike(datName,2,25);
handles = zeros(1,7);
%% Fig 1a: global firing rate
% sliding window; bin width = 1s
[counts,timeVec] = hist(spikes.time,0:ceil(max(spikes.time)));
figure(1); subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Stimulus locations and time
%Splitting spikes and stim info into channels and analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site

inAChannel = cell(60,1);
inAnalog = cell(4,1);
for ii=0:63
    if ii<60
        inAChannel{ii+1,1} = spikes.time(spikes.channel==ii);
    else
        inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
    end
end

% the following info shall in future versions automatically gathered from the log file...
% working on that script stim_efficacy.m

nStimSites = 5;
str = inputdlg('Enter the list of stim sites (in cr),separated by spaces or commas');
stimSites = str2num(str{1}); % in cr
%stimSites = cr2hw([35, 21, 46, 41, 58]);
stimTimes = cell(1,5);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end


%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell in a cell structure.
% Layer 1 (outer cell) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x1 cell, each corresponding to a channel
% Layer 3 is a 50x1 cell, holding the periStim spike stamps corresponding to each of the 50 stimuli.
periStim = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            periStim{ii}{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes{ii}(jj)-0.05, inAChannel{kk}<stimTimes{ii}(jj)+0.5));
        end
    end
end

%% Measuring pre-stimulus inactivity/periods of silence
% silence_s has a matrix in a cell structure.
% Layer 1 (outer) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x50 matrix, each row corresponding to a channel and column
% corresponding to the 50 individual stimuli.

silence_s = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            previousTimeStamp = inAChannel{kk}(find(inAChannel{kk}<stimTimes{ii}(jj),1,'last'));
            if isempty(previousTimeStamp), previousTimeStamp = 0; end
            silence_s{ii}(kk,jj) = stimTimes{ii}(jj) - previousTimeStamp;
        end
    end
end

%% Isolating the periStims that follow a period of silence > tSilence_s
% periStim_selected has the same structure as periStim
periStim_selected = cell(size(periStim));
tSilence_s = 1;
for ii = 1:nStimSites
    [validRows, validCols] = find(silence_s{ii}>tSilence_s);
    for jj = 1: size(validRows,1)
        periStim_selected{ii}{validRows(jj),1}{validCols(jj),1} = periStim{ii}{validRows(jj)}{validCols(jj)};
    end
    
% fixed a bug in retrospective
% If by chance a channel did not have a valid response in the 50th trial,
% that cell array would remain of length 49. There could be a more elegant
% solution. But this patch works for the moment. buggyLength is the index of
% such aberrant channels. diffLen is the deficit in length which is then
% appropriately compensated.
    
        buggyLengths = find(cellfun(@length,periStim_selected{ii})<50);
        if buggyLengths
            for kk = 1:length(buggyLengths)
                diffLen = length(stimTimes{ii}) - length(periStim_selected{ii}{buggyLengths(kk)});
                periStim_selected{ii}{buggyLengths(kk)}{end+diffLen} = [];
            end
        end
end


%% Fig 1b: General raster
gfr_rstr_h = figure(1); 
handles(1) = gfr_rstr_h;
subplot(3,1,2:3)

for ii = 1:60 
    plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.','MarkerSize',5);
    axis tight;
    hold on
end
for ii = 1:nStimSites
    switch ii
        case 1
            clr = 'r';
        case 2
            clr = 'g';
        case 3
            clr = 'c';
        case 4
            clr = 'k';
        case 5
            clr = 'm';
    end
%line([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})),'Color',clr,'LineWidth',0.1);
patch([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
plot(stimTimes{ii},cr2hw(stimSites(ii))+1,[clr,'*']);

% code for the tiny rectangle
Xcoords = [stimTimes{ii};stimTimes{ii};stimTimes{ii}+0.5;stimTimes{ii}+0.5];
Ycoords = 60*repmat([0;1;1;0],size(stimTimes{ii}));
patch(Xcoords,Ycoords, 'r', 'EdgeColor','none', 'FaceAlpha',0.2);
end
hold off;
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot indicating stimulation at channels [',num2str(cr2hw(stimSites)+1),'] (hw+1)']);

%% Binning, averaging and plotting the PSTHs with 1s pre-stim silence
% listOfCounts = cell(1,nStimSites);
% for ii = 1:nStimSites
%     figure(2+ii)
%     for jj = 1:60
%         bins = -50: 10: 500;
%         count = 0;
%         frMat = zeros(2,length(bins));
%         for kk = 1:size(stimTimes{ii},2)
%             shiftedSp = periStim_selected{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
%             if ~isempty(shiftedSp)
%                 fr = zeros(size(bins));
%                 for mm = 1:length(bins)-1
%                     fr(mm) = length(shiftedSp(and(shiftedSp>=bins(mm)*1e-3,shiftedSp<(bins(mm+1)*1e-3))));
%                 end
%                 count = count + 1;
%                 frMat(count,:) = fr;     
%             end
%         end
%         listOfCounts{1,ii}{jj,1} = count; 
%         if count ==0, count=1; end
%         
%         %finding the right subplot position in a 6x10 array
%         ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
%         [row, col] = find(ch6x10_ch8x8_60 == jj);
%         pos = 6*(row-1) + col;
%         subplot(10,6,pos)
%         shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
%         axis([-100 500 -0.5 2.5])
%         line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
%         text(375,1.7,num2str(jj),'FontAngle','italic');
%         if ~or(mod(pos,6)==1,pos>54)
%             set(gca,'YTickLabel',[]);
%             set(gca,'XTickLabel',[]);
%         elseif pos>55
%             set(gca,'YTickLabel',[]);
%         elseif pos~=55
%             set(gca,'XTickLabel',[]);
%         end
%         set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
%      end
%         % Add a title to the whole plot
%         set(gcf,'NextPlot','add');
%         axes;
%         h = title(['Mean PSTHs following stimulation at ',num2str(stimSites(ii)+1),'(hw+1). [mean #spikes vs time(ms)]']);
%         set(gca,'Visible','off');
%         set(h,'Visible','on');
%         
% %         %print as a landscape eps figure
% %         h=gcf;
% %         set(h,'PaperPositionMode','auto'); 
% %         set(h,'PaperOrientation','landscape');
% %         set(h,'Position',[50 50 1200 800]);
% %         print(gcf, '-depsc', [fPath,datRoot,'_',num2str(stimSites(ii)+1),'.eps']); % hw+1
% end


%% Binning, averaging and plotting all the PSTHs
listOfCounts_all = cell(1,nStimSites);

for ii = 1:nStimSites
    psth_h = genvarname(['psth_',num2str(ii)]);
    eval([psth_h '= figure(', num2str(1+ii), ');']);
    handles(ii+1) = eval(psth_h);
    for jj = 1:60
        bins = -50: 10: 500;
        count = 0;
        frMat = zeros(2,length(bins));
        for kk = 1:size(stimTimes{ii},2)
            shiftedSp = periStim{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
            %if ~isempty(spikes)
                fr = zeros(size(bins));
                for mm = 1:length(bins)-1
                    fr(mm) = length(shiftedSp(and(shiftedSp>=bins(mm)*1e-3,shiftedSp<(bins(mm+1)*1e-3))));
                end
                count = count + 1;
                frMat(count,:) = fr;     
            %end
        end
        listOfCounts_all{1,ii}{jj,1} = count; 
        if count ==0, count=1; end
        
        %finding the right subplot position in a 6x10 array
        ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
        [row, col] = find(ch6x10_ch8x8_60 == jj);
        pos = 6*(row-1) + col;
        subplot(10,6,pos)
        shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
        axis([-100 500 -0.5 2.5])
        line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
        text(375,1.7,num2str(jj),'FontAngle','italic');
        if ~or(mod(pos,6)==1,pos>54)
            set(gca,'YTickLabel',[]);
            set(gca,'XTickLabel',[]);
        elseif pos>55
            set(gca,'YTickLabel',[]);
        elseif pos~=55
            set(gca,'XTickLabel',[]);
        end
        set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
     end
        % Add a title to the whole plot
        set(gcf,'NextPlot','add');
        axes;
        h = title(['Mean PSTHs following stimulation at ',num2str(cr2hw(stimSites(ii))+1),'(hw+1). [mean #spikes vs time(ms)]']);
        set(gca,'Visible','off');
        set(h,'Visible','on');
end

%% saving the figures
%saveFigs('stimAnalysis', datRoot,handles, stimSites);

%% Debuggin routines
%59 il stim um  16 il responses um nokkam
% art_bin = cell(60,1);
% for jj = 1:60
%     for kk = 1: length(stimTimes{5})
%         shiftedSp = periStim{5}{jj}{kk,1}-stimTimes{5}(1,kk);
%         art_bin{jj,1}{kk,1} = shiftedSp(and(shiftedSp>=0,shiftedSp<10*1e-3));
%     end
% end
% figure(13)
% for ii = 1:50
%     realTime = art_bin{16}{ii} + stimTimes{5}(ii);
%     for jj = 1:length(realTime)
%         indxOfSpk = find(and(spikes.time == realTime, spikes.channel==15));
%         subplot(5,10,ii)
%         plot(spikes.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(spikes.thresh(indxOfSpk)+mean(spikes.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end
% 
% figure(14)
% 
% for ii = 1:50
%     realTime = art_bin{16}{ii} + stimTimes{5}(ii);
%     for jj = 1:length(realTime)
%         lots = find(and(spikes.time ~= realTime, spikes.channel==12));
%         indxOfSpk = lots(1+ round(length(lots)*rand(1,1)));
%         subplot(5,10,ii)
%         plot(spikes.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(-spikes.thresh(indxOfSpk)+mean(spikes.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end
