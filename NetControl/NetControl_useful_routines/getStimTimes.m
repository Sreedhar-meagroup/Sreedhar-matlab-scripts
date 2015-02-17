function stimTimes = getStimTimes(spikes,nStimSites)
inAnalog  = cell(4,1);
stimTimes = cell(1,nStimSites);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end

for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end
