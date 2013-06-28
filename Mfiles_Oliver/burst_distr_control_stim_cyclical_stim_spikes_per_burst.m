%16/03/07
%As an outcome of the progress report and discussion with Uli, he suggested
%to plot burst_length distributions for various conditions, e.g. in the
%control case outside the trigger, in the control case inside the trigger,
%in the stim case outside the stim, in the stim case inside the stim.
%to see how the stimulation does interfere with with the burst, i.e. if they
%can possibly terminate them
%04/04/07
%Modification for cyclical stim protocols
%05/04/07
%This mfiles considers the nr. of spikes in a burst as the burst length
%10/04/07
% A modification towards the possibility to consider all stimperiods at
% once, i.e. one more 'for'  loop...
% A datapoint is determined as a specific channel in a specific cycleperiod. 
% From that, the mean spikes/burst during control vs. the mean spikes/burst during stim is calculated.
% From all these datapoints, a  scatter plot is generated and furthermore, a calculation is made that determines the 
% mean spikes/burst during control minus mean spikes/burst during stim period for each datapoint. This is done for the
% 'inside' and ' outside' condition separatly. This calculation gives, in a sense, the ' net' effect of stimulation, since it determines in how much the 
% stimulation reduces the (mean)burst length during the stim period. In the scatter plot, it can be seen as the distance from the diagonal. 


