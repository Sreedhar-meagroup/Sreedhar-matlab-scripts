function stim_data = stimAnalysis_v4(varargin)
% stim_data = stimAnalysis_v4(varargin):
% INPUT Arguments, in the following order:
%     1. Experiment no. (optional);  default = 5
%     2. response_window in s (optional); default = 0.5s

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

% defaults
    Exp_no = 9; %default value;
    response_window = 0.5;
  
    if nargin    
        if isa(varargin{1},'double')
            Exp_no = varargin{1};
            pvpmod(varargin(2:end));
        elseif mod(nargin-1,2)
            pvpmod(varargin);
        else
            disp('Check input arguments');
        end
    end



%% loading the file
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(Exp_no,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes  = loadspike_sk([pathName,datName],2,25);
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
    recSites = [];
catch
    open([pathName,datRoot,'.log']);
    stimSitePattern = 'MEA)..?(\d\d)';
    [~,~,~,~,token_data] = regexp(rawText, stimSitePattern, 'match');
    % str = inputdlg('Enter the list of stim sites (in cr),separated by spaces or commas');
    % stimSites = str2num(str{1}); % in cr
    recSites  = str2num(cell2mat(strtrim(token_data{1}))); % cr
    stimSites = str2num(cell2mat(strtrim(token_data{2}))); % cr
    fprintf('Stim(cr): %d\n',stimSites) ;
    fprintf('Rec(cr) : %d\n',recSites) ;
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
% spks = spikes_oc; % comment in for unclean data
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
% [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh);
spks = blankArtifacts(spks,stimTimes,1);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end


%% Response slices
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



%% preparing general structure

stim_data.fileName = datRoot;
stim_data.Spikes = spks;
stim_data.Electrode_details.stim_electrodes = stimSites;
stim_data.Electrode_details.rec_electrodes = recSites;
stim_data.StimTimes = stimTimes;
stim_data.Responses.resp_slices = resp_slices;
stim_data.Responses.resp_lengths = resp_lengths;
stim_data.Responses.response_window = response_window;
stim_data.Silence_s = silence_s;
