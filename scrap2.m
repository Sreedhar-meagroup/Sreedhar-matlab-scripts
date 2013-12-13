
%% continously firing channels
chIchose = [50, 49];
for jj = chIchose
    inCh_outNBs.(sprintf('Ch%d',jj)) = inAChannel{jj};
    beforeEachNB.(sprintf('Ch%d',jj)) = cell(60,1);

    for ii = 1:length(mod_NB_onsets)
        inCh_outNBs.(sprintf('Ch%d',jj))(inCh_outNBs.(sprintf('Ch%d',jj)) >= mod_NB_onsets(ii) & inCh_outNBs.(sprintf('Ch%d',jj)) <= NB_ends(ii)) = [];
        if ii > 1
            beforeEachNB.(sprintf('Ch%d',jj)){ii} = inCh_outNBs.(sprintf('Ch%d',jj))(inCh_outNBs.(sprintf('Ch%d',jj)) < mod_NB_onsets(ii) & inCh_outNBs.(sprintf('Ch%d',jj)) > NB_ends(ii-1));
        else
            beforeEachNB.(sprintf('Ch%d',jj)){ii} = inCh_outNBs.(sprintf('Ch%d',jj))(inCh_outNBs.(sprintf('Ch%d',jj)) < mod_NB_onsets(ii));
        end

    end
end

sizeOfNB_s = NB_ends - mod_NB_onsets;
sizeOfpreNB_n(:,1) = cellfun(@length, beforeEachNB.Ch49);
sizeOfpreNB_n(:,2) = cellfun(@length, beforeEachNB.Ch50);

%% total number of spikes/ time before a burst
nSpikesBefNB = zeros(size(mod_NB_onsets));
for ii = 1:length(mod_NB_onsets)
    if ii > 1
        temp = find(spks.time <= mod_NB_onsets(ii) & spks.time > NB_ends(ii-1) );
    else
        temp = find(spks.time <= mod_NB_onsets(ii));
    end
    nSpikesBefNB(ii) = size(temp,2);
end

nSpBefPerIBI = nSpikesBefNB./IBIs;
figure(), plot(nSpBefPerIBI, sizeOfNB_s, '.')