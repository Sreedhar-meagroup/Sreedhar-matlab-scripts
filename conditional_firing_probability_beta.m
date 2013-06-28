 %datRoot = {'130311_4105'};%, '130311_4106', '130311_4108', '130312_4096', '130313_4107', '130313_4104'};
 
 for count = 1:size(datRoot,2)
%datName = '130311_4105_spontaneous.spike';
function condFiringProb(datRoot)
datName = [datRoot{count},'_spontaneous.spike'];
spikes=loadspike(datName,2,25);
s=zeros(60); %%60x60 matrix of connection strenghts
binSize=5; %% bin size in ms
minT=0;  %% Considered time window limits in ms
maxT=30;
binsVect=(minT:binSize:maxT)*25; %% Vector of bins limits in samples
nBins=length(binsVect);
%relativeTimings=zeros(60,60,nBins);
activity = zeros(60,60,nBins);
cfprobability = zeros(60,60);
elapsedTime=0;
nSpikes=zeros(60,1);
maxRelSpikes = 0;

for ii=0:59
    spikesInThisChannel = spikes.time(spikes.channel==ii);
    nSpikes(ii+1) = size(spikesInThisChannel,2);
    for jj = 0:59
       spikesInThatChannel = spikes.time(spikes.channel==jj);
       spikesHist = zeros(1,length(binsVect));
       numOfRelevantSpikes = 0;
       for kk = 1:nSpikes(ii+1)
           spikeTime = spikesInThisChannel(kk);
           spikesInThatChannel = spikesInThatChannel - spikeTime;
           relevantSpikes = spikesInThatChannel(and(spikesInThatChannel>minT*1e-3,spikesInThatChannel<maxT*1e-3));
%            binIndxs=floor((relevantSpikes-minT)/(maxT-minT)*nBins)+1;
%            for ll=1:length(binIndxs)
%                spikesHist(binIndxs(ll))=spikesHist(binIndxs(ll))+1;
%            end
           if size(relevantSpikes,2)>maxRelSpikes
               maxRelSpikes = size(relevantSpikes,2);
           end
           spikesInThatChannel = spikesInThatChannel + spikeTime;
           numOfRelevantSpikes = numOfRelevantSpikes + size(relevantSpikes,2);
       end
%         activity(ii+1,jj+1,:)=spikesHist;
%         activity(jj+1,ii+1,:)=fliplr(spikesHist);
        cfprobability(ii+1,jj+1) = numOfRelevantSpikes/(maxT/2*nSpikes(ii+1));
%         cfprobability(jj+1,ii+1) = cfprobability(ii+1,jj+1);
    end
end
cfprobability(isnan(cfprobability))=0;
figure(1)
imagesc(cfprobability), axis square, colorbar
% fpath = 'C:\Sreedhar\Lat_work\Closed_loop\misc';
% saveas(gcf, fullfile(fpath, [datRoot{count},'_cfp']), 'epsc');
save([datRoot{count},'_cfp'],'cfprobability');
%close all;
%clearvars -except datRoot count
 end   
 
 