STIMPERIOD_LENGTH     = 6945;   %all times given in sec
CONTROLPERIOD_LENGTH  = 6945;
%sometimes, the real control period is muchlonger than the stim period, and
%in data analysis, I prefer to have equal lengths for stim and control,
%therefore give the real length ofthe control period that should be
%considered and change the start and end times accordingly
CONTROLPERIOD_CONTROL = 6945;
NR_PERIODS=1;
for STIM_PERIOD_NR       = 1:NR_PERIODS;
    CONTROL_START        = (STIM_PERIOD_NR-1)*(STIMPERIOD_LENGTH+CONTROLPERIOD_LENGTH)+(CONTROLPERIOD_LENGTH-CONTROLPERIOD_CONTROL);
    CONTROL_END          = CONTROL_START+CONTROLPERIOD_CONTROL;
    STIM_START           = CONTROL_END; 
    STIM_END             = STIM_START+STIMPERIOD_LENGTH;


    %first of all find the control and stim triggers
    control_trigger = find(ls.channel==60 & ls.time<CONTROL_END & ls.time>CONTROL_START);
    control_trigger = ls.time(control_trigger);
    stim_trigger    = find(ls.channel==60 & ls.time>STIM_START & ls.time<STIM_END);
    stim_trigger    = ls.time(stim_trigger);


    %define a cell burst_end with entries for each channel when the burst ends,
    %then, the burts length can easily be calculated with burst_end-burst_onset
    burst_end      = cell(1,no_bursting_ch);
    burst_length   = cell(1,no_bursting_ch);
    burst_spike_nr = cell(1,no_bursting_ch);
    for ii=1:no_bursting_ch
        active_ch=bursting_channels(ii);
        for jj=1:length(burst_detection{1,active_ch})
            burst_end{1,ii}{jj,1}  = burst_detection{1,active_ch}{jj,3}(end);
            burst_length{ii}(jj)   = burst_end{1,ii}{jj,1}-burst_onset{1,ii}{jj,1};
            burst_spike_nr{ii}(jj) = burst_detection{1,active_ch}{jj,2};
        end
    end



    %following are the cells that store the indices from burst_onset  for those
    %bursts that either lie inside or outside of control and stim, i.e 4
    %possible combinations. A cell entry for each channel separatly.
    bursts_control_outside = cell(1,no_bursting_ch);
    bursts_control_inside  = cell(1,no_bursting_ch);
    bursts_stim_outside    = cell(1,no_bursting_ch);
    bursts_stim_inside     = cell(1,no_bursting_ch);


    control_length = length(control_trigger);
    stim_length    = length(stim_trigger);
    for ii=1:no_bursting_ch
     ii
        for jj=1:length(control_trigger)
            control_inside_ind=find([burst_onset{1,ii}{:}] <control_trigger(jj)  & ([burst_onset{1,ii}{:}]+burst_length{ii}) >control_trigger(jj));
            if ~isempty(control_inside_ind)
                bursts_control_inside{ii}=cat(2,bursts_control_inside{ii},control_inside_ind);
            end
        end
          

        for kk=1:length(stim_trigger)
            stim_inside_ind = find([burst_onset{1,ii}{:}] <stim_trigger(kk)  & ([burst_onset{1,ii}{:}]+burst_length{ii}) >stim_trigger(kk));
            if ~isempty(stim_inside_ind)
                bursts_stim_inside{ii} = cat(2,bursts_stim_inside{ii},stim_inside_ind);
            end
        end
        %if isempty(bursts_stim_inside{ii})
         %   bursts_stim_inside{ii}=[0];
        %end

        bursts_control_outside{ii} = setdiff(find([burst_onset{1,ii}{:}] > CONTROL_START & [burst_onset{1,ii}{:}]<CONTROL_END),bursts_control_inside{ii});
        bursts_stim_outside{ii}    = setdiff(find([burst_onset{1,ii}{:}] > STIM_START & [burst_onset{1,ii}{:}]<STIM_END), bursts_stim_inside{ii});
        

        burst_spike_nr_control_outside{STIM_PERIOD_NR,ii}                = burst_spike_nr{ii}(bursts_control_outside{ii});
        mean_spike_nr(STIM_PERIOD_NR,ii,1)                = mean(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii});
        std_spike_nr(STIM_PERIOD_NR,ii,1)                 = std(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii});
        nr_bursts_control_outside{STIM_PERIOD_NR,ii}      = length(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii});

        burst_spike_nr_control_inside{STIM_PERIOD_NR,ii}                 = burst_spike_nr{ii}(bursts_control_inside{ii});
         %make the check for the very rare case that no burst was detected
        %in the control-inside condition, although I operate with bursting
        %electrodes
        %if isempty(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii})
         %   burst_spike_nr_control_inside{ii}                            = [0];
        %end
        nr_bursts_control_inside{STIM_PERIOD_NR,ii}       = length(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii});
        mean_spike_nr(STIM_PERIOD_NR,ii,2)                = mean(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii});
        std_spike_nr(STIM_PERIOD_NR,ii,2)                 = std(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii});

        burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii}                   = burst_spike_nr{ii}(bursts_stim_outside{ii});
        nr_bursts_stim_outside{STIM_PERIOD_NR,ii}         = length(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii});
        mean_spike_nr(STIM_PERIOD_NR,ii,3)                = mean(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii});
        std_spike_nr(STIM_PERIOD_NR,ii,3)                 = std(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii});

        burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii}                    = burst_spike_nr{ii}(bursts_stim_inside{ii});
        %if isempty(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii})
         %   burst_spike_nr_stim_inside{ii}                               = [0];
        %end
        nr_bursts_stim_inside{STIM_PERIOD_NR,ii}          = length(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii});
        mean_spike_nr(STIM_PERIOD_NR,ii,4)                = mean(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii});
        std_spike_nr(STIM_PERIOD_NR,ii,4)                 = std(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii});

       if (nr_bursts_stim_inside{STIM_PERIOD_NR,ii}+nr_bursts_stim_outside{STIM_PERIOD_NR,ii} + nr_bursts_control_inside{STIM_PERIOD_NR,ii} + nr_bursts_control_outside{STIM_PERIOD_NR,ii}< 100)
            mean_spike_nr(STIM_PERIOD_NR,ii,:)                = NaN;
            std_spike_nr(STIM_PERIOD_NR,ii,:)                 = NaN;
       end
    end
end% of the STIM_PERIOD loop
    
