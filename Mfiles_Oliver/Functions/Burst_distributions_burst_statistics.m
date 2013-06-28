%More or less unfinished work, The  idea was to look at Network burst
%interval distrubtions, Network burst length distribution, and finally the
%dependence on the Networkburst interval vs. the Networkburst length. I
%expected to see a dependence that goes exponentially, i.e longer Network
%bursts for longer intervals (before he NB). The ideas behind  that were
%taken from Staley et al 2001, J. Neurpphysiology. They study similar
%things (not in cultures however). They have the idea that burst timing can
%be explained by relaxation from depression. They set up a model where they
%can measure the relevant timeconstant of relaxation, and furthermore explain a
%burst-timing distribution by a binomial probability ditribution of
%relaxing synapses.
% I thought I can come up with a similar analysis, but I have seen that in many cases, I don't see a clear exponantial dependency between
% Networkburst interval and Network burst length. Only in a few cases I could imagine to fit an exponential in the curve. In many cases however, Network bursts
% had constant length, not dependend on the Interval before. In other cases
% there was just no clear sepearation possible. Maybe the analysis was not
% detailed enough.
% 
% Another observation was, sth. that also in the mentioned paper was studied, that there seems to be a clear relation between the mean and variance of burst lengths at INDIVIDUAL electrodes.
% I.e. I look at the distribution of burst lengths from several electrodes, calculate mean length and the variance, and see that for the whoel dataste, 
% I can fit the dependency of mean and variance approx like var = a*mean^3, i.e. a third order polynomial.
% The mentioned paper finds this relationship with Networkbursts of slices with different excitability (K_0+ - level), i.e. different burst levels.




function Burst_distributions_burst_statistics(datname,ls,Nr_bursting_ch);

burst_detection                   = burst_detection_all_ch(ls);
[b_ch_mea network_burst NB_onset] = Networkburst_detection(datname,ls,burst_detection,Nr_bursting_ch);

%find the intervals between bursts at electrodes, not for NB, but for
%single bursrs
%burst intervals stores for the electrodes inb_ch_mea, the interval between
%burst nr j+1 and j, at position j. The interval is the gap between the end
%of the previous and the start of the next. I.e. at position 1, it sotres
%the gap between the second and first burst
[burst_intervals] = burst_characteristics(datname,ls,burst_detection,b_ch_mea,ls.time(1)/3600,ls.time(end)/3600);

NB_ends   = cellfun(@(x) max(x),network_burst(:,5));
NB_length = NB_ends(1:end-1) - NB_onset(:,2);

%the following stores the Network burst interval ast the
%gap between last offset and new onset. the first index is for the NB nr 1,
%i..e the gap to the next NB
INBI      = NB_onset(2:end,2) - NB_ends(1:end-2);

%this simply stores the INBI as the difference between two onsets
INBI_long = diff(NB_onset(:,2));

screen_size_fig;
subplot_r  = 3;
subplot_c  = 2;
%this plots a histogram of NB_length distribution
subplot(subplot_r,subplot_c,1);
Max_val    = max(NB_length);
hist_vec   = 0:0.01:Max_val;
bar(hist_vec,hist(NB_length,hist_vec));
title({[num2str(datname)];[ 'Network burst length distribution']});
xlabel('length [sec]');


%the following plots the InterNetworkburst interval distribution
subplot(subplot_r,subplot_c,3);
inbi_vec = 0:0.1:90;
bar(inbi_vec,hist(INBI,inbi_vec));
title('InterNetworkburst Interval distribution');
xlabel('Interval (Gap between NB end and start) [sec]');


%the following plots the Networkburst interval vs the NEXT burst length
subplot(subplot_r,subplot_c,5)
plot(INBI(1:end-1),NB_length(2:end-1),'*');
title('InterNetworkburst interval vs. the length of the NEXT NB');
xlabel('InterNetworkburst interval [sec]');
ylabel('Networkburst length [sec]');



%define the burst lengths, of individual bursts on electrodes, not NBs
for ii=1:length(b_ch_mea)
    active_ch          = cr2hw(b_ch_mea(ii))+1;
    %find the intervals not exceeding some level
    
    burst_length{ii}   = cellfun(@(x) x(end) -x(1),burst_detection{1,active_ch}(:,3));
    %also calculate the mean burst interval
    short_int_ind      = find([burst_intervals{1,ii}{:,1}]<20);
    mean_burst_int{ii} = mean([burst_intervals{1,ii}{short_int_ind,1}] );
    %define the mean burst_length
    mean_burst_length{ii} = mean(burst_length{ii}(short_int_ind+1));
    burst_length_var {ii} = var(burst_length{ii}(short_int_ind+1));
end


%plot the relationship between burst length mean and variance, for
%individual electrodes
%make a fit to the dependency between burst length varaiance and burst mean
%fit to third order
fit_coeff  = polyfit([mean_burst_length{:}],[ burst_length_var{:}],3);
fit_res    = (max([mean_burst_length{:}])-min([mean_burst_length{:}]))/100;
time_poly  = min([mean_burst_length{:}]):fit_res:max([mean_burst_length{:}]);
fit_result = polyval(fit_coeff,time_poly)


subplot(subplot_r, subplot_c,4)
plot([mean_burst_length{:}],[burst_length_var{:}],'*');
hold on
plot(time_poly,fit_result,'r');
title({['Burst length vs. variance of burst length distribution'];['Coeff for fit are ', num2str(fit_coeff)]});
xlabel('mean burst length [sec]');
ylabel('variance of burst length distribution');

%plot the mean Burst interval vs. the mean burst length, (based on single
%bursts) for
subplot(subplot_r,subplot_c,6)
%plot([mean_burst_int{:}]/max([mean_burst_int{:}]),[mean_burst_length{:}]/max([mean_burst_length{:}]),'*')
plot([mean_burst_int{:}],[mean_burst_length{:}],'*');
title('Mean burst interval vs. mean burst length, for different electrodes, based on single bursts')
xlabel('Burst interval [sec]')
ylabel('Burst length [sec]');


