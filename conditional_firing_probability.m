% clear all;
datname = '130311_4108_spontaneous.spike';
spikes=loadspike(datname,2,25);
%spikes=loadSpikesData;

s=zeros(60); %%60x60 matrix of connection strenghts
binSize=5; %% bin size in ms
minT=-100;  %% Considered time window limits in ms
maxT=100;
binsVect=(minT:binSize:maxT)*10; %% Vector of bins limits in samples
nBins=length(binsVect);
relativeTimings=zeros(60,60,nBins);
activity=zeros(60,60,nBins);

elapsedTime=0;
nSpikes=zeros(60,1);
for i=1:60
    tic
    spikes1=spikes(spikes(:,1)==i,:);
    nSpikes(i)=size(spikes1,1); 
    for j=i:60
        spikes2=spikes(spikes(:,1)==j,:);
        spikesHist=zeros(1,length(binsVect));
        for n=1:nSpikes(i)
            spikeTime=spikes1(n,2);
            spikes2(:,2)=spikes2(:,2)-spikeTime;
            relevantSpikes=spikes2(and(spikes2(:,2)>minT*10,spikes2(:,2)<maxT*10),:);
%             spikesHist=spikesHist+hist(relevantSpikes(:,2),binsVect);
            binIndxs=floor((relevantSpikes(:,2)/10-minT)/(maxT-minT)*nBins)+1;
            for m=1:length(binIndxs)
                spikesHist(binIndxs(m))=spikesHist(binIndxs(m))+1;
            end                
            spikes2(:,2)=spikes2(:,2)+spikeTime;
        end
        activity(i,j,:)=spikesHist;
        activity(j,i,:)=fliplr(spikesHist);
        relativeTimings(i,j,:)=spikesHist/nSpikes(i);
    end
    [num2str(i),'\',num2str(60)]
    elapsedTime=elapsedTime+toc;
    ['Estimated time to completion is ',num2str((60-i)*elapsedTime/i),' seconds']
    pause(.001);
end
timeBaricenter=sum(relativeTimings.*repmat(reshape(binsVect,1,1,nBins),[60,60,1]),3)./sum(relativeTimings,3);
timeBaricenter(isnan(timeBaricenter))=0;
timeBaricenter=timeBaricenter-timeBaricenter';
s=sum(relativeTimings,3);
s=s+s';
%Few lines added here.
for i = 1: size(s,1)
    s(i,i) = s(i,i)/2;
end
s(isnan(s))=0;
strengths = sum(s);
[sorted indices]=sort(strengths,'descend');
my_Indices = indices(1:10)
my_Coords = elInd2Coords(my_Indices)
%--------------------
% s2=reshape(s,60*60,1);
% [s2,strongC]=sort(s2,1,'descend');
% strongC=strongC(1:100);
% r=mod(strongC,60);
% c=ceil(strongC/60);
% for i=1:length(r)
%     [source(i,1),source(i,2)]=elInd2Coords(r(i));
%     [dest(i,1),dest(i,2)]=elInd2Coords(c(i));
% end
% quiver(source(:,1),source(:,2),dest(:,1)-source(:,1),dest(:,2)-source(:,2),0,'LineWidth',2);

% b=zeros(1,1001);
% b(1:16)=1;
% b(17)=2/3;
% b=b/sum(b);
% B=conj(fft(b))';
% binnedTimings=zeros(60,60,60);
% for i=1:60
%     for j=1:60
%         tempTimings=squeeze(relativeTimings(i,j,:));
%         tempTimings=ifft(fft(tempTimings).*B);
%         tempTimings=downsample(tempTimings,floor(1001/60));
%         binnedTimings(i,j,:)=tempTimings(1:60);
%     end
% end

% nBins=250;
% binnedTimings=zeros(60,60,nBins);
% for i=1:60
%     for j=1:60
%         binnedTimings(i,j,:)=resample(relativeTimings(i,j,:),nBins,1001);
%     end
% end

save conditional_firing_probability
    