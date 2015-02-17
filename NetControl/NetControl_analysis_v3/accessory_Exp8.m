%% participation in spontaneous bursts
recCh = 53; %hw+1
SpikeTimes = spon_data.InAChannel{recCh}; %hw+1
Steps = 10.^[-5:.05:1.5];
N = 2;
valleyMinimizer_ms = HistogramISIn(SpikeTimes, N, Steps)
Spike.T = spon_data.InAChannel{recCh};
Spike.C = recCh*ones(size(Spike.T));
[Burst, BNum] = BurstDetectISIn(Spike, 3, 0.7);
disp(['Mean participation in SB: ', num2str(mean(Burst.S))]);
disp(['Std. dev of participation in SB: ', num2str(std(Burst.S))]);

lenInNB = cellfun(@(x) length(find(x.channel == recCh-1)),spon_data.NetworkBursts.NB_slices);
figure; subplot(211)
hist(lenInNB,0:max(lenInNB));
box off;
set(gca,'TickDir','Out');
xlabel('No: of spikes')
ylabel('Probability');
title(['Distribution of spikes in spontaneous bursts (Ch:', num2str(hw2cr(recCh-1)),')']);


%% response to stimuli
chosen_stimInd = 5;
resp_slices = stim_data.Responses.resp_slices{chosen_stimInd};
silence_s = stim_data.Silence_s{chosen_stimInd};
for ii = 1:size(stim_data.StimTimes{chosen_stimInd},2)
    resp_length(ii) = length(find(resp_slices{ii}.channel == recCh-1));
end
disp(['Mean reponse length: ', num2str(mean(resp_length))]);
disp(['Std. dev of response length: ', num2str(std(resp_length))]);

sil_at_rc = silence_s(recCh,:);

subplot(212)
% figure;
plot(sil_at_rc, resp_length, '.','MarkerSize',12);
box off;
set(gca,'TickDir','Out');
xlabel('Pre-stimulus inactivity [s]');
ylabel('Response length');
title(['Ch:', num2str(hw2cr(recCh-1))])