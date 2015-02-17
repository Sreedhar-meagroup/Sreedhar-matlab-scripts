function NetControlData = NetControlExp10(varargin)
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

%% setting parameter values
% defaults
Exp_no = 10; 
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

%% Stimulus locations and times
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site

electrode_details = extract_elec_details([pathName,'config_files\config.yaml']);
stimSites  = electrode_details.stim_electrodes; % in cr
recSites   = electrode_details.rec_electrodes;  % in cr
nStimSites = size(stimSites,2);
stimTimes  = getStimTimes(spikes,nStimSites);


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

[PID, CID] = getCultureDetails(pathName);

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


%%




%% preparing output data structure

NetControlData.fileName = datRoot;
NetControlData.Culture_details.PID = PID;
NetControlData.Culture_details.CID = CID;
NetControlData.Culture_details.MEA = '';
NetControlData.Culture_details.MEAtype = '';
NetControlData.Culture_details.Age = '';
NetControlData.Spikes = spks;
NetControlData.Electrode_details = electrode_details;
NetControlData.StimTimes = stimTimes;
NetControlData.InAChannel = inAChannel;
NetControlData.Responses.resp_slices = resp_slices;
NetControlData.Responses.resp_lengths = resp_lengths;
NetControlData.Responses.response_window = response_window;
NetControlData.Silence_s = silence_s;
