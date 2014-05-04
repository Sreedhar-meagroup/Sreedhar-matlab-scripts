% Aim: To analyze NetControl data in Experiments6 onwards, where the
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

%% Time discretization
    dt = 0.5
    disp('Message::Did you remember to set the right dt?');

%% Collect log of number of stimuli in training and testing sessions
nStimuliInEachSession = str2num(strtrim(fileread([pathName,'statistics\log_num_stimuli.txt'])));
nSessions = size(nStimuliInEachSession,1);
totalStim = repmat([300;200],3,1);
session_vector = [0;cumsum(nStimuliInEachSession)]; % they are boundaries



%% NetControl-Data structure
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

NetControlData.SessionInfo.nStimuliInEachSession = nStimuliInEachSession;
NetControlData.SessionInfo.nSessions = nSessions; 
NetControlData.SessionInfo.session_vector = session_vector;
NetControlData.Silence_s = silence_s;
NetControlData.RespLengths_n = respLengths_n;

NetControlData.Pre_spontaneous = spontaneousData();
NetControlData.Post_spontaneous = spontaneousData('spon_after_testing.spike', pathName);
