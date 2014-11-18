function data = fuse_sessions(spikes1,spikes2)

stimTimes_train = getStimTimes(spikes1); 
stimTimes_test   = getStimTimes(spikes2); 
nSessions = 2;
nStimuliInEachSession = [length(stimTimes_train); length(stimTimes_test)];

buffer = 25; %25s buffer between two spike trains
allfields = fieldnames(spikes1);

for ii = 1:length(allfields)
    if strcmpi(allfields{ii},'time')
        if isempty(spikes1.time), endtraining = 0; else endtraining = spikes1.time(end); end
        spikes.time = [spikes1.time, (spikes2.time+endtraining+buffer)];
    else
        spikes.(allfields{ii}) = [spikes1.(allfields{ii}), spikes2.(allfields{ii})];
    end
end
spikes.remark = ['Training and testnig spike trains fused with a ',num2str(buffer),'s buffer'];

data.Spikes = spikes;
data.StimTimes = [stimTimes_train, stimTimes_test];
data.nStimuliInEachSession = nStimuliInEachSession;
data.session_vector = [0;cumsum(data.nStimuliInEachSession)];