for STIM_PERIOD_NR=1:NR_PERIODS
    %burst_spike_bin_width=0.05;
    CH_PER_PLOT=4;
    plot_nrs(1,:)=[1,2,5,6];
    plot_nrs(2,:)=[3,4,7,8];
    plot_nrs(3,:)=[9,10,13,14];
    plot_nrs(4,:)=[11,12,15,16];
    %figure_cycle=1


    for figure_cycle=1:ceil(no_bursting_ch/CH_PER_PLOT)
        figure_h(figure_cycle)=figure;
        set(figure_h(figure_cycle),'position',[ -3 39 1600 1086]);

        %determine those channels that should be plotted in the current figure
        ch_first = (figure_cycle-1)*CH_PER_PLOT+1;
        if figure_cycle < ceil(no_bursting_ch/CH_PER_PLOT)
            ch_last  = ch_first+CH_PER_PLOT-1;
        else
            ch_last  =  no_bursting_ch
        end

            for ii=ch_first:ch_last
                ch_nr_in_plot = ii-(figure_cycle-1)*CH_PER_PLOT;

                if (nr_bursts_stim_inside{STIM_PERIOD_NR,ii}+nr_bursts_stim_outside{STIM_PERIOD_NR,ii} + nr_bursts_control_inside{STIM_PERIOD_NR,ii} + nr_bursts_control_outside{STIM_PERIOD_NR,ii}> 100)


                        subplot_h{figure_cycle}(ch_nr_in_plot,1)=subplot(4,4,plot_nrs(ch_nr_in_plot,1));
                        a=hist(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii},0:max(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii}));
                        bar(0:max(burst_spike_nr_control_outside{STIM_PERIOD_NR,ii}),a./nr_bursts_control_outside{STIM_PERIOD_NR,ii},1);
                        ylabel(' normalized probability');
                        pos1=get(gca,'position');

                        subplot_h{figure_cycle}(ch_nr_in_plot,2)=subplot(4,4,plot_nrs(ch_nr_in_plot,2));
                        a=hist(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii},0:max(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii}));
                        if (~isempty(a))
                        bar(0:max(burst_spike_nr_control_inside{STIM_PERIOD_NR,ii}),a./nr_bursts_control_inside{STIM_PERIOD_NR,ii},1);
                        else
                            bar(0,0);
                        end;
                        pos2=get(gca,'position');
                        pos2(1)=pos1(1)+pos1(3)+0.025;
                        set(gca,'position',pos2);


                        subplot_h{figure_cycle}(ch_nr_in_plot,3)=subplot(4,4,plot_nrs(ch_nr_in_plot,3));
                        a=hist(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii},0:max(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii}));
                        bar(0:max(burst_spike_nr_stim_outside{STIM_PERIOD_NR,ii}),a./nr_bursts_stim_outside{STIM_PERIOD_NR,ii},1);
                        xlabel('burst length [spikes]');
                        ylabel('normalized probability');
                        pos3=get(gca, 'position');
                        pos3(2)=pos1(2)-0.18;
                        set(gca,'position',pos3);


                        subplot_h{figure_cycle}(ch_nr_in_plot,4)=subplot(4,4,plot_nrs(ch_nr_in_plot,4));
                        a=hist(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii},0:max(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii}));
                        if(~isempty(a))
                        bar(0:max(burst_spike_nr_stim_inside{STIM_PERIOD_NR,ii}),a./nr_bursts_stim_inside{STIM_PERIOD_NR,ii},1);
                        else 
                            bar(0,0);
                        end
                        xlabel('burst length [spikes]');
                        pos4=get(gca, 'position');
                        pos4(1)=pos3(1)+pos3(3)+0.025;
                        pos4(2)=pos2(2)-0.18;
                        set(gca,'position',pos4);



                    else              %the case when there are not enough bursts to make a valuable statistics, e.g. in cases when the resp. electrode (in cylcical stim esperiments) was blanked
                    continue
                    end

                    %some settings for the x and y axes
                    max_mean = max(mean_spike_nr(STIM_PERIOD_NR,ii,:));
                    max_std  = max(std_spike_nr(STIM_PERIOD_NR,ii,:));
                    set(subplot_h{figure_cycle}(ch_nr_in_plot,1:4),'xlim',[0 ceil(2*max_mean) ]);
                    for jj=1:4
                    y_range=get(subplot_h{figure_cycle}(ch_nr_in_plot,jj),'ylim');
                    y_max(jj)=y_range(2);
                    end

                    %   compare the plots between the conditions outside and inside
                    %   seperately, therefore make the same scale on the y_axis for these
                    %   cases, i.e. same scale for plot (1,3) and (2,4)
                    if y_max(1) >= y_max(3)
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,3), 'ylim',[0 y_max(1)]);
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,2), 'ylim',[0 y_max(1)]);
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,4), 'ylim',[0 y_max(1)]);
                        y_lims=get(subplot_h{figure_cycle}(ch_nr_in_plot,1), 'ylim');
                    else
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,1), 'ylim',[0 y_max(3)]);
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,2), 'ylim',[0 y_max(3)]);
                        set(subplot_h{figure_cycle}(ch_nr_in_plot,4), 'ylim',[0 y_max(3)]);
                        y_lims=get(subplot_h{figure_cycle}(ch_nr_in_plot,3), 'ylim');
                    end


    %                 if y_max(2) > y_max(4) 
    %                     set(subplot_h{figure_cycle}(ch_nr_in_plot,4), 'ylim',[0 y_max(2)])
    %                 else
    %                     set(subplot_h{figure_cycle}(ch_nr_in_plot,2), 'ylim',[0 y_max(4)])
    %                 end

                    title(subplot_h{figure_cycle}(ch_nr_in_plot,1),{['channel: ', num2str(bursting_channels_mea(ii))]});
                    x_lims=xlim;
                    axes(subplot_h{figure_cycle}(ch_nr_in_plot,1));
                    text(2/3*x_lims(2), 2/3*y_lims(2), {['mean: ',num2str(ceil(mean_spike_nr(STIM_PERIOD_NR,ii,1)*10)/10)];['std: ', num2str(ceil(std_spike_nr(STIM_PERIOD_NR,ii,1)*10)/10)]});
                    axes(subplot_h{figure_cycle}(ch_nr_in_plot,2));
                    text(2/3*x_lims(2),2/3*y_lims(2), {['mean: ',num2str(ceil(mean_spike_nr(STIM_PERIOD_NR,ii,2)*10)/10)];['std: ', num2str(ceil(std_spike_nr(STIM_PERIOD_NR,ii,2)*10)/10)]});
                    axes(subplot_h{figure_cycle}(ch_nr_in_plot,3));
                    text(2/3*x_lims(2), 2/3*y_lims(2), {['mean: ',num2str(ceil(mean_spike_nr(STIM_PERIOD_NR,ii,3)*10)/10)];['std: ', num2str(ceil(std_spike_nr(STIM_PERIOD_NR,ii,3)*10)/10)]});
                    axes(subplot_h{figure_cycle}(ch_nr_in_plot,4));
                    text(2/3*x_lims(2), 2/3*y_lims(2), {['mean: ',num2str(ceil(mean_spike_nr(STIM_PERIOD_NR,ii,4)*10)/10)];['std: ', num2str(ceil(std_spike_nr(STIM_PERIOD_NR,ii,4)*10)/10)]});
                    if (ch_nr_in_plot==1)
                       ch_nr_in_plot;
                       legend(subplot_h{figure_cycle}(1,1),'control, outside trigger');
                       legend(subplot_h{figure_cycle}(1,2),'control, inside trigger');
                       legend(subplot_h{figure_cycle}(1,3),'stimulation, outside trigger');
                       legend(subplot_h{figure_cycle}(1,4),'stimulation, inside trigger');
                    end
            end   %end for the current channel in the resp plot
            
            textbox_h{figure_cycle} = annotation(gcf,'textbox', [0.4 0.89 0.1 0.1]);
            set(textbox_h{figure_cycle},'string',{['datname: ',num2str(datname)];['stimulation period ', num2str(STIM_PERIOD_NR),', burst length distribution for various conditions' ]},'FitHeightToText','on','Interpreter','none')
  
    end %end of the plotcycle loop
