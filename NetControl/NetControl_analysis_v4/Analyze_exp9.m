%Netcontrol Experiments9

% Aim: To analyze NetControl data in Experiments9 


%% File selection and loading data
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(9,'net');
end
datRoot = datName(1:strfind(datName,'.')-1);
% spikes  = loadspike_noc_shortcutouts([pathName,datName],2,25);
spikes  = loadspike_sk([pathName,datName],2,25); 
% spikes  = loadspike_noc1_sk([pathName,datName],2,25); 
try
    thresh  = extract_thresh([pathName, datName, '.desc']);
catch
    str = inputdlg('Enter the MEABench threshold');
    thresh = str2num(str{1}); 
end

%% Stimulus times and location

stimTimes   = getStimTimes(spikes);
%electrode_details =
%extract_elec_details([pathName,'config_files\train.cls']); correct this
open([pathName,'config_files\config.yaml']);
sites = inputdlg('Enter stim site: rec site (in cr),separated by :',':');
sites = strsplit(strtrim(sites{1}),':');
electrode_details.description    = 'All electrodes are in cr(11 to 88)';
electrode_details.stim_electrodes = str2num(sites{1});%87;%14;
electrode_details.rec_electrodes  = str2num(sites{2});%62;%78;

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into inAChannel cells
% off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
% spikes_oc = spikes;
% spikes_oc.context = off_corr_contexts;
% [spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
% spks = blankArtifacts(spks,stimTimes,1);
% spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts

% no cleaning
spks = spikes; % to use when cleaning routines are not used
%  spks = cleaning_routines(spikes, stimTimes, electrode_details, thresh);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
[PID, CID] = getCultureDetails(pathName);

%% NetControlData structure
NetControlData.fileName = datRoot;
NetControlData.Culture_details.PID = PID;
NetControlData.Culture_details.CID = CID;
NetControlData.Culture_details.MEA = '';
NetControlData.Culture_details.MEAtype = '';
NetControlData.Culture_details.Age = '';

NetControlData.Spikes = spks;
NetControlData.Electrode_details = electrode_details;
NetControlData.StimTimes{1} = stimTimes;

NetControlData.InAChannel = inAChannel;
NetControlData.Responses.response_window = 0.5;

%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell structure.
% Layer 1 is a 60x1 cell, each corresponding to a channel
% Layer 2 is a nx1 cell, holding the periStim (-50 ms to +500 ms)spike stamps corresponding to each of the n stimuli.

% for the time being:
recSite = electrode_details.rec_electrodes;
stimSite = electrode_details.stim_electrodes;

periStim = cell(60,1);
for jj = 1: size(stimTimes,2)
    for kk = 1:60
        periStim{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes(jj)-0.05, inAChannel{kk}<stimTimes(jj)+0.5));
    end
end


%% Measuring pre-stimulus inactivity/periods of silence at the recording site
% silence_s has a matrix in a cell structure.
% Layer 1 (outer) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x50 matrix, each row corresponding to a channel and column
% corresponding to the 50 individual stimuli.

silence_s = zeros(size(stimTimes));
for jj = 1: size(stimTimes,2)
    previousTimeStamp = inAChannel{cr2hw(recSite)+1}(find(inAChannel{cr2hw(recSite)+1}<stimTimes(jj),1,'last'));
    if isempty(previousTimeStamp), previousTimeStamp = 0; end
    silence_s(jj) = (stimTimes(jj) - previousTimeStamp);
end


%% Response lengths (in no: of spikes)

periStimAtRecSite = periStim{cr2hw(recSite)+1};
postStimAtRecSite = cell(size(periStimAtRecSite));
respLengths_n = zeros(size(stimTimes));
for ii = 1: size(stimTimes,2)
    respLengths_n(ii) =  length(find(periStimAtRecSite{ii}>stimTimes(ii)));
    postStimAtRecSite{ii} = periStimAtRecSite{ii}(periStimAtRecSite{ii}>stimTimes(ii));
end


%% Burst detection part (optional)
NetworkBursts = sreedhar_ISI_threshold(spks);

%%
nStimuliInEachSession = str2num(strtrim(fileread([pathName,'\stimuli_per_episode.log'])));
nSessions = length(nStimuliInEachSession);
session_vector = [0;cumsum(nStimuliInEachSession)];

