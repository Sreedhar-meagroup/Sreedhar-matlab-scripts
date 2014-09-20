function stim_data = stimAnalysis_v4(varargin)
% stim_data = stimAnalysis_v4(varargin):
% INPUT Arguments, in the following order:
%     1. Experiment no. (optional);  default = 5
%     2. response_window in s; default = 0.5s

%% Version info, aim
% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site

% Author: Sreedhar S Kumar
% Date: 12.09.2014
%--------------------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b)
% MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
% ----------------------------------------------------------------------------------------------------


switch nargin
    case 0    
        Exp_no = 5; %default value;
        response_window = 0.5;
        plotID = '';
    case 1
        Exp_no = varargin{1};
        response_window = 0.5;
        plotID = '';
    case 2
        [Exp_no, response_window] = varargin{:};
        plotID = ''; %default value;
    case 3
        [Exp_no, response_window, plotID] = varargin{:};
    otherwise
        disp('Check input arguments');
end

%% loading the file
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(Exp_no,'st');
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

try
rawText = fileread([pathName,datRoot,'.log']);
stimSitePattern = 'MEA style: ([\d\d ]+)';
[~,~,~,~,token_data] = regexp(rawText, stimSitePattern, 'match');
stimSites = str2num(cell2mat(strtrim(token_data{1}))) % cr
catch
open([pathName,datRoot,'.log']);
str = inputdlg('Enter the list of stim sites (in cr),separated by spaces or commas');
stimSites = str2num(str{1}); % in cr
end
nStimSites = size(stimSites,2);
stimTimes = cell(1,nStimSites);
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
% [counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
% handles(1)= figure(); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
% axis tight; ylabel('# spikes'); title('Global firing rate (bin= 0.1s)');
% set(gca,'TickDir','Out');


% binSize = 0.1;
% handles(1)= figure();
% [counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
% fig1ha(1) = subplot(3,1,1); bar(timeVec,counts/binSize); box off; 
% set(gca,'XTick',[]);
% set(gca,'TickDir','Out');
% axis tight; ylabel('Global firing rate [Hz]'); 

%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell in a cell structure.
% Layer 1 (outer cell) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x1 cell, each corresponding to a channel
% Layer 3 is a 50x1 cell, holding the periStim spike stamps corresponding to each of the 50 stimuli.
periStim = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            periStim{ii}{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes{ii}(jj)-0.05, inAChannel{kk}<stimTimes{ii}(jj)+response_window));
        end
    end
end

% another form -- cell of cell array of structures
%resp_slices{site no:}{stimulation no:}.time/channel

resp_slices = cell(1,nStimSites);
resp_lengths = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        resp_slices{ii}{jj}.time = spks.time(and(spks.time>stimTimes{ii}(jj), spks.time<stimTimes{ii}(jj)+response_window));
        resp_slices{ii}{jj}.channel = spks.channel(and(spks.time>stimTimes{ii}(jj), spks.time<stimTimes{ii}(jj)+response_window));
        resp_lengths{ii}(:,jj) = hist(resp_slices{ii}{jj}.channel,0:59);
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


%% Fig 1b: General raster
% figure(handles(1)); 
% fig1ha(2) = subplot(3,1,2:3);
% linkaxes(fig1ha, 'x');
% hold on;
% joined_ch = [];
% for ii = 1:nStimSites
%     switch ii
%         case 1
%             clr = 'r';
%             joined_ch = strcat(joined_ch,'{\color{red}',num2str(cr2hw(stimSites(ii))+1),' }');
%         case 2
%             clr = 'g';
%             joined_ch = strcat(joined_ch,'{\color{green}',num2str(cr2hw(stimSites(ii))+1),' }');
%         case 3
%             clr = 'c';
%             joined_ch = strcat(joined_ch,'{\color{cyan}',num2str(cr2hw(stimSites(ii))+1),' }');
%         case 4
%             clr = 'k';
%             joined_ch = strcat(joined_ch,'{\color{black}',num2str(cr2hw(stimSites(ii))+1),' }');
%         case 5
%             clr = 'm';
%             joined_ch = strcat(joined_ch,'{\color{magenta}',num2str(cr2hw(stimSites(ii))+1),' }');
%     end
% plot(stimTimes{ii},cr2hw(stimSites(ii))+1,[clr,'.']);
% 
%     for jj = 1:length(stimTimes{ii})
%         Xcoords = [stimTimes{ii}(jj);stimTimes{ii}(jj);stimTimes{ii}(jj)+0.5;stimTimes{ii}(jj)+response_window];
%         Ycoords = 61*[0;1;1;0];
%         patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.2);
%     end
% 
% end
% rasterplot_so(spks.time,spks.channel,'b-');
% hold off;
% set(gca,'TickDir','Out');
% xlabel('Time (s)');
% ylabel('Channel #');
% set(gca,'YMinorGrid','On');
% title(['Raster plot indicating stimulation at channels [',joined_ch,'] (hw+1)']);
% zoom xon;
% pan xon;

%% Plotting the PSTHs
if ~strcmpi(strtrim(plotID), 'noplots')
% Binning, averaging and plotting all the PSTHs
listOfCounts_all = cell(1,nStimSites);
% binSize = 50; % in ms
binSize = 15; % in ms
for ii = 1:nStimSites
    psth_h = genvarname(['psth_',num2str(ii)]);
    eval([psth_h '= figure();']);%, num2str(1+ii), ');']);
    handles(ii+1) = eval(psth_h);
    psth_sp_h = zeros(1,60); %psth subplot handles
    max_axlim = 0;
    for jj = 1:60
        bins = -50: binSize: response_window*1e3;
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
    axis([-50 response_window*1e3 -0.5 max_axlim]);
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
end
%% saving the figures
%saveFigs('stimAnalysis', datRoot,handles, stimSites);

%% preparing structure to send to function plt_resp2stim()

stim_data.fileName = datRoot;
stim_data.Spikes = spks;
stim_data.Electrode_details.stim_electrodes = stimSites;
stim_data.Electrode_details.rec_electrodes = [];
stim_data.StimTimes = stimTimes;
stim_data.Responses.resp_slices = resp_slices;
stim_data.Responses.resp_lengths = resp_lengths;
stim_data.Responses.response_window = response_window;
stim_data.Silence_s = silence_s;
% plt_resp2stim(5,stim_data);
