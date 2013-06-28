function createCFPMat(datRoot,maxT)
% cfp mat
datName = [datRoot,'_spontaneous.spike'];
spikes=loadspike(datName,2,25);
minT=0;  %% Considered time window limits in ms
cfprobability = zeros(60,60);
nSpikes=zeros(60,1);
filepath = 'C:\Sreedhar\Mat_work\Closed_loop\NBS_CFP_mats\';

for ii=0:59
    spikesInThisChannel = spikes.time(spikes.channel==ii);
    nSpikes(ii+1) = size(spikesInThisChannel,2);
    for jj = 0:59
       spikesInThatChannel = spikes.time(spikes.channel==jj);
       numOfRelevantSpikes = 0;
       for kk = 1:nSpikes(ii+1)
           spikeTime = spikesInThisChannel(kk);
           spikesInThatChannel = spikesInThatChannel - spikeTime;
           relevantSpikes = spikesInThatChannel(and(spikesInThatChannel>minT*1e-3,spikesInThatChannel<maxT*1e-3));
           spikesInThatChannel = spikesInThatChannel + spikeTime;
           numOfRelevantSpikes = numOfRelevantSpikes + size(relevantSpikes,2);
       end
        cfprobability(ii+1,jj+1) = numOfRelevantSpikes/(maxT/2*nSpikes(ii+1));
    end
end
cfprobability(isnan(cfprobability))=0;
save([filepath,datRoot,'_CFP_',num2str(maxT),'ms'],'cfprobability');
