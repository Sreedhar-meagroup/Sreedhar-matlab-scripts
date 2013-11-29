function spks = trimAnalogChannels(spks)
% Trims the analog channels(Ch: 59:63)from the MEABench spike data
% structure. Call only after extracting stimulation time data from the
% original struct. This needs to be done so that the raster plots are
% clean.

analogInd = find(spks.channel >= 60);
spks.time(analogInd)        = [];
spks.channel(analogInd)     = [];
spks.height(analogInd)      = [];
spks.width(analogInd)       = [];
spks.context(:,analogInd)   = [];
spks.thresh(analogInd)      = [];
end

