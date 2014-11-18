function NetControlData = Exp3datahandling(NetControlData)

recSite = NetControlData.Electrode_details.rec_electrode;
stimSite = NetControlData.Electrode_details.stim_electrode;
stimTimes = NetControlData.StimTimes;
inAChannel = NetControlData.InAChannel;
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
%% Response lengths (in no: of spikes)

periStimAtRecSite = periStim{cr2hw(recSite)+1};
respLengths_n = zeros(size(stimTimes));
for ii = 1: size(stimTimes,2)
    respLengths_n(ii) =  length(find(periStimAtRecSite{ii}>stimTimes(ii)));
end

%% Response lengths (in time)
respBurst = cell(size(stimTimes));
respLengths_ms = zeros(size(stimTimes));
for ii = 1:size(stimTimes,2)
    temp = periStimAtRecSite{ii};
    if isempty(temp), continue; end
    
    ISI = diff(temp);
    breach = find(ISI>=0.1,1,'first');
    if isempty(breach)
        respBurst{ii} = temp;
    else
        respBurst{ii} = temp(1:breach);
        if ISI(breach)<= 0.2
            respBurst{ii}(end+1) = temp(breach+1);
        end
    end
    respLengths_ms(ii) =  (respBurst{ii}(end) - stimTimes(ii))*1e3;
end
%% peristim long at recording site
periStimAtRecSite_long = periStim{cr2hw(recSite)+1};


%% Burst detection part

% burst_detection = burstDetAllCh_sk(spks);
% [bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
%     = Networkburst_detection_sk(datName,spks,burst_detection,10);
% % harking back 50ms from the current NB onset definition and redefining onset boundaries.
% mod_NB_onsets = zeros(length(NB_onsets),1);
% for ii = 1:length(NB_onsets)
%     if ~isempty(find(spks.time>NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2), 1))
%         mod_NB_onsets(ii) = spks.time(find(spks.time >...
%             NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2),1,'first'));
%     else
%         mod_NB_onsets(ii) = NB_onsets(ii,2);
%     end
% end
% NB_slices = cell(length(mod_NB_onsets),1);
% inNB_time =[];
% inNB_channel =[];
% for ii = 1: length(mod_NB_onsets)
%     NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
%     NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
%     inNB_time = [inNB_time, NB_slices{ii}.time];
%     inNB_channel = [inNB_channel, NB_slices{ii}.channel];
% end
% [outNB_time, outIndices] = setdiff(spks.time, inNB_time);
% outNB_channel = spks.channel(outIndices);

%% 
NetControlData.Silence_s = silence_s;
NetControlData.RespLengths_n = respLengths_n;