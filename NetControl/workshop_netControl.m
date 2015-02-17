spks = ncdata.Spikes;
stimTimes = ncdata.StimTimes;
respwin = ncdata.Responses.response_window;
inrespwin_idx = arrayfun(@(x) find(spks.time>x & spks.time<=x+respwin),...
                                   stimTimes{1},'UniformOutput',false);
all_idx = 1:length(spks.time);
reduced_idx = setdiff(all_idx, [inrespwin_idx{:}]);

spks_wo_resp.time = spks.time(reduced_idx);
spks_wo_resp.channel = spks.channel(reduced_idx);

NBursts_wo_resp = sreedhar_ISI_threshold(spks_wo_resp);
mod_NB_onsets = NBursts_wo_resp.NB_extrema(:,1);
NB_ends = NBursts_wo_resp.NB_extrema(:,2);