end %end of the STIM_PERIOD_NR loop



%some ongoing data analysis; the mean burst length in control and stim case
%should be plotted as a scatter plot, where each plot combines several
%channels and stim periods.
%the mean spike nr are stored in mean_spike_nr{STIM_PERIOD_NR,CH_NR,PERIOD)
%where   PERIOD = 1 ==> control outside trigger
%        PERIOD = 2 ==> control inside
%        PERIOD = 3 ==> stim outside trigger
%        PERIOD = 4 ==> stim inside trigger

scatter_fig_outside=figure;
set(scatter_fig_outside,'position',[ -3 39 1600 1086])
legend_string=[];
for period_nr=1:NR_PERIODS;
    scatter_plot=scatter(mean_spike_nr(period_nr,:,1),mean_spike_nr(period_nr,:,3));
    legend_string=strvcat(legend_string,['period ', num2str(period_nr)]);
    hold all;
end
x_lims=xlim;
y_lims=ylim;

if x_lims(2) >= y_lims(2)
    ylim([0 x_lims(2)]);
    line([0 x_lims(2)],[0 x_lims(2)]);
else
    xlim([0 y_lims(2)]);
    line([0 y_lims(2)],[0 y_lims(2)]);
end

title({['datname: ', num2str(datname)];['scatter plot for mean nr. of spikes in bursts, for bursts outside trigger'];[ 'x-axis:  control, y-axis: stim period, datapoints for all control-stim cycles, and various channels']},'Interpreter','none');
xlabel('mean burst length (nr. of spikes), outside trigger during control period');
ylabel('mean burst length (nr. of spikes), outside during stim period');
legend(legend_string);


