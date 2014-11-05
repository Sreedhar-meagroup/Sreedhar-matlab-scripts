%% participation in spontaneous bursts
recCh = 40; %hw+1
SpikeTimes = spon_data.InAChannel{recCh}; %hw+1
Steps = 10.^[-5:.05:1.5];
N = 2;
valleyMinimizer_ms = HistogramISIn(SpikeTimes, N, Steps)
Spike.T = spon_data.InAChannel{recCh};
Spike.C = recCh*ones(size(Spike.T));
[Burst, BNum] = BurstDetectISIn(Spike, 3, 0.35);
disp(['Mean participation in SB: ', num2str(mean(Burst.S))]);
disp(['Std. dev of participation in SB: ', num2str(std(Burst.S))]);


%% response to stimuli
chosen_stimInd = 2;
resp_slices = stim_data.Responses.resp_slices{chosen_stimInd};
silence_s = stim_data.Silence_s{chosen_stimInd};
for ii = 1:50
    resp_length(ii) = length(find(resp_slices{ii}.channel == recCh-1));
end
disp(['Mean reponse length: ', num2str(mean(resp_length))]);
disp(['Std. dev of response length: ', num2str(std(resp_length))]);

sil_at_rc = silence_s(recCh,:);

figure;
box off;
plot(sil_at_rc, resp_length, '.');