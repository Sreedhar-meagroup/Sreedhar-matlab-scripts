%19/02/07
%for datasets with cyclical stimulation (and with control and stim period
%in one file) previous plots have to be modified.
%This is a modiification of the plots in nostim_stim_burst_analysis.
% I need a better timeresolved plot of the development of burst length and
% IBI, with the time on the xaxis and not the burst nr.

%the following needs the same structures as nostim_stim_burst_analysis,
%this is just a slight modification of the plotting behavior

%21/02/07
% a new, probably easier way of getting a 'noise filtered' burst interval
% (and length) development over time, by convolving it with a gaussian,
%which is sth. similar than a moving average, this one is in fact also
%faster and probably  more error-free and standard

%22/02/07
%From analysing some of those data, the burst interval bar graphs and their
%mov. averaged time series have shown, in some cases, a change upon
%stimulation, (or even afterwards, or before,...), but it's hard to judge
%this by eye. A method is to calculate the burts interval pdf and look at
%the differences during control and stimperiods for various channels. The
%pdf can easily be calculted with the ksdensity fct in matlab, the results
%are sufficient for now, although it can generate probabilities larger than
%1 and even negative interval lengths! (Simply because it is nothing more than a convolution of the burst
%interval histogram with a simple gaussian)
%Anther idea would be to ake some statistical test about the individual
%distributions (during control and stim). The right test would probably be
%a Mann-Whitney U-test (same as Wilcoxon-rank sum test. this is one is
%implemented in matlab). This was already tried but not implemented yet.
%the test needs to be a 'distribution-free' (non-parametric)
%since I don't know the underlying distribution and for unpaired (independent) two-samples%
%see e.g. the book 'biostatistical analysis' chap. 8.9 - 8.10 (p. 145ff) for some examples
%for a general overview of statistical test use the 'Statistikbaum.pdf'




bursting_channels_mea=[17 26 ];
bursting_channels      = cr2hw(bursting_channels_mea)+1;
no_bursting_ch         = length(bursting_channels);

%find the triggers
trig_ind    = find(ls.channel==60);
trig_times  = ls.time(trig_ind);
trig_num    = length(trig_times);

b_length_all   = cell(no_bursting_ch,1);
b_interval_all = cell(no_bursting_ch,1);
%calculate the burst length of all detected bursts on several channels
%and also calculate the burst intervals
%and calculate the percentage of spikes in bursts 
for b_ch=1:no_bursting_ch
    burst_ch=bursting_channels(b_ch);
    for b_ct=1:size([burst_detection{1,burst_ch}],1)-1
        b_length_all{b_ch}(b_ct)   = burst_detection{1,burst_ch}{b_ct,3}(end) - burst_detection{1,burst_ch}{b_ct,3}(1);
        b_interval_all{b_ch}(b_ct) = [burst_intervals_ch{1,b_ch}{b_ct,1}];
    end
    %find those 'intervals'that are actually blanking periods. easiest way to
    %check if the max burst interval is larger than e.g. 1hr (hardly a real
    %burst interval) and delete it or set it 0
    %[max_val max_ind]=max(b_interval_all{b_ch});
    %if (max_val > 3600)
    %    b_interval_all{b_ch}(max_ind) = NaN;
    %    b_length_all{b_ch}(max_ind)   = NaN;
    %end  
    
     spikes_in_bursts_percentage(b_ch) = sum([burst_detection{1,burst_ch}{:,2}])/length(find(ls.channel==bursting_channels(b_ch)-1));
end;



%Calculate moving averages, in this case by convolving it with a gaussian
%kernel, what is also an an (moving) averaging method
nu=0;
%how many values to take to the left and to the right:
mov_average_half_size     = 100;
sigma                     = 0.3*mov_average_half_size;
%array_length              = 3*mov_average_half_size+1;
gauss_array               = gauss_kernel(-mov_average_half_size:mov_average_half_size,nu,sigma); %this is a function defined by myself
figure;plot(-mov_average_half_size:mov_average_half_size,gauss_array);