%calculate the disribution for the  'deviation from diagonal', i.e.
%calculate for each datapoint (which is in the scatter plot a combination
%of control and stim period), the relative effect of the stimulation, which is
%here expressed as the mean nr. of spikes in a burst in the stimulation period
%divided by the mean nr. of spikes in a burst in the control period

mean_diff_outside=zeros(NR_PERIODS,no_bursting_ch);
mean_diff_inside=zeros(NR_PERIODS,no_bursting_ch);
mean_ratio_outside=zeros(NR_PERIODS,no_bursting_ch);
mean_ratio_inside=zeros(NR_PERIODS,no_bursting_ch);
for period_nr=1:NR_PERIODS
    for ch_nr=1:no_bursting_ch
        if ~isnan(mean_spike_nr(period_nr,ch_nr,1))
            mean_diff_outside(period_nr,ch_nr)     = mean_spike_nr(period_nr,ch_nr,1)-mean_spike_nr(period_nr,ch_nr,3);
            mean_diff_inside(period_nr,ch_nr)      = mean_spike_nr(period_nr,ch_nr,2)-mean_spike_nr(period_nr,ch_nr,4);
            %take care, I divide in the ratio calculation and I change the
            %order
            mean_ratio_outside(period_nr,ch_nr)    = mean_spike_nr(period_nr,ch_nr,3)/mean_spike_nr(period_nr,ch_nr,1);
            mean_ratio_inside(period_nr,ch_nr)     = mean_spike_nr(period_nr,ch_nr,4)/mean_spike_nr(period_nr,ch_nr,2);
        else
            mean_diff_outside(period_nr,ch_nr)     = NaN;
            mean_diff_inside(period_nr,ch_nr)      = NaN;
            mean_ratio_outside(period_nr,ch_nr)    = NaN;
            mean_ratio_inside(period_nr,ch_nr)     = NaN;
        end
        
       
    end
end

%reshaphe the current datavector, in order to run some distribution
%estimate over it
mean_diff_outside_distr=reshape(mean_diff_outside,1,size(mean_diff_outside,1)*size(mean_diff_outside,2));
mean_diff_outside_distr(isnan(mean_diff_outside_distr))=[];
[muhat_outside sigmahat_outside]=normfit(mean_diff_outside_distr);
mean_ratio_outside_distr=reshape(mean_ratio_outside,1,size(mean_ratio_outside,1)*size(mean_ratio_outside,2));
mean_ratio_outside_distr(isnan(mean_ratio_outside_distr))=[];
[muhat_ratio_outside sigmahat_ratio_outside]=normfit(mean_ratio_outside_distr);

