%This function is used to calculate instantaneous rate estimates. Given a
%series of spike trains and a time vector where the spike rate should be
%calculated, I apply a convolution with a (gauss)kernel to estimate the
%rate. The return values are the estimated rate, one for each input spike
%trian


%INPUT: 
%Spike_train: a cell array, where each cell stores one spike trian. Convolutions are done for each of the spiek trains
%
%time_vec:  time vector, over which the rate is calculated. the resolution is the bin size of the rate claculation 
% 
% 

%OUTPUT:
%RF_estimate: a cell array, where each entry is a estimated firimng rate for the acc. spike trian



function [FR_estimate Estim_rate_time_vec] = Spike_train_firing_rate_estimate(Spike_train,time_vec)

%determine the bin_width;
bin_width = diff(time_vec(1:2));

%determine the no. of input spike trains
no_spike_trains = size(Spike_train,2);

%the convolution kernel
nu    = 0;
sigma = 5;
conv_kernel = gauss_kernel(-10*sigma:10*sigma,nu,sigma);

%calculate the ttime vector for the rate estimate
Estim_rate_time_vec = [-floor(length(conv_kernel)/2):(length(time_vec)+floor(length(conv_kernel)/2)-1)]*bin_width;


for ii=1:no_spike_trains
    
    %bin the spike trian
    sp_train_hist = hist(Spike_train{ii},time_vec);
    %calculate the convolution
    estim_rate = conv(sp_train_hist,conv_kernel);
    FR_estimate{ii} = estim_rate/bin_width;
end
    
    
    
    
    
    
    
    


