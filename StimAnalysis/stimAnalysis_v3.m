%% Version info, aim
% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site

% Author: Sreedhar S Kumar
% Date: 27.06.2013
%--------------------------------------------------------------------------------------
% MATLAB Version 7.12.0.635 (R2011a)
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------

%% loading the file
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(5,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike([pathName,datName],2,25);
thresh  = extract_thresh([pathName, datName, '.desc']);
handles = zeros(1,7);

%% Stimulus locations and time
%Get stim info into analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
% I do this before cleaning the spikes because I do not want to clean off
% the stim times in the analog channels.

inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end


rawText = fileread([pathName,datRoot,'.log']);
stimSitePattern = 'MEA style: ([\d\d ]+)';
[~,~,~,~,token_data] = regexp(rawText, stimSitePattern, 'match');
stimSites = str2num(cell2mat(strtrim(token_data{1}))) % cr
nStimSites = size(stimSites,2);

% str = inputdlg('Enter the list of stim sites (in cr),separated by spaces or commas');
% stimSites = str2num(str{1}); % in cr

 stimTimes = cell(1,5);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end


%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells
%Introducing dc offset correction
off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
spikes_oc = spikes;
spikes_oc.context = off_corr_contexts;
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
% [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh);
spks = blankArtifacts(spks,stimTimes,1);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end

%% Fig 1a: global firing rate
% sliding window; bin width = 100ms
[counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
handles(1)= figure(); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 0.1s)');
set(gca,'TickDir','Out');

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

% another form -- cell of cell array of structures
%resp_slices{site no:}{stimulation no:}.time/channel

resp_slices = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        resp_slices{ii}{jj}.time = spks.time(and(spks.time>stimTimes{ii}(jj)-0.05, spks.time<stimTimes{ii}(jj)+0.5));
        resp_slices{ii}{jj}.channel = spks.channel(and(spks.time>stimTimes{ii}(jj)-0.05, spks.time<stimTimes{ii}(jj)+0.5));
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
% periStim_selected = cell(size(periStim));
% tSilence_s = 1;
% for ii = 1:nStimSites
%     [validRows, validCols] = find(silence_s{ii}>tSilence_s);
%     for jj = 1: size(validRows,1)
%         periStim_selected{ii}{validRows(jj),1}{validCols(jj),1} = periStim{ii}{validRows(jj)}{validCols(jj)};
%     end
%     
% % fixed a bug in retrospective
% % If by chance a channel did not have a valid response in the 50th trial,
% % that cell array would remain of length 49. There could be a more elegant
% % solution. But this patch works for the moment. buggyLength is the index of
% % such aberrant channels. diffLen is the deficit in length which is then
% % appropriately compensated.
%     
%         buggyLengths = find(cellfun(@length,periStim_selected{ii})<50);
%         if buggyLengths
%             for kk = 1:length(buggyLengths)
%                 diffLen = length(stimTimes{ii}) - length(periStim_selected{ii}{buggyLengths(kk)});
%                 periStim_selected{ii}{buggyLengths(kk)}{end+diffLen} = [];
%             end
%         end
% end


%% Fig 1b: General raster
figure(handles(1)); 
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
joined_ch = [];
for ii = 1:nStimSites
    switch ii
        case 1
            clr = 'r';
            joined_ch = strcat(joined_ch,'{\color{red}',num2str(cr2hw(stimSites(ii))+1),' }');
        case 2
            clr = 'g';
            joined_ch = strcat(joined_ch,'{\color{green}',num2str(cr2hw(stimSites(ii))+1),' }');
        case 3
            clr = 'c';
            joined_ch = strcat(joined_ch,'{\color{cyan}',num2str(cr2hw(stimSites(ii))+1),' }');
        case 4
            clr = 'k';
            joined_ch = strcat(joined_ch,'{\color{black}',num2str(cr2hw(stimSites(ii))+1),' }');
        case 5
            clr = 'm';
            joined_ch = strcat(joined_ch,'{\color{magenta}',num2str(cr2hw(stimSites(ii))+1),' }');
    end
% patch([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
plot(stimTimes{ii},cr2hw(stimSites(ii))+1,[clr,'*']);

% code for the tiny rectangle (500 ms)
Xcoords = [stimTimes{ii};stimTimes{ii};stimTimes{ii}+0.5;stimTimes{ii}+0.5];
Ycoords = 60*repmat([0;1;1;0],size(stimTimes{ii}));
patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.2);
end
rasterplot_so(spks.time,spks.channel,'b-');
hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
set(gca,'YMinorGrid','On');

title(['Raster plot indicating stimulation at channels [',joined_ch,'] (hw+1)']);
zoom xon;
pan xon;
%% Binning, averaging and plotting the PSTHs 
%with 1s pre-stim silence
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

% Comment in/out from here downwards:

% Binning, averaging and plotting all the PSTHs
listOfCounts_all = cell(1,nStimSites);
binSize = 10;
for ii = 1:nStimSites
    psth_h = genvarname(['psth_',num2str(ii)]);
    eval([psth_h '= figure();']);%, num2str(1+ii), ');']);
    handles(ii+1) = eval(psth_h);
    psth_sp_h = zeros(1,60); %psth subplot handles
    max_axlim = 0;
    for jj = 1:60
        bins = -50: binSize: 500;
        count = 0;
        frMat = zeros(size(stimTimes{ii},2),length(bins));
        for kk = 1:size(stimTimes{ii},2)
            shiftedSp = periStim{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
            %if ~isempty(spks)
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
        
        psth_sp_h(jj) = subplot(10,6,pos);
        shadedErrorBar(bins+binSize/2,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
%         shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
%         axis([-50 500 -0.5 1])
        
        line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
        if jj == cr2hw(stimSites(ii))+1
            text(375,0.5,num2str(jj),'FontAngle','italic','Color',[1,0,0]);
        else
            text(375,0.5,num2str(jj),'FontAngle','italic');
        end
        
%         if ~or(mod(pos,6)==1,pos>54)
%             set(gca,'YTickLabel',[]);
%             set(gca,'XTickLabel',[]);
%         elseif pos>55
%             set(gca,'YTickLabel',[]);
%         elseif pos~=55
%             set(gca,'XTickLabel',[]);
%         end
        set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
        set(gcf,'WindowStyle','docked');

        if max(mean(frMat)+std(frMat)) > max_axlim
            max_axlim =  max(mean(frMat)+std(frMat));
        end
    end
    linkaxes(psth_sp_h);
    axis([-50 500 -0.5 max_axlim]);
    [ax1,h1]=suplabel('time[ms]');
    set(h1,'FontSize',16);
    [ax2,h2]=suplabel('Mean #spikes','y');
    set(h2,'FontSize',16);
    [ax4,h3]=suplabel(['PSTH (stimulation at ',num2str(stimSites(ii)),'^{cr} / ',num2str(cr2hw(stimSites(ii))+1),'^{hw+1})'],'t');
    set(h3,'FontSize',16);
 %  set(h3,'FontSize',30)
%     % Add a title to the whole plot
%         set(gcf,'NextPlot','add');
%         axes;
%         h = title(['PSTHs following stimulation at ',num2str(stimSites(ii)),' / ',num2str(cr2hw(stimSites(ii))+1),' cr/(hw^{+1}). [mean #spikes vs time(ms)]']);
%         set(gca,'Visible','off');
%         set(h,'Visible','on');
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
%         indxOfSpk = find(and(spks.time == realTime, spks.channel==15));
%         subplot(5,10,ii)
%         plot(spks.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(spks.thresh(indxOfSpk)+mean(spks.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end
% 
% figure(14)
% 
% for ii = 1:50
%     realTime = art_bin{16}{ii} + stimTimes{5}(ii);
%     for jj = 1:length(realTime)
%         lots = find(and(spks.time ~= realTime, spks.channel==12));
%         indxOfSpk = lots(1+ round(length(lots)*rand(1,1)));
%         subplot(5,10,ii)
%         plot(spks.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(-spks.thresh(indxOfSpk)+mean(spks.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end



%% preparing structure to send to function plt_resp2stim()

stimEfficacy_data.recording = spks;
stimEfficacy_data.stimTimes = stimTimes;
stimEfficacy_data.stimSites = stimSites;

plt_resp2stim(5,stimEfficacy_data);


