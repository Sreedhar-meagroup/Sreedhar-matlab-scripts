function stim_data = stimulatedData(varargin)
% stim_data = stimulatedData(varargin):
% INPUT Arguments (optional) as parameter, value pairs:
%     examples:
%       y = stimulatedData()
%       y = stimulatedData('Exp_no',9,'response_window', 0.6)
%       y = spontaneousData('Exp_no',9,'cleaning',false, 'context',false)
%       y = spontaneousData('Exp_no',9,'context',false,'cutout','short')
% see defaults for possible parameter value pairs
% OUTPUT Argument:
% Structure with fields...

%% Version info, aim
% -------------------------------------------------------------------------------------
% Purpose: Analyse stimulus responses

% Author: SK
% Date: 12.09.2014
%--------------------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b)
% MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
% ----------------------------------------------------------------------------------------------------

% defaults
Exp_no = 5; 
response_window = 0.5; %in s
cleaning = true;
context = true;
cutout = 'long';

if ~mod(nargin,2)
    pvpmod(varargin);
else
    disp('Check input arguments');
end



%% loading the file
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(Exp_no,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
if context
    if strcmpi(strtrim(cutout),'short')
        spikes = loadspike_shortcutouts([pathName,datName],2,25);
    else
        spikes = loadspike_sk([pathName,datName],2,25);
    end
else 
    if strcmpi(strtrim(cutout),'short')
        spikes = loadspike_noc_shortcutouts([pathName,datName],2,25);
    else
        spikes = loadspike_noc2_sk([pathName,datName],2,25);
    end
    cleaning  = false;
end
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


% prompt = {'Enter stim site/(s), sepatated by spaces or commas:','Enter rec site (if any):'};
% dlg_title = 'Input';
% num_lines = 1;
% str = inputdlg(prompt,dlg_title,num_lines);
% stimSites = str2num(strtrim(str{1}));
% recSites = str2num(strtrim(str{2}));

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
stimTimes   = getStimTimes(spikes,nStimSites);
electrode_details.description    = 'All electrodes are in cr(11 to 88)';
electrode_details.stim_electrodes = stimSites;
electrode_details.rec_electrodes  = recSites;
electrode_details.res_electrodes  = [];


%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells

if cleaning && context
  spks = cleaning_routines(spikes, stimTimes, electrode_details, thresh);
else
  spks = spikes;
end
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



%% preparing output data structure

stim_data.fileName = datRoot;
stim_data.Spikes = spks;
stim_data.Electrode_details.stim_electrodes = stimSites;
stim_data.Electrode_details.rec_electrodes = recSites;
stim_data.StimTimes = stimTimes;
stim_data.Responses.resp_slices = resp_slices;
stim_data.Responses.resp_lengths = resp_lengths;
stim_data.Responses.response_window = response_window;
stim_data.Silence_s = silence_s;
