NB_widths = NB_ends - mod_NB_onsets;

exp_decay = zeros(100,50-1);
exp_growth = zeros(100,50-1);
lastDecay = 1;
lastGrowth = 1;
for ii = 1:50-1
    decay_t = linspace(mod_NB_onsets(ii),NB_ends(ii),100) - mod_NB_onsets(ii);
    exp_decay(:,ii) = lastGrowth*exp(-(decay_t));
    lastDecay = exp_decay(end,ii);
    growth_t = linspace(NB_ends(ii), mod_NB_onsets(ii+1),100) - NB_ends(ii);
    exp_growth(:,ii) = lastDecay+(1-exp(-(growth_t)));
    lastGrowth = exp_growth(end,ii);
end

final_vec = [];
final_time = [];
for ii = 1:50-1
    final_vec = [final_vec;exp_decay(:,ii);exp_growth(:,ii)];
    final_time = [final_time; linspace(mod_NB_onsets(ii),NB_ends(ii),100)'; linspace(NB_ends(ii),mod_NB_onsets(ii+1),100)'];
end

pred_NB_widths = NaN(size(NB_widths));
for ii = 1:length(NB_widths)-1
    pred_NB_widths(ii+1) = max(NB_widths)*((max(NB_widths)-NB_widths(ii))/max(NB_widths) - exp(-IBIs(ii+1)));
    if pred_NB_widths(ii+1)<0
        pred_NB_widths(ii+1) = min(NB_widths);
    end
end

%% learning input = 50  random bursts
learn_IBIs = IBIs(1:50);

% one channel in NBs
% for 4346_spontaneous2, let us choose ch: 26(hw+1)
ch = 26;
NBpart_ch = zeros(length(NB_ends),1);
for ii = 1:length(NB_ends)
    NBpart_ch(ii) = length(find(NB_slices{1}.channel == ch-1));
end

    
%% spectral analysis

Fs = 1;
T = 1/Fs;
L = length(preNB_period);
t = (0:L-1)*T;
figure(); plot(Fs*t,preNB_period);
title('The variations in NB widths (ms)')
xlabel('NB index#')

NFFT = 2^nextpow2(L);
spInfo = fft(preNB_period,NFFT)/L;
freq = Fs/2*linspace(0,1,NFFT/2+1);

figure();
% Plot single sided amplitude spectrum
plot(freq,2*abs(spInfo(1:NFFT/2+1)));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
