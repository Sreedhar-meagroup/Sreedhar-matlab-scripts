function bl_spks = blankArtifacts(spks,stimTimes,t)
%Function blankArtifacts blanks the stimulation artifacts t ms after a stimulation.
% INPUTS: spks -- the structure of spikes and channels
%         stimTimes --  the cell of stimulation times
%         t ms -- the blanking window
initialSize = size(spks.time,2);
allStimTimes = [stimTimes{:}];
for ii = 1:length(allStimTimes)
    ind2remove = find(spks.time-allStimTimes(ii)>0 & spks.time-allStimTimes(ii)<t*1e-3);
    spks.time(ind2remove) = [];
    spks.channel(ind2remove) = [];
    spks.height(ind2remove) = [];
    spks.width(ind2remove) = [];
    spks.context(:,ind2remove) = [];
    spks.thresh(ind2remove) = [];
end
finalSize = size(spks.time,2);
bl_spks = spks;
disp(['Percentage of spikes blanked = ',num2str(100*(initialSize-finalSize)/initialSize),'%']);