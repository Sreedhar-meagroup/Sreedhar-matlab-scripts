%%%%function Smooth_rat






function [Smooth_rate Summed_rate Time_vec]= Smooth_rate_plot(datname, ls,RATE_START, RATE_END, RATE_RES)

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
figure; plot(Smooth_kernel)
title('Kernel used to smooth the rate profiles');

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
    title({['datname: ', num2str(datname),' Smoothed Rate profiles, resolution of ', num2str(RATE_RES),'sec'];...
        ['Smoothing was performed with a gaussian kernel of length ', num2str(length(EXTEND)),', mean of ', num2str(MEAN_VAL),', and sigma of ', num2str(SIGMA_VAL)];...
        ['Channel: ', num2str(CHANNELS(1))]},'Interpreter', 'none'); 
    

%calculate the summed rate
Summed_rate     = sum(Smooth_rate);
Sum_rate_smooth = screen_size_fig();
plot(Time_vec/3600, Summed_rate/Nr_ch);
xlabel('time [hrs]');
ylabel('Rate');
title({['datname: ', num2str(datname)];['Smoothed, Summed and averaged Rate profile, resolution of ', num2str(RATE_RES),'sec']},'Interpreter', 'none');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    