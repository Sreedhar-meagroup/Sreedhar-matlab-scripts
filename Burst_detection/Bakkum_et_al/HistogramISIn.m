function [valleyMinimizer_ms, h] = HistogramISIn( SpikeTimes, N, Steps ) 
% ISI_N histogram plots 
% © Douglas Bakkum, 2013 
% 
% 
% HistogramISIn( SpikeTimes, N, Steps ) 
% 'SpikeTimes' [sec] % Vector of spike times. 
% 'N' % Vector of values for plotting ISI_N histograms. 
% 'Steps' [sec] % Vector of histogram edges. 
% 
% Steps should be of uniform width on a log scale. Note that histograms 
% are smoothed using smooth.m with the default span and lowess method. 
% 
% 
% Modified @SSK----------------------------------------------------------
% valleyMinimizer_ms returns the minimizer of the Histogram that lies
% between 10 and 1000 ms. Has same dimension as N.

% Example code: SpikeTimes = ---- ; % Load spike
% times here. N = [2:10]; % Range of N for ISI_N histograms. Steps =
% 10.^[-5:.05:1.5]; % Create uniform steps for log plot.
% HistogramISIn(SpikeTimes,N,Steps) % Run function
% 

% version 1.2 @ SSK, 23.04.2014
h = figure(); hold on 
map = hsv(length(N)); 
 
cnt = 0;
valleyMinimizer_ms = zeros(size(N));
for FRnum = N 
 cnt = cnt + 1; 
 ISI_N = SpikeTimes( FRnum:end ) - SpikeTimes( 1:end-(FRnum-1) ); 
 n = histc( ISI_N*1000, Steps*1000 ); 
 n = smooth( n, 'lowess' ); 
 plot( Steps*1000, n/sum(n), '.-', 'color', map(cnt,:),'LineWidth',2 )  % changed linewidth
 yValues = n/sum(n);
 DataInv = 1.01*max(yValues) - yValues;
 [peakVals, peakInd] = findpeaks(DataInv);
 [~, maxInd] = max(peakVals);
 valleyMinimizer_ms(cnt) = 1e3*Steps(peakInd(maxInd));
 hold on;
 plot(valleyMinimizer_ms(cnt),yValues(peakInd(maxInd)),'g^');
end 
hold off;
 
% xlabel 'ISI [ms]'
xlabel 'ISI, T_i - T_{i-(N-1) _{ }} [ms]' 
ylabel 'Probability [%]' 
set(gca,'xscale','log') 
set(gca,'yscale','log')

