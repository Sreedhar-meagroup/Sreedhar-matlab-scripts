spont_data = spontaneousData;

%took 4569 postS2
%take channel 57 (1-60) hw+1

SpikeTimes = spont_data.InAChannel{57}; %hw+1
Steps = 10.^[-5:.05:1.5];
N = 2;
valleyMinimizer_ms = HistogramISIn(SpikeTimes, N, Steps)
Spike.T = SpikeTimes;
Spike.C = 57*ones(size(Spike.T));
[Burst SpikeBurstNumber] = BurstDetectISIn( Spike, 3, valleyMinimizer_ms/1e3 );

burstDuration_s = Burst.T_end - Burst.T_start;
preBurstSil_s = Burst.T_start(2:end) - Burst.T_end(1:end-1);
nSpikesInBurst = Burst.S;



