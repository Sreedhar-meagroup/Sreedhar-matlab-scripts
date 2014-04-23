
spks = pre_spont.Spikes;
binSize = 0.5;
[counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
counts1 = smooth(counts,51,'lowess');


figure();
bar(timeVec(1:1000),counts(1:1000)/binSize); box off;hold on
plot(timeVec(1:1000), counts1(1:1000)/binSize,'r','LineWidth',2);
axis tight;
set(gca,'TickDir','Out');
ylabel('Global firing rate [Hz]','FontSize',14);
xlabel('Time [s]','FontSize',14);

counts2 = counts1 - mean(counts1);

Fs = 1/binSize;
T = 1/Fs;
L = length(counts2);
t = (0:L-1)*T;
figure(); plot(t,counts2,'r','LineWidth',2);
xlabel('Time [s]'); box off;
title('smoothed DC corrected signal');

NFFT = 2^nextpow2(L);
spInfo = fft(counts2,NFFT)/L;
powInfo = spInfo.*conj(spInfo)/NFFT;
freq = Fs/2*linspace(0,1,NFFT/2+1);

figure();
% Plot single sided amplitude spectrum
% plot(freq,2*abs(spInfo(1:NFFT/2+1)));
plot(1000*freq, powInfo(1:NFFT/2+1),'LineWidth',2);
xlabel('Frequency (mHz)','FontSize',14);
title('Power spectral density of GFR');
set(gca,'xscale','log');
box off;