%Generate a uipanel in the scatter plot figure, and plot the
%mean_diff_outside distribution, this is done as follows
%set the desired figure as  current figure
set(scatter_fig_outside);
%create an uipanel atthe specified position, relative to the figure
%coordinates, the current figure is also parent to the uipanel
uipanel_h=uipanel('position', [0.135 0.62 0.25 0.3]); 
%now create some axes in the uipanelm the position is relative to the uipanel coordinates, the parent has to be defined 
uipanel_axes=axes('parent', uipanel_h,'position', [0.15 0.15 0.75 0.7]);
%now plots can be made as usual in  the uipanle axes
[ks_prob_val_diff,xi]=ksdensity(uipanel_axes,mean_diff_outside_distr);
%plot(xi,ks_prob_val_diff,'b');
hold on;
%plot(uipanel_axes,-30:0.01:30, normpdf(-30:0.01:30,muhat_outside,sigmahat_outside),'b--');
hold on;
[ks_prob_val_ratio,xi]=ksdensity(uipanel_axes,mean_ratio_outside_distr,'width', 0.1);
plot(xi,ks_prob_val_ratio,'r');
hold on;
plot(uipanel_axes,-30:0.01:30, normpdf(-30:0.01:30,muhat_ratio_outside,sigmahat_ratio_outside),'r--');
hold on
y_lims=ylim;
%line_h(1) = line([0 0],[0 y_lims(2)+0.05]);
line_h(2) = line([1 1],[0 y_lims(2)+0.05]);
%set(line_h(1),'Color','b');
%set(line_h(2),'Color', 'r');
xlim([-2 2]);
%title({[ 'mean burst length control - mean burst length stim (in blue)'];[ 'mean burst length stim /mean burst length control (in red)'] });
title({['mean burst length stim /mean burst length control (in red)'] });
ylabel('probability');
xlabel('ratio mean nr. sp/burst stim/control period');
%legend_ha=legend('ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_outside*100)/100),', sigma: ', num2str(ceil(sigmahat_outside*100)/100)],'ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_ratio_outside*100)/100),', sigma: ', num2str(ceil(sigmahat_ratio_outside*100)/100)]);
legend_ha=legend('ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_ratio_outside*100)/100),', sigma: ', num2str(ceil(sigmahat_ratio_outside*100)/100)]);
set(legend_ha,'fontsize',8);



%do all the same things alos for the inside condition;
%plot the scatter plot first
scatter_fig_inside=figure;
set(scatter_fig_inside,'position',[ -3 39 1600 1086])
legend_string=[];
for period_nr=1:NR_PERIODS;
    scatter_plot=scatter(mean_spike_nr(period_nr,:,2),mean_spike_nr(period_nr,:,4));
    legend_string=strvcat(legend_string,['period ', num2str(period_nr)]);
    hold all;
end
x_lims=xlim;
y_lims=ylim;

if x_lims(2) >= y_lims(2)
    ylim([0 x_lims(2)]);
    xlim([0 x_lims(2)]);
    line([0 x_lims(2)],[0 x_lims(2)]);
else
    xlim([0 y_lims(2)]);
    ylim([0 y_lims(2)]);
    line([0 y_lims(2)],[0 y_lims(2)]);
end

title({['datname: ', num2str(datname)];['scatter plot for mean nr. of spikes in bursts, for bursts inside trigger'];[ 'x-axis:  control, y-axis: stim period, datapoints for all control-stim cycles, and various channels']},'Interpreter','none');
xlabel('mean burst length (nr. of spikes), inside trigger, during control period');
ylabel('mean burst length (nr. of spikes), inside trigger, during stim period');
legend(legend_string);

%reshape the datavector to run some distrbution fits
mean_diff_inside_distr=reshape(mean_diff_inside,1,size(mean_diff_inside,1)*size(mean_diff_inside,2));
mean_diff_inside_distr(isnan(mean_diff_inside_distr))=[];
[muhat_inside sigmahat_inside]=normfit(mean_diff_inside_distr);
%reshape the datavector to run some distrbution fits
mean_ratio_inside_distr=reshape(mean_ratio_inside,1,size(mean_ratio_inside,1)*size(mean_ratio_inside,2));
mean_ratio_inside_distr(isnan(mean_ratio_inside_distr))=[];
[muhat_ratio_inside sigmahat_ratio_inside]=normfit(mean_ratio_inside_distr);

%make ther inlet plot as described above
set(scatter_fig_inside);
uipanel_h=uipanel('position', [0.135 0.62 0.25 0.3]); 
uipanel_axes=axes('parent', uipanel_h,'position', [0.15 0.15 0.75 0.7]);
%[ks_prob_val_mean,xi]=ksdensity(uipanel_axes,mean_diff_inside_distr);
%plot(xi,ks_prob_val_mean,'b');
hold on;
%plot(uipanel_axes,-40:0.01:40, normpdf(-40:0.01:40,muhat_inside,sigmahat_inside),'b--');
hold on;
[ks_prob_val_ratio,xi]=ksdensity(uipanel_axes,mean_ratio_inside_distr,'width', 0.1);
plot(xi,ks_prob_val_ratio,'r');
hold on;
plot(uipanel_axes,-40:0.01:40, normpdf(-40:0.01:40,muhat_ratio_inside,sigmahat_ratio_inside),'r--');
hold on;
y_lims=ylim;
%line_h(1) = line([0 0],[0 y_lims(2)+0.05]);
line_h(2) = line([1 1],[0, y_lims(2)+0.05]);
xlim([-2 2]);
%title({[ 'mean burst length control - mean burst length stim (in blue)'];[ 'mean burst length stim /mean burst length control (in red)'] });
title({['mean burst length stim /mean burst length control (in red)'] });
ylabel('probability');
xlabel('ratio  mean nr. sp/burst stim/control period');
%legend_ha=legend('ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_inside*100)/100),', sigma: ', num2str(ceil(sigmahat_inside*100)/100)],'ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_ratio_inside*100)/100),', sigma: ', num2str(ceil(sigmahat_ratio_inside*100)/100)]);
legend_ha=legend('ksdensity estimate', ['estimated normpdf, mu: ', num2str(ceil(muhat_ratio_inside*100)/100),', sigma: ', num2str(ceil(sigmahat_ratio_inside*100)/100)]);

set(legend_ha,'fontsize',8);








    