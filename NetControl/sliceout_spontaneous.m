function SpontaneousData = sliceout_spontaneous(data, start_time, stop_time)
% sliceout_spontaneous slices out the spontaneous activity interleaved
% between training-testing session pairs in NetControl Experiment7
% Work in progress.

delta_t = 5; % in s
spks.time = data.time(data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);
spks.channel = data.channel(data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);
                                
spks.height = data.height(data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);
spks.width = data.width(data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);
spks.context = data.context(:,data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);
spks.thresh = data.thresh(data.time > start_time + delta_t ...
                                    & data.time < stop_time - delta_t);

inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
                   
                                
%% Burst detection
burst_detection = burstDetAllCh_sk(spks);
[~, ~, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk('',spks,burst_detection,10);
% harking back 50ms from the current NB onset definition and redefining onset boundaries.
mod_NB_onsets = zeros(length(NB_onsets),1);
for ii = 1:length(NB_onsets)
    if ~isempty(find(spks.time>NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2), 1))
        mod_NB_onsets(ii) = spks.time(find(spks.time >...
            NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2),1,'first'));
    else
        mod_NB_onsets(ii) = NB_onsets(ii,2);
    end
end
NB_slices = cell(length(mod_NB_onsets),1);
for ii = 1: length(mod_NB_onsets)
    NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
end           

IBIs = zeros(size(mod_NB_onsets));
IBIs(1) = mod_NB_onsets(1) - start_time;
IBIs(2:end) = mod_NB_onsets(2:end) - NB_ends(1:end-1);

%% creating output structure

SpontaneousData.fileName = 'NetControl slice';
SpontaneousData.Spikes = spks;
SpontaneousData.InAChannel = inAChannel;
SpontaneousData.NetworkBursts.NB_slices = NB_slices;
SpontaneousData.NetworkBursts.NB_extrema = [mod_NB_onsets, NB_ends];
SpontaneousData.NetworkBursts.IBIs = IBIs;
