%08/02/07 applying a smoothing (blurring, filtering) technique to the spike
%train in order to get a better estimate of the underlying rate function,
%to obtain a rate f(t) with high sampling rate and that can be used in subsequent analysis (i.e burst
%correlation)
%the method presented in the paper by Nawrot, Aertsen & Rotter is basically
%a FIR filter method, I use this kind of method also in the online
%burst-detection, here it is realized via a convolution of the kernel fct
%with the rate at every single time step t and adding up these results. According
%to eq. 2 in the mentioned paper. A conv of the total spike train with the
%kernel would be slightly different. Here I use a gaussian kernel, in the
%online version I used a triangle kernel. this should not maatte really,
%this was also a result from the mentioned paper. for the purposes here, it
%should be okay anyway.




%various possibilities to plot an array wide, smoothed rate, e.g. by a
%convolution with a gaussian kernel or by applyingthe (single-trial) rate
%estimation (which is basicallythe same

%calculate the array wide rate in specified bins
recording_time=ls.time(end)-ls.time(1);
array_bin = 0.002;
bin_vec=0:array_bin:recording_time;
all_electrode=find(ls.channel<60);
array_rate=hist(ls.time(all_electrode),bin_vec); 

nu=0;
sigma=5;
gauss_array=gauss_kernel(-20*sigma:20*sigma,nu,sigma);
figure;plot(-20*sigma:20*sigma,gauss_array);
%rate_conv=conv(array_rate,gauss_array);

lambda=zeros(1,length(array_rate)+length(gauss_array)-1);
lambda=conv(array_rate, gauss_array);                    %this makes the convolution of the spike train with the gaussian kernel
time_vec=-floor(length(gauss_array)/2)*array_bin:array_bin:(length(array_rate)+floor(length(gauss_array)/2)-1)*array_bin;

figure; plot(time_vec,lambda./array_bin);
xlabel('time [sec]');
ylabel('array-wide spike rate [1/s]');
title(['(single-trial, array-wide) rate estimation, with a gaussian kernel of \sigma = ', num2str(sigma*array_bin*1000),' ms, rate sampled in ', num2str(array_bin*1000),' ms bins']);
