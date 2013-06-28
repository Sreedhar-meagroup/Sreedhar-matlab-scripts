%Consider I have detected network bursts, then I want to ride a rate
%estimation over the periods of network bursts via a convolution with a
%kernel to get a precise rate-profile of these network events. Then, I plan
%to crosscorrelate (correlation coefficient) the rate-profiles ( as e.g. presented in the Wagenaar PRe paper from 2006)
% and arrange the results in an nxn matrix, where n is the number of
% network bursts. The entry that is stored in the matrix should be the
% maximum crosscorrleation (coefficient) w.r.t. tau. I.e. max(CC(tau))

%what I have to do is cycle through the network bursts and determine the
%arraywide rate between the start and end point of the network burst. I.e.
%arraywide rate means taking all spikes (from ls) between the start of the
%burst (first spike on the respective channel) and the end of the burst (last spike on the channel that fires last in the network burst)
%this rate vactor should be stored in a seperate array (cell) for later
%crosscorrelation

%for the rate calculation, but also necessary to determine the right kernel
%width
bin_width=0.002;

%the Kernel function
nu=0;
sigma=2;
kernel_width=sigma*5; %in this range, the values are basically down to 0
array_extend=2*kernel_width;  %this gives the extend of the plotting range
gauss_array=gauss_kernel(-array_extend:array_extend,nu,sigma);
%of course, depending on the sampling in the (spike) train to be convolved,
%the real sigma can differ, here it is assumed to be 1 ( uniform step).
%E.g. if the sampling in a spike train is 2ms, then the real sigma would be
% 2ms*sigma (sigma as given in the calculation of the kernel)
figure;plot(-array_extend:array_extend,gauss_array);
title(['gaussian kernel with \sigma= ',num2str(sigma),', sample size: 1 (uniform step on x-axis)']);


no_networkbursts=1000%length(network_burst);
networkburst_start=zeros(1,no_networkbursts);
networkburst_end=zeros(1,no_networkbursts);
networkburst_convrate=cell(1,no_networkbursts);
for i=1:no_networkbursts
    networkburst_start(i)       = network_burst{i,2}(1);           % the second row has the start times of the single bursts for the resp. channels 
    networkburst_lastchannel    = network_burst{i,1}(end);   % in the 1st row there are the channels which participate in the networkburst, listed according to order of appearance 
    lastchannel_burstno         = network_burst{i,4}(end);   %in the 4th column, there are the burst no on the respectiv echannels
    networkburst_end(i)         = burst_detection{1,networkburst_lastchannel}{lastchannel_burstno,3}(end);
    networkburst_spikes         = ls.time(ls.time > networkburst_start(i) & ls.time < networkburst_end(i));
    bin_vec                     = networkburst_start(i):bin_width:networkburst_end(i);
    networkburst_histrate       = hist(networkburst_spikes,bin_vec);                      %the histogram vector that has entries of 0s and spike counts in the resp bin  
    networkburst_convrate{1,i}  = conv(networkburst_histrate,gauss_array);
end


plot_which=[53    86   101   107   113   124   173   179   190];
figure;
for j=1:length(plot_which)%no_networkbursts
nb_burstnr=plot_which(j);
timevec_relative = (0:length(networkburst_convrate{1,nb_burstnr})-1)*bin_width;
%timevec_absolute = timevec_relative+networkburst_start(nb_burstnr);
%plot(timevec_absolute,networkburst_convrate{1,nb_burstnr});
plot(timevec_relative,networkburst_convrate{1,nb_burstnr});
hold all;
end
title(['rate profiles for networkburst nr. ', num2str(plot_which), ' which were convolved with a gaussian kernel of sigma = ', num2str(sigma*bin_width*1000),' ms'], 'Fontsize',12);
xlabel('relative time in the convolved spike train [sec]', 'FontSize',12);
ylabel('frequency [Hz] ', 'FontSize',12);

cross_covariance_coeff=zeros(no_networkbursts,no_networkbursts);
for row_nr=1:no_networkbursts
    row_nr
    row_vec=networkburst_convrate{1,row_nr};
    row_norm=sqrt(sum((row_vec-mean(row_vec)).^2));
    for col_nr=1:no_networkbursts
        col_vec=networkburst_convrate{1,col_nr};
        cross_covariance=xcov(row_vec,col_vec);
        cross_covariance_norm=cross_covariance./(row_norm*sqrt(sum((col_vec-mean(col_vec)).^2)));
        cross_covariance_coeff(row_nr,col_nr)=max(cross_covariance_norm);
    end
end;
        
        
        
%try to get some clustering in the cross_cov_coeff matrix by running an
%algorithm on it that searches for a tree structure from the pairwise
%distances (of the rows==footprint of a networkburst, similarity of one
%networkburst with allothers in the network)
%then the indices from the tree structure are taken as the indices in the
%cross_cov_coeff matrix and a pcolor plot is done

%ccc-->cross_cov_coeff
%use euclidean distance measure
ccc_dist    = pdist(cross_covariance_coeff,'euclidean');
ccc_linkage = linkage(ccc_dist,'single');
dend_fig=figure;
[line_handle,leafnode_nr,ccc_permind]=dendrogram(ccc_linkage,0);  %show all eaf nodes, don't combine small clusters in the plot
title({['dendrogram tree representing clusters (in terms of pairwise distance in multidimensional space) in the data, for a total of ', num2str(no_networkbursts),' network bursts'];['datname ', num2str(datname)]}, 'FontSize',12,'Interpreter', 'none');
xlabel('network burst nr.', 'FontSize',12);
ylabel('(pairwise, euclidean) distance', 'FontSize',12);

ccc_clusterfig=figure;
imagesc(cross_covariance_coeff(ccc_permind,ccc_permind));colormap('gray');
title({['clustering algorithm appliedd to the cross_covariance coefficient matrix for network bursts'];['(gaussian kernel) sigma = ', num2str(sigma*bin_width*1000),' ms'];['datname ', num2str(datname)]}, 'FontSize',12,'Interpreter', 'none' )
xlabel('network burst nr (sorted according to appearance in cluster)');









