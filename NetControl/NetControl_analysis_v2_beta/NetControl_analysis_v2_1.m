% Aim: To analyze NetControl data in Experiments6, where the
% training and testing sessions were contiguous and recorded without interruption.

%% File selection and loading data
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(6,'net');
end
datRoot = datName(1:strfind(datName,'.')-1);
spikes  = loadspike([pathName,datName],2,25);
try
    thresh  = extract_thresh([pathName, datName, '.desc']);
catch
    str = inputdlg('Enter the MEABench threshold');
    thresh = str2num(str{1}); 
end


%% Stimulus times and location

stimTimes   = getStimTimes(spikes);
electrode_details = extract_elec_details([pathName,'config_files\train.cls']);

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into inAChannel cells

spks = cleaning_routines(spikes, stimTimes, electrode_details, thresh);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
[PID, CID] = getCultureDetails(pathName);
session_number = pathName(end-1);
%% Peri(-5ms<t<500ms) and post(t<500ms) stimulus spike times at the recording channel

recSite = electrode_details.rec_electrode;
stimSite = electrode_details.stim_electrode;
recSite_in_hwpo = cr2hw(recSite)+1;
stimSite_in_hwpo = cr2hw(stimSite)+1;

periStimAtRecSite = cell(length(stimTimes),1);
postStimAtRecSite = cell(length(stimTimes),1);
for ii = 1: size(stimTimes,2)
       periStimAtRecSite{ii} = inAChannel{recSite_in_hwpo}(and(inAChannel{recSite_in_hwpo}>stimTimes(ii)-0.05, inAChannel{recSite_in_hwpo}<stimTimes(ii)+0.5));
       postStimAtRecSite{ii} = inAChannel{recSite_in_hwpo}(and(inAChannel{recSite_in_hwpo}>stimTimes(ii), inAChannel{recSite_in_hwpo}<stimTimes(ii)+0.5));
end

%% Measuring pre-stimulus inactivity/periods of silence at the recording site

silence_s = zeros(size(stimTimes));
for jj = 1: size(stimTimes,2)
    previousTimeStamp = inAChannel{recSite_in_hwpo}(find(inAChannel{recSite_in_hwpo}<stimTimes(jj),1,'last'));
    if isempty(previousTimeStamp), previousTimeStamp = 0; end
    silence_s(jj) = (stimTimes(jj) - previousTimeStamp);
end

%% Response lengths (in no: of spikes)
respLengths_n = cellfun(@length, postStimAtRecSite);

%% Time discretization and burst criterion
    dt = 0.5
    disp('Message::Did you remember to set the right dt?');
    burst_criterion = 0.2
    disp('Message::Did you remember to set the right burst criterion?');
%% Collect log of number of stimuli in training and testing sessions
try
    nStimuliInEachSession = str2num(strtrim(fileread([pathName,'statistics\log_num_stimuli.txt'])));

catch err
    try 
        nStimuliInEachSession = str2num(strtrim(fileread([pathName,'\log_num_stimuli.txt'])));
    catch err
        disp('Warning:: log_num_stimuli file not found');
        nStimuliInEachSession = [];
        nSessions = [];
        totalStim = [];
        session_vector = []; 
    end
end

if ~isempty(nStimuliInEachSession)
    nSessions = size(nStimuliInEachSession,1);
    totalStim = repmat([300;200],3,1);
    session_vector = [0;cumsum(nStimuliInEachSession)]; % they are boundaries
end
%% Burst detection part

burst_detection = burstDetAllCh_sk(spks);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spks,burst_detection,10);
% harking back 50ms from the current NB onset definition and redefining onset boundaries.
mod_NB_onsets = zeros(length(NB_onsets),1);
for ii = 1:length(NB_onsets)
    if ~isempty(find(spks.time>NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2), 1))
        mod_NB_onsets(ii) = spks.time(find(spks.time >...
            NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2),1,'first'));
    else
        mod_NB_onsets(ii) = NB_onsets(ii,2);
    end
end
NB_slices = cell(length(mod_NB_onsets),1);

for ii = 1: length(mod_NB_onsets)
    NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
end

%% preparing the pre-spont path
pathName_preSpont = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\Spontaneous\';
preSpont_filenames = dir([pathName_preSpont,'*.spike']);
for ii = 1:numel(preSpont_filenames)
    if strfind(preSpont_filenames(ii).name,PID) & strfind(preSpont_filenames(ii).name,CID) & strfind(preSpont_filenames(ii).name,['preS',session_number])
        datName_preSpont = preSpont_filenames(ii).name;
    end
end


%% NetControl-Data structure
% NetControlData.fileName = datRoot;
NetControlData.Culture_details.PID = PID;
NetControlData.Culture_details.CID = CID;
NetControlData.Session_number = session_number;
NetControlData.Culture_details.MEA = '';
NetControlData.Culture_details.MEAtype = '';
NetControlData.Culture_details.Age = '';
NetControlData.discretization= dt;

NetControlData.Spikes = spks;
NetControlData.Electrode_details = electrode_details;
NetControlData.StimTimes = stimTimes;

NetControlData.InAChannel = inAChannel;

NetControlData.SessionInfo.nStimuliInEachSession = nStimuliInEachSession;
NetControlData.SessionInfo.nSessions = nSessions; 
NetControlData.SessionInfo.session_vector = session_vector;
NetControlData.Silence_s = silence_s;
NetControlData.RespLengths_n = respLengths_n;

NetControlData.burst_criterion = burst_criterion;

try
    NetControlData.Pre_spontaneous = spontaneousData('datName',datName_preSpont,'pathName',pathName_preSpont);
    disp('Loaded pre-spontaneous activity...');
catch err
    disp('Warning:: Could not find pre spontaneous file!')
    NetControlData.Pre_spontaneous = spontaneousData();
end

NetControlData.Pre_spontaneous.RecChannelBursts = bursts_at_RecSite(NetControlData.Pre_spontaneous.Spikes,[burst_criterion,burst_criterion,3],recSite_in_hwpo);

try
    NetControlData.Post_spontaneous = spontaneousData('datName','spon_after_testing.spike','pathName', pathName);
    disp('Loaded post-spontaneous activity...');
    NetControlData.Post_spontaneous.RecChannelBursts = bursts_at_RecSite(NetControlData.Post_spontaneous.Spikes,[burst_criterion,burst_criterion,3],recSite_in_hwpo);
catch err
    disp('Warning:: No post experiment spontaneous data available!');
    NetControlData.Post_spontaneous = [];
end