%the following cells store the moving averaged (convolved) initerburst
%interval and burstlength development over time, for the channels under
%investigation
b_interval_all_conv = cell(no_bursting_ch,1);
b_length_all_conv   = cell(no_bursting_ch,1);

for b_ch=1:no_bursting_ch;  
    b_interval_all_conv{b_ch} = conv(b_interval_all{b_ch},gauss_array);
    b_length_all_conv{b_ch}   = conv(b_length_all{b_ch},gauss_array);
    %delete the overlapping values at the left and right edges
    b_interval_all_conv{b_ch}(1:mov_average_half_size)           = [];
    b_interval_all_conv{b_ch}(end-(mov_average_half_size-1):end) = [];
    b_length_all_conv{b_ch}(1:mov_average_half_size)             = [];
    b_length_all_conv{b_ch}(end-(mov_average_half_size-1):end)   = [];      
end;



%make the same plots as in previous analysis, only here with time on the
%xaxis and also with the new convolved time-averaged burst interval and
%burts length
subplot_row  = 3;  %a rateplot, a burst length plot and a burst interval plot
subplot_col  = 1;
%this was taken from rateprofile.m, I need that vector here
bin_vec=0:bin_width:recording_end;
for b_ch=1:no_bursting_ch;
    burst_ch=bursting_channels(b_ch);
    fig_handle(b_ch)  = figure;
    set(fig_handle(b_ch),'Position',[0 0 1600 1120]);
    sub_handle(b_ch,1)= subplot(subplot_row,subplot_col,1);
    %plot a rate profile first
    stairs(bin_vec./3600,spikecount(burst_ch,:));
    hold on;
    line(stim_hrs,zeros(2,length(stim_hrs)),'Linewidth',4,'Color','y');
    rate_ticks       = ceil(max(spikecount(burst_ch,:))/4);
    y_ticks_rate     = 0:rate_ticks:max(spikecount(burst_ch,:))+rate_ticks;
    y_ticklabel_rate = y_ticks_rate./bin_width; 
    set(sub_handle(b_ch,1),'XLim', [0 recording_end_hrs]);%,'YTick',y_ticks_rate,'YTickLabel',num2str(y_ticklabel_rate'),'XTick',xtick,'XTickLabel',xtick_label,'FontSize',12);
    title({[' dataset: ',num2str(datname)];['channel ',num2str(bursting_channels_mea(b_ch))];[' rate-profile ' ]},'FontSize',12, 'Interpreter' ,'none'); 
    xlabel('time [hrs] ', 'FontSize',12);
    ylabel( 'rate [Hz]', 'FontSize',12);
    
    %plot the burst length development over time as bar graphs and as
    %moving average in one plot
    sub_handle(b_ch,3)=subplot(subplot_row,subplot_col,2);
    bar([burst_onset{1,b_ch}{1:length(b_length_all{b_ch}),1}]./3600,[b_length_all{b_ch}])
    hold on;
    plot([burst_onset{1,b_ch}{1:length(b_length_all{b_ch}),1}]./3600,b_length_all_conv{b_ch},'r','LineWidth',2);
    %the vectors stim_hrs are first defined in rate-profile.m
    line(stim_hrs,zeros(2,length(stim_hrs)),'Linewidth',4,'Color','y');
    xlabel('time [hrs]','FontSize',12);
    ylabel('burst length [sec]','FontSize',12);
    title(['burst length and moving average (convolved over ', num2str(mov_average_half_size),' burst lengths to left and right )'], 'FontSize',12);
    all_real=find(~isnan(b_interval_all_conv{b_ch}));
    set(sub_handle(b_ch,3),'XLim',[0 recording_end_hrs],'YLim', [0 max(b_length_all_conv{b_ch}(all_real))+3*std(b_length_all_conv{b_ch}(all_real))],'FontSize',12);
    
    %the same for the burst intervals 
    sub_handle(b_ch,5)=subplot(subplot_row,subplot_col,3);
    bar([burst_onset{1,b_ch}{1:length(b_length_all{b_ch}),1}]./3600,b_interval_all{b_ch});
    hold on;
    plot([burst_onset{1,b_ch}{1:length(b_length_all{b_ch}),1}]./3600,b_interval_all_conv{b_ch},'r','LineWidth',2);
    line(stim_hrs,zeros(2,length(stim_hrs)),'Linewidth',4,'Color','y');
    title(['Interburst Intervals  and moving average (convolved over ', num2str(mov_average_half_size),' intervals to left and right)'], 'FontSize', 12)
    xlabel('time [hrs]','FontSize',12);
    ylabel('Inter burst interval [sec]','FontSize',12);
    set(sub_handle(b_ch,5),'XLim',[0 recording_end_hrs],'YLim', [0 max(b_interval_all_conv{b_ch}(all_real))+3*std(b_interval_all_conv{b_ch}(all_real))],'FontSize',12);
      
end



%specific for each dataset
control_length     = 10800;
stim_length        = 3600;
no_stim_electrodes = 7;
stimulus_el=[31 52 44 25 72 57 17];
control_starttime  = [11 14422 28826 43230 57634 72038 86443];
stim_starttime     = control_starttime+control_length;


%this gives the intervals for the respective bursting channels (under
%investigation) during the periods of stimulation and control (thosefollow thw switch 
%of the stim_electrodes
%this is necessary for later calculation of burst intervals pdfs during the
%different periods
IBI_cont_stim=cell(no_bursting_ch,no_stim_electrodes);
for i=1:no_bursting_ch
    for j=1:no_stim_electrodes
        cont_int = find([burst_onset{1,i}{:,1}] > control_starttime(j) & [burst_onset{1,i}{:,1}] < stim_starttime(j));
        stim_int = find([burst_onset{1,i}{:,1}] > stim_starttime(j)    & [burst_onset{1,i}{:,1}] < stim_starttime(j)+stim_length);  %if I do it like that, I circimvent the problwm of having no control after the last stim
        cont_int = b_interval_all{i}(cont_int);
        stim_int = b_interval_all{i}(stim_int);
        IBI_cont_stim{i,j}{1} = cont_int;
        IBI_cont_stim{i,j}{2} = stim_int;
    end
end




%calculate the mentioned density functions with the ksdensity matlab fct
%!Note: restricting the x-values only to positive ones, (what is possible
%with choosing the option 'support', 'positive'), does also worsen the pdf-shape, there are more edges in it.
%this is because only-positive values means a different kind of pdf
%computuaion and density function is calculated for larger x-values, so
%there spacing for small x-values is smaller what makes the zick-zack
%shape in the plot, looks pretty ugly, therfore do allow negative x-values
IBI_cont_stim_density_pdf=cell(no_bursting_ch,no_stim_electrodes);    
max_prob_chwise=zeros(1,no_bursting_ch);

%use a specified kernel
a_gamma=2;
b_gamma=1.5;
gammapdf_handle=@(gpdf) gampdf(gpdf,a_gamma,b_gamma);

for i=1:no_bursting_ch
    for j=1:no_stim_electrodes
        
        if ( isempty([IBI_cont_stim{i,j}{1}]) | isempty([IBI_cont_stim{i,j}{2}]))
            IBI_cont_stim_density_pdf{i,j}{1}(1:2,:) = [0; 0];
            IBI_cont_stim_density_pdf{i,j}{2}(1:2,:) = [0;0];
        else
        [IBI_cont_stim_density_pdf{i,j}{1}(1,:) IBI_cont_stim_density_pdf{i,j}{1}(2,:)] = ksdensity([IBI_cont_stim{i,j}{1}],'npoints', 300,'kernel',gammapdf_handle);
        [IBI_cont_stim_density_pdf{i,j}{2}(1,:) IBI_cont_stim_density_pdf{i,j}{2}(2,:)] = ksdensity([IBI_cont_stim{i,j}{2}],'npoints', 300,'kerne', gammapdf_handle);
        end
        
         max_control(j) = max([IBI_cont_stim_density_pdf{i,j}{1}(1,:)]);
         max_stim(j)    = max([IBI_cont_stim_density_pdf{i,j}{2}(1,:)]);  
    end
    if (max(max_control) > max(max_stim))
        max_prob_chwise(i) = max(max_control);
    else
        max_prob_chwise(i) = max(max_stim);
    end
end

  


%plot the results, by generating a couple of subplots, each subplot has
%more than 1 period of cont and stim in it (rows), and on each figure, there are
%the results for a given nr. of channels (columns)
periods_per_plot=2 
channels_per_figure=4;
total_plots=ceil(no_bursting_ch/channels_per_figure);

for i=1:no_bursting_ch
    %make 'channels_per_figure' channels on one figure
    if (mod(i,channels_per_figure)==1)
        fig_nr=(i-1)/channels_per_figure+1
        density_fig(fig_nr)=figure;
    end
    
    %make periods_per_plot on one subplot, one period is always control AND
    %stim together
    for period_nr=1:no_stim_electrodes/periods_per_plot
        
        if (mod(i,channels_per_figure)==0)
            subplot_nr               = channels_per_figure+(period_nr-1)*4;
            sub_h(fig_nr,subplot_nr) = subplot(4,4,subplot_nr);   
        else 
            subplot_nr               = mod(i,channels_per_figure)+(period_nr-1)*4;
            sub_h(fig_nr,subplot_nr) = subplot(4,4,subplot_nr);
        end
        
        periods(1:periods_per_plot)=(period_nr*periods_per_plot-1):period_nr*periods_per_plot;
 
        %the plots for the 1st period of contorl and stim
        plot(IBI_cont_stim_density_pdf{i,periods(1)}{1}(2,:),IBI_cont_stim_density_pdf{i,periods(1)}{1}(1,:));
        hold all;
        plot(IBI_cont_stim_density_pdf{i,periods(1)}{2}(2,:),IBI_cont_stim_density_pdf{i,periods(1)}{2}(1,:));
        hold all;
 
        %the plots for the subsequent period cycle
        plot(IBI_cont_stim_density_pdf{i,periods(2)}{1}(2,:),IBI_cont_stim_density_pdf{i,periods(2)}{1}(1,:));
        hold all;
        plot(IBI_cont_stim_density_pdf{i,periods(2)}{2}(2,:),IBI_cont_stim_density_pdf{i,periods(2)}{2}(1,:));
        xlabel('time [sec]');
        ylabel({['probability'];['periods ', num2str(period_nr*periods_per_plot-1),' , ',num2str(period_nr*periods_per_plot)]});
        xlim([-5 40]);
        ylim([0 max_prob_chwise(i)]);
         
    end  
end
   



%all for the labeling and putting a alegend on the first column on each
%figure
for k=1:total_plots
     for l=1:4
         stimulus_nr=l*periods_per_plot-1;
        if sub_h(k,l)>0
         title(sub_h(k,l), ['channel: ',num2str(bursting_channels_mea((k-1)*channels_per_figure + l))])
        end
         legend(sub_h(k,(l-1)*4+1),['control period ',num2str(stimulus_nr)],...
             ['stim period ', num2str(stimulus_nr),' (el. ',num2str(stimulus_el(stimulus_nr)),')'],...
             ['control period ',num2str(stimulus_nr+1)],...
             ['stim period ', num2str(stimulus_nr+1),' (el. ',num2str(stimulus_el(stimulus_nr+1)),')']);
     end
     title(sub_h(k,1),{['datname: ', num2str(datname)];['PDF for Interburst Intervals during periods of control and stimulation']...
         ;[];['channel: ', num2str(bursting_channels_mea((k-1)*channels_per_figure + 1))]}, 'FontSize' , 12,'Interpreter', 'none');
end


time_start=control_starttime(1);
time_end=control_starttime(8);
onsets=find(network_burst_onset(:,2)>time_start & network_burst_onset(:,2)<time_end);
burstchannel_ref_mea = 84;
%consider the following as the stim channel 
%currently allow only max 0f 6 channels to plot( due to subplot
%limitations)
burstchannel_act_mea_array=[ 84 76 58 52 45 25];
cc_max_timepoints_fig=figure;
for b_ch_act=1:length(burstchannel_act_mea_array);
    burstchannel_act_mea=burstchannel_act_mea_array(b_ch_act);
burstchannel_ref     = find(bursting_channels_mea==burstchannel_ref_mea);
burstchannel_ref     = bursting_channels(burstchannel_ref);
burstchannel_act     = find(bursting_channels_mea==burstchannel_act_mea);
burstchannel_act     = bursting_channels(burstchannel_act);


%figure;
%burst_sequence_ref_act=zeros(1,length(onsets));
sample_window=0.002;
non_act=0;
non_ref=0;
num_act_ref=0;
cross_correlate_all=cell(2,20);
for i=1:length(onsets)
    burstpos_ref =(find(network_burst{onsets(i),1}==burstchannel_ref));
    if (burstpos_ref)
    burstpos_act=(find(network_burst{onsets(i),1}==burstchannel_act));
        if (burstpos_act)
           
            %i
            %assuming 'act' comes after 'ref', i.e the following value
            %would be positive,just a s a convention
            %burst_sequence_ref_act(i)=burstpos_act-burstpos_ref;
            ref_burst_times  = burst_detection{1,burstchannel_ref}{network_burst{onsets(i),4}(burstpos_ref),3};
            act_burst_times  = burst_detection{1,burstchannel_act}{network_burst{onsets(i),4}(burstpos_act),3};
            ref_burst_length = ref_burst_times(end)-ref_burst_times(1);
            act_burst_length = act_burst_times(end)-act_burst_times(1);
            if(ref_burst_length>0.1 & act_burst_length>0.1)      %take only bursts in the case when they are larger than 400 ms
                num_act_ref=num_act_ref+1;
                if(burstpos_ref < burstpos_act)
                    if (ref_burst_times(end) > act_burst_times(end))
                        ref_burst_array=hist(ref_burst_times,ref_burst_times(1):sample_window:ref_burst_times(end));
                        act_burst_array=hist(act_burst_times,ref_burst_times(1):sample_window:ref_burst_times(end));
                    else
                         ref_burst_array=hist(ref_burst_times,ref_burst_times(1):sample_window:act_burst_times(end));
                         act_burst_array=hist(act_burst_times,ref_burst_times(1):sample_window:act_burst_times(end));
                    end
                elseif (burstpos_ref > burstpos_act & ref_burst_times(end) > act_burst_times(end))
                         ref_burst_array=hist(ref_burst_times,act_burst_times(1):sample_window:ref_burst_times(end));
                         act_burst_array=hist(act_burst_times,act_burst_times(1):sample_window:ref_burst_times(end));
                else
                         ref_burst_array=hist(ref_burst_times,act_burst_times(1):sample_window:act_burst_times(end));
                         act_burst_array=hist(act_burst_times,act_burst_times(1):sample_window:act_burst_times(end));
                end

                ref_burst_array_conv=conv(ref_burst_array,gauss_array);
                act_burst_array_conv=conv(act_burst_array, gauss_array);

                cross_correlate_all{1,num_act_ref} = xcorr(ref_burst_array_conv,act_burst_array_conv,'coeff');
                cross_correlate_all{2,num_act_ref} = (length(cross_correlate_all{1,num_act_ref})+1)/2;    %this is then also the sample number
            end
          
        else
            non_act=non_act+1;
            %burst_sequence_ref_act(i)=0;
        end
    else
        non_ref=non_ref+1;
        %burst_sequence_ref_act(i)=NaN;
    end
end
     
max_pos_all=zeros(1,length(cross_correlate_all));
for i=1:num_act_ref
    max_pos=find(cross_correlate_all{1,i}==max(cross_correlate_all{1,i}));
    max_pos_all(i)=(max_pos(1)-cross_correlate_all{2,i})*sample_window;
end

if (b_ch_act<=3)
    cc_max_timep_handle(b_ch_act)=subplot(3,2,2*b_ch_act-1);
else
    cc_max_timep_handle(b_ch_act)=subplot(3,2,2*b_ch_act-6);
end
hist(max_pos_all,-1:sample_window:1);
title([' electrodes ', num2str(burstchannel_ref_mea),' and ', num2str(burstchannel_act_mea_array(b_ch_act))]);
xlabel('position of maxima rel. to 0 in cross correlogramm [sec]');
ylabel('counts');
xlim([-0.2 0.2]);

end
title(cc_max_timep_handle(1),{['datname: ',num2str(datname)];['histogram distribution for timepoints of maxima in crosscorrelograms'];...
    [' between (time-near) bursts on '];['electrodes ', num2str(burstchannel_ref_mea),' and ', num2str(burstchannel_act_mea_array(1))]},'FontSize',12,'Interpreter', 'none');

  



single_elbursts_in_netwburst=cell(no_bursting_ch,10);
for i=1:no_bursting_ch
    burst_ch=bursting_channels(i);
    num_in_netwburst=0;
    for j=1:size(network_burst,1);
        if find(network_burst{j,1}==burst_ch)
            num_in_netwburst=num_in_netwburst+1;
            single_elbursts_in_netwburst{i,num_in_netwburst}=j;
        end
    end
    ratio_el_burst_to_netwburst(i)=num_in_netwburst/size(network_burst,1);
end

figure;
bar(bursting_channels_mea,ratio_el_burst_to_netwburst);
title({['datname: ',num2str(datname)];['percentage of network bursts that include a burst from the resp. electrode'];['total nr. of network bursts: ', num2str(size(network_burst,1))];...
        ['nr. above bar indicates total nr. of bursts on resp. electrode']},'Interpreter','none');
xlabel('electrode nr. (MEA)');
ylabel('percentage');
ylim([0 1]);
for i=1:no_bursting_ch
    text(bursting_channels_mea(i),ratio_el_burst_to_netwburst(i)+0.05,num2str(size(burst_detection{1,bursting_channels(i)},1)))
end;



  
  
max_samples    = max([cross_correlate_all{2,:}])     %since cross_correlate_all{2,x} has the sample numbers 
max_array_size = 2*max_samples-1;                    %and the vectors are always 2*N-1 long
array_middle   = max_samples;


take_which=1:length(cross_correlate_all);
cross_correlate_avg=zeros(1,max_array_size);
for i=take_which
    N_samples=cross_correlate_all{2,i};
    indices   = (array_middle-(N_samples-1)):(array_middle+ N_samples-1);
    cross_correlate_avg(indices)  = cross_correlate_avg(indices)+cross_correlate_all{1,i};
    tau_vec=(-(N_samples-1):(N_samples-1)).*sample_window;
    plot(tau_vec,cross_correlate_all{1,i});
    hold all;
end;
cross_correlate_avg=cross_correlate_avg./length(take_which);

cc_figure=figure;
avg_tau_vec=(-(max_samples-1):(max_samples-1)).*sample_window;
plot(avg_tau_vec,cross_correlate_avg);
title({['averaged cross correlogramm for time-near (i.e. both are in same network burst) bursts on electrodes ',...
       num2str(burstchannel_ref_mea),' and ', num2str(burstchannel_act_mea)];...
       ['each spike train was previously convolved with a gaussian kernel of width ', num2str(sigma*sample_window*1000),' ms'];...
       ['averaging over ',num2str(length(take_which)),' correlogramms, for burst nrs ', num2str(take_which(1)),':',num2str(take_which(end))]});
   xlabel('tau [sec]');
   ylabel('cross-correlation coefficent');


   
   
   
   
   
   
   
   
   
    hist(burst_sequence_ref_act,-10:10)
    title({['temporal sequence in network bursts between electrodes ', num2str(burstchannel_ref_mea),' and ', num2str(burstchannel_act_mea)];...
        [' for all network bursts between ', num2str(floor(time_start/3600)),' hrs and ',num2str(floor(time_end/3600)),' hrs.'];...
        [' x-axis value indicates difference in burstposition for these channels' ];...
        [' positive values for the case when ch ', num2str(burstchannel_ref_mea),' is bursting first, '...,
        '0 means only channel ', num2str(burstchannel_ref_mea),' is in the network burst'] },'FontSize', 12);
    xlabel(' burst position difference', 'FontSize',12);
    ylabel(' counts' );
    %hold all;
end

        
        
        
        
        
        
        
        







