if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(3,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike([pathName,datName],2,25);


%% Stimulus locations and time
%Get stim info into analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
% I do this before cleaning the spikes because I do not want to clean off
% the stim times in the analog channels.

inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end


% the following info shall in future versions automatically gathered from the log file...
% working on that script stim_efficacy.m


% rawText = fileread('C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\NetControl\PID317_CID4346\session_1_4346\session_1_4346.log');
% 
% stimSitePattern = 'The choice of the Stimulating: recording pair was made as (\d\d):(\d\d))';
% [matchedPattern matchedPatternIdx_start matchedPatternIdx_end ...
%     token_idx token_data] = regexp(rawText, stimSitePattern, 'match');
% stimSites = str2num(cell2mat(strtrim(token_data{1}))) % cr

str = inputdlg('Enter the stimulation site (in cr)');
stimSite = str2num(str{1}); % in cr
str = inputdlg('Enter the recording site (in cr)'); % in cr
recSite = str2num(str{1});
 

stimTimes = inAnalog{2};

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells
[spks, selIdx, rejIdx] = cleanspikes(spikes);
spks = blankArtifacts(spks,stimTimes,1);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end

%% Fig 1a: global firing rate
% sliding window; bin width = 100ms
[counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
figure(1); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');


%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell structure.
% Layer 1 is a 60x1 cell, each corresponding to a channel
% Layer 2 is a nx1 cell, holding the periStim (-50 ms to +500 ms)spike stamps corresponding to each of the n stimuli.
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


%% Response lengths (in time)


%% Response lengths (in no: of spikes)

periStimAtRecSite = periStim{cr2hw(recSite)+1};
respLengths_n = zeros(size(stimTimes));
for ii = 1: size(stimTimes,2)
    respLengths_n(ii) =  length(find(periStimAtRecSite{ii}>stimTimes(ii)));
end
