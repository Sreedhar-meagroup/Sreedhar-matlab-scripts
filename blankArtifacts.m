function bl_spks = blankArtifacts(spks,stimTimes,t)
%Function blankArtifacts blanks the stimulation artifacts t ms after a stimulation.
% INPUTS: spks -- the structure of spikes and channels
%         stimTimes --  the cell of stimulation times
%         t ms -- the blanking window
initialSize = size(spks.time,2);
if iscell(stimTimes)
    allStimTimes = [stimTimes{:}];
else
    allStimTimes = stimTimes;
end
ind2remove = cell(size(allStimTimes));


h = waitbar(0,'Blanking stimulus artifacts...');
for ii = 1:length(allStimTimes)
    tic;
    ind2remove{ii} = find(spks.time-allStimTimes(ii)>0 & spks.time-allStimTimes(ii)<t*1e-3);
    if ~mod(ii,100)
            waitbar(ii/length(allStimTimes))
    end
end
close(h);

rogueIndices = [ind2remove{:}];
spks.time(rogueIndices) = [];
spks.channel(rogueIndices) = [];
spks.height(rogueIndices) = [];
spks.width(rogueIndices) = [];
spks.context(:,rogueIndices) = [];
spks.thresh(rogueIndices) = [];

finalSize = size(spks.time,2);
bl_spks = spks;
disp(['Percentage of spikes blanked = ',num2str(100*(initialSize-finalSize)/initialSize),'%']);

end
