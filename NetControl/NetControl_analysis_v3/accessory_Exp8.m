%% participation in spontaneous bursts
recCh = 58;
SpikeTimes = data.InAChannel{recCh}; %hw+1
Steps = 10.^[-5:.05:1.5];
N = 2;
valleyMinimizer_ms = HistogramISIn(SpikeTimes, N, Steps)
Spike.T = data.InAChannel{recCh};
Spike.C = recCh*ones(size(Spike.T));
[Burst, BNum] = BurstDetectISIn(Spike, 3, 1);
mean(Burst.S)
std(Burst.S)


%% response to stimuli
chosen_stimInd = 3;
% recCh = 17; %hw+1
for ii = 1:50
    resp_length(ii) = length(find(resp_slices{chosen_stimInd}{ii}.channel == recCh-1));
end