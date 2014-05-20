% smoothing global activity to look for drifts in NetControl data
spks = NetControlData.Spikes;
binSize_g = 2;
[counts_g,timeVec_g] = hist(spks.time,0:binSize_g:ceil(max(spks.time)));
counts_smooth_g = smooth(counts_g,3001,'lowess');

%% rec channel
inrec = NetControlData.InAChannel{cr2hw(NetControlData.Electrode_details.rec_electrode)+1};
binSize_r = 15;
[counts_r,timeVec_r] = hist(inrec,0:binSize_r:ceil(max(spks.time)));
counts_smooth_r = smooth(counts_r,301,'lowess');

%% stimulus frequencies
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

binSize_st = 15;
[counts_st,timeVec_st] = hist(stimTimes,0:binSize_st:ceil(max(spks.time)));
counts_smooth_st = smooth(counts_st,301,'lowess');

figure(); hold on;
smooth_h(1) = subplot(2,1,1);
plot(timeVec_g/3600, counts_smooth_g/max(counts_smooth_g),'b','LineWidth',2);
set(gca,'XTick',[]);
set(gca,'TickDir','Out');
set(gca,'FontSize',12);
axis tight;
box off;
legend('Global activity');
legend('boxoff');

smooth_h(2) = subplot(2,1,2);
plot(timeVec_st/3600, counts_smooth_st/max(counts_smooth_st),'g','LineWidth',2); hold on;
plot(timeVec_r/3600, counts_smooth_r/max(counts_smooth_r),'k','LineWidth',2);
axis tight;
box off;
set(gca,'TickDir','Out');
set(gca,'FontSize',12);
legend('Stimulus','Recording channel');
legend('boxoff');
[ax1,h1]=suplabel('Time [h]');
[ax2,h2]=suplabel('Frequency [n.u]','y');
linkaxes(smooth_h,'x');
set(h1,'FontSize',12);
set(h2,'FontSize',12);

%% stalling times
% [stimGaps,stimGapIdx] = sort(diff(stimTimes),'descend');
% for ii = 1:2
%     plot(stimTimes(stimGapIdx(ii))/3600,0,'g^');
%     plot(stimTimes(stimGapIdx(ii)+1)/3600,0,'r^');
% end

%% superbursting culture

spks = pre_spont.Spikes
% spks = NetControlData.Spikes;
binSize_g = 0.5;
[counts_g,timeVec_g] = hist(spks.time,0:binSize_g:ceil(max(spks.time)));
counts_smooth_g = smooth(counts_g,75,'lowess');



figure(); hold on;
plot(timeVec_g,counts_smooth_g/max(counts_smooth_g),'b','LineWidth',2);
set(gca,'TickDir','Out');
set(gca,'FontSize',12);
axis tight;
box off;
xlabel('Time [s]');
ylabel('Frequency [n.u]');


counts_meanshifted = counts_smooth_g - mean(counts_smooth_g);
Fs = 1/binSize_g;
T = 1/Fs;
L = length(counts_meanshifted);
t = (0:L-1)*T;

NFFT = 2^nextpow2(L);
spInfo = fft(counts_meanshifted,NFFT)/L;
ampInfo = 2*abs(spInfo(1:NFFT/2+1));
% powInfo = 10*log10(abs(spInfo).^2);
freq = Fs/2*linspace(0,1,NFFT/2+1);

figure();
semilogx(1000*freq, ampInfo,'LineWidth',2);
axis tight;
box off;
set(gca,'TickDir','Out');
set(gca,'FontSize',12);
legend('boxoff');
xlabel('Frequency [mHz]','FontSize',12);
ylabel('|GFR(f)|','FontSize',12);
title('Single-sided amplitude spectrum of global firing rate (GFR)');

% NFFT = 2^nextpow2(L);
% spInfo = fft(counts_meanshifted,NFFT);
% spInfo = spInfo(1:NFFT/2+1);
% powInfo = (1/(Fs*NFFT)).*abs(spInfo).^2;%   spInfo.*conj(spInfo)/NFFT;
% powInfo(2:end-1) = 2*powInfo(2:end-1);
% freq = 0:Fs/NFFT:Fs/2;
% figure();
% plot(freq,10*log10(powInfo));
% axis tight;
% box off;
% set(gca,'TickDir','Out');
% set(gca,'FontSize',12);
% xlabel('Frequency [mHz]','FontSize',12);
