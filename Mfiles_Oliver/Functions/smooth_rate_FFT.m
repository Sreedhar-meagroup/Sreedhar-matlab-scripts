%%%%function Smooth_rat
%function [Smooth_rate Summed_rate Time_vec]= Smooth_rate_FFT(datname,ls,RATE_START, RATE_END, RATE_RES)
%%%%%
%INPUT:
% datname:               Name of the dataset
% 
% ls                     structure that holds spike information
% 
% RATE_START             Begining of rate calculation, in hrs
% 
% RATE_END               End of rate calculation in hrs
% 
% RATE_RES:              Time resolution of rate-binning, in sec
% 
%
%
function [Smooth_rate Summed_rate Time_vec]= Smooth_rate_FFT(datname,ls,RATE_START, RATE_END, RATE_RES)

% %%%Define the times for calculation of the rate, in HRS
% RATE_START = 0;
% RATE_END   = 6;
% 
% %%%Define also the resolution of the rate_profile, in sec
% RATE_RES   = 5;

rate_vec=rate_profile(datname,ls,RATE_START,RATE_END,RATE_RES);

%%%choose a set of interesting channels
disp('Give Channels that should be used for the rate calculation');
CHANNELS = input('Channels (MEA notation)');
%CHANNELS = [13 14 23 54];
Nr_ch    = length(CHANNELS);
HW_CH    = cr2hw(CHANNELS);
%%%Define a smoothing (gaussian) Kernel
EXTEND    = [-20:20];
MEAN_VAL  = 0;
SIGMA_VAL = 5;

Smooth_kernel = gauss_kernel(EXTEND,MEAN_VAL,SIGMA_VAL);
%figure; plot(Smooth_kernel)
%title('Kernel used to smooth the rate profiles');

%for all channels, smooth their rate by running the convolution over their
%time series
%first extract their time series from the rate_vec matrix,
%then run the convolution and store the result in a new vector (the smoothed rates)
Smooth_rate = zeros(Nr_ch,length(conv(Smooth_kernel,zeros(1,size(rate_vec,2)))));
for ii=1:Nr_ch
    curr_rate   = rate_vec(HW_CH(ii)+1,:);
    smooth_rate_vec = conv(curr_rate,Smooth_kernel);
    Smooth_rate(ii,:) =  smooth_rate_vec;
end

%%%Remove the overlapping parts that came with the convolution
nr_index = length(Smooth_rate)-length(rate_vec);
if mod(nr_index,2)  %if it is an odd number
    nr_remove_front = floor(nr_index/2);
    nr_remove_back  = ceil(nr_index/2);
else
    nr_remove_front = nr_index/2;
    nr_remove_back  = nr_index/2;
end
    
    
    
    
rm_index = [1:nr_remove_front (length(Smooth_rate)-nr_remove_back+1):length(Smooth_rate)];
Smooth_rate(:,rm_index) = [];

Ch_rate_prof_smooth=screen_size_fig();
subplot_col = 1;
subplot_row = Nr_ch;
Time_vec = RATE_START*3600:RATE_RES:RATE_END*3600;

%To obtain the proper 

for ii=1:Nr_ch
    subplot(subplot_row, subplot_col,ii)
    plot(Time_vec/3600, Smooth_rate(ii,:))
    title(['Channel: ', num2str(CHANNELS(ii))]);
    xlabel('time [hrs]');
    ylabel('rate');
end
    subplot(subplot_row,subplot_col,1)
    title({['datname: ', num2str(datname),' Smoothed Rate profiles, resolution of ', num2str(RATE_RES),' sec'];...
        ['Smoothing was performed with a gaussian kernel of length ', num2str(length(EXTEND)*RATE_RES),' sec, mean of ', num2str(MEAN_VAL),', and sigma of ', num2str(SIGMA_VAL*RATE_RES),' sec'];...
        ['Channel: ', num2str(CHANNELS(1))]},'Interpreter', 'none'); 
    

%calculate the summed rate
Summed_rate     = sum(Smooth_rate);
Sum_rate_smooth = screen_size_fig();
subplot(2,1,1);
plot(Time_vec/3600, Summed_rate/Nr_ch);
xlabel('time of recording [hrs]');
ylabel('Rate');
title({['datname: ', num2str(datname)];['Smoothed, Summed and averaged Rate profile, resolution of ', num2str(RATE_RES),'sec'];....
    ['Summed over channels ',num2str(length(CHANNELS)),' channels,: ',  num2str(CHANNELS)]},'Interpreter', 'none');




%%%%Calculate a Fourier transform of the summed rate

fft_sum_rate = fft(Summed_rate);
N               = length(fft_sum_rate);  %Nr. of frequencies (including redundant part)

%%%delete the first entry in the fft-vector
fft_sum_rate(1)=[];

%%%define the frequency (and period)vector
freq_vec   = [1:floor(N/2)]/(N*RATE_RES); %is in Hz
period_vec = 1./freq_vec; %%%is in seconds

%calculate the power spectrum
power_spec_rate = abs(fft_sum_rate(1:floor(N/2))).^2;
%plot in the same figure
subplot(2,1,2)
plot(period_vec,power_spec_rate);
%restrict x-axis from 1 sec to 30 min
xlim([1 100]);
xlabel('period (sec)');
ylabel('power');
title('Power spectrum of the summed rate timeseries');
    
    

%%%%Do the same things for the individual channels
%calculate also the fft and power spec for the individual channels
fft_ch_rate      = fft(Smooth_rate');
fft_ch_rate      = fft_ch_rate';
fft_ch_rate(:,1) = [];
FFT_ch_fig = screen_size_fig();

for ii=1:Nr_ch
    power_spec_ch(ii,:) = abs(fft_ch_rate(ii,1:floor(N/2))).^2;
%make the plot
    h_sub(ii)    = subplot(subplot_row, subplot_col,ii)
    plot(period_vec,power_spec_ch(ii,:));
    y_lims       = get(gca,'ylim');
    y_limits(ii) = y_lims(2); 
    xlim([1 100]);
    ylabel('power');
    xlabel('period (sec)');
    title(['channel ', num2str(CHANNELS(ii))])
end
set(h_sub(:),'ylim',[0 max(y_lims)]);
  subplot(subplot_row, subplot_col,1)
  title({['Power spectrum for the rate timeseries of individual channels'];...
      ['channel ', num2str(CHANNELS(1))]});
    





    
    
    
    
    
    
    
    
    
    
    
    
    
    
    