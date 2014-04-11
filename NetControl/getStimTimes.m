function stimTimes = getStimTimes(spikes)
inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end
stimTimes = inAnalog{2};