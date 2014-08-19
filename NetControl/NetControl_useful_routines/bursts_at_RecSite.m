function RecChannel = bursts_at_RecSite(data, burst_para, recSite_in_hwpo)

burst_recSite = burstDetAllCh_sk(data, burst_para(1), burst_para(2), burst_para(3));

burstsInRecCh.onsets.time = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.onsets.idx  = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.ends.time  = zeros(length(burst_recSite{recSite_in_hwpo}),1);
burstsInRecCh.ends.idx   = zeros(length(burst_recSite{recSite_in_hwpo}),1);

burstsInRecCh.indices = [];
for ii = 1:length(burst_recSite{recSite_in_hwpo})
    burstsInRecCh.onsets.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(1);
    burstsInRecCh.ends.time(ii) = burst_recSite{recSite_in_hwpo}{ii,3}(end);

    burstsInRecCh.onsets.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(1);
    burstsInRecCh.ends.idx(ii) = burst_recSite{recSite_in_hwpo}{ii,4}(end);
    
    burstsInRecCh.indices = [burstsInRecCh.indices; burst_recSite{recSite_in_hwpo}{ii,4}(:)];
end

% No: of spikes per single channel burst
allLengths = cellfun(@length, burst_recSite{recSite_in_hwpo});
nSpikesperBurst = allLengths(:,3);

% Single channel IBI 
IBI_RecCh = zeros(size(burstsInRecCh.onsets.time));
IBI_RecCh(1) = burstsInRecCh.onsets.time(1);
IBI_RecCh(2:end) = burstsInRecCh.onsets.time(2:end) - burstsInRecCh.ends.time(1:end-1);

RecChannel.IBIs = IBI_RecCh;
RecChannel.nSpikesperBurst = nSpikesperBurst;
RecChannel.burstsInRecCh = burstsInRecCh;