function createCFPMat(spikes,maxT)
% cfp mat
% datName = [datRoot,'_spontaneous.spike'];
% spikes=loadspike(datName,2,25);
minT=0;  %% Considered time window limits in ms
cfprobability = zeros(60,60);
nSpikes=zeros(60,1);
% filepath = 'C:\Sreedhar\Mat_work\Closed_loop\NBS_CFP_mats\';

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
% save([filepath,datRoot,'_CFP_',num2str(maxT),'ms'],'cfprobability');




%% evoked cfp

minT=0;  %% Considered time window limits in ms
maxT = 30e-3;
cfprobability = cell(1,nStimSites);
final_cfp = cell(1,nStimSites);
for mm = 1:length(resp_slices)
    
    for nn = 1:50
    nSpikes=zeros(60,1);    
        for ii=0:59
            spikesInThisChannel = resp_slices{mm}{nn}.time(resp_slices{mm}{nn}.channel==ii);
            nSpikes(ii+1) = size(spikesInThisChannel,2);
            for jj = 0:59
               spikesInThatChannel = resp_slices{mm}{nn}.time(resp_slices{mm}{nn}.channel==jj);
               numOfRelevantSpikes = 0;
               for kk = 1:nSpikes(ii+1)
                   spikeTime = spikesInThisChannel(kk);
                   spikesInThatChannel = spikesInThatChannel - spikeTime;
                   relevantSpikes = spikesInThatChannel(and(spikesInThatChannel>minT,spikesInThatChannel<maxT));
                   spikesInThatChannel = spikesInThatChannel + spikeTime;
                   numOfRelevantSpikes = numOfRelevantSpikes + size(relevantSpikes,2);
               end
                cfprobability{mm}(ii+1,jj+1,nn) = numOfRelevantSpikes/(maxT*1e3/2*nSpikes(ii+1));
            end
        end 
         
    end
    disp(num2str(mm));
    cfprobability{mm}(isnan(cfprobability{mm})) = 0;
    final_cfp{mm} = mean(cfprobability{mm},3);
end

for ii = 1:nStimSites
    figure();
    imagesc(final_cfp{ii}), axis square;
    colorbar;
    title(['Conditional firing probability, stim:',num2str(cr2hw(stimSites(ii))+1)]);
    xlabel('Channel');
    ylabel('Channel');
    set(gca,'FontSize',14);
end


%% spont cfp

minT=0;  %% Considered time window limits in ms
maxT = 30e-3;
cfprobability = cell(1,5);
final_cfp = cell(1,5);
for mm = 1:5
    for nn = 1:Sp_corr.sortednNBs(mm)
    burst_ids = find(Sp_corr.LCEachBurst == Sp_corr.LCsorted(mm));
    nSpikes=zeros(60,1);    
        for ii=0:59
            spikesInThisChannel = NB_slices{burst_ids(nn)}.time(NB_slices{burst_ids(nn)}.channel==ii);
            nSpikes(ii+1) = size(spikesInThisChannel,2);
            for jj = 0:59
               spikesInThatChannel = NB_slices{burst_ids(nn)}.time(NB_slices{burst_ids(nn)}.channel==jj);
               numOfRelevantSpikes = 0;
               for kk = 1:nSpikes(ii+1)
                   spikeTime = spikesInThisChannel(kk);
                   spikesInThatChannel = spikesInThatChannel - spikeTime;
                   relevantSpikes = spikesInThatChannel(and(spikesInThatChannel>minT,spikesInThatChannel<maxT));
                   spikesInThatChannel = spikesInThatChannel + spikeTime;
                   numOfRelevantSpikes = numOfRelevantSpikes + size(relevantSpikes,2);
               end
                cfprobability{mm}(ii+1,jj+1,nn) = numOfRelevantSpikes/(maxT*1e3/2*nSpikes(ii+1));
            end
        end 
         
    end
    disp(num2str(mm));
    cfprobability{mm}(isnan(cfprobability{mm})) = 0;
    final_cfp{mm} = mean(cfprobability{mm},3);
end

for ii = 1:5
    figure();
    imagesc(final_cfp{ii}), axis square;
    colorbar;
    title(['Conditional firing probability, Spont hotspot:',num2str(LCsorted(ii))]);
    xlabel('Channel');
    ylabel('Channel');
    set(gca,'FontSize',14);
end
