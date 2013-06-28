%16/03/07
%As an outcome of the progress report and discussion with Uli, he suggested
%to plot burst_length distributions for various conditions, e.g. in the
%control case outside the trigger, in the control case inside the trigger,
%in the stim case outside the stim, in the stim case inside the stim.
%to see how the stimulation does interfere with with the burst, i.e. if they
%can possibly terminate them
%04/04/07
%Modification for cyclical stim protocols

STIMPERIOD_LENGTH    = 5400;   %all times given in sec
CONTROLPERIOD_LENGTH = 5400;
STIM_PERIOD_NR       = 2;
CONTROL_START        = (STIM_PERIOD_NR-1)*(STIMPERIOD_LENGTH+CONTROLPERIOD_LENGTH)
CONTROL_END          = CONTROL_START+CONTROLPERIOD_LENGTH;
STIM_START           = CONTROL_END; 
STIM_END             = STIM_START+STIMPERIOD_LENGTH;


%first of all find the control and stim triggers
control_trigger = find(ls.channel==60 & ls.time<CONTROL_END & ls.time>CONTROL_START);
control_trigger = ls.time(control_trigger);
stim_trigger    = find(ls.channel==60 & ls.time>STIM_START & ls.time<STIM_END);
stim_trigger    = ls.time(stim_trigger);


%define a cell burst_end with entries for each channel when the burst ends,
%then, the burts length can easily be calculated with burst_end-burst_onset
burst_end=cell(1,no_bursting_ch);
burst_length=cell(1,no_bursting_ch);
for ii=1:no_bursting_ch
    active_ch=bursting_channels(ii);
    for jj=1:length(burst_detection{1,active_ch})
        burst_end{1,ii}{jj,1} = burst_detection{1,active_ch}{jj,3}(end);
        burst_length{ii}(jj)  = burst_end{1,ii}{jj,1}-burst_onset{1,ii}{jj,1};
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
    
    bursts_control_outside{ii} = setdiff(find([burst_onset{1,ii}{:}] > CONTROL_START & [burst_onset{1,ii}{:}]<CONTROL_END),bursts_control_inside{ii});
    bursts_stim_outside{ii}    = setdiff(find([burst_onset{1,ii}{:}] > STIM_START & [burst_onset{1,ii}{:}]<STIM_END), bursts_stim_inside{ii});
end


    
    
 burst_length_bin_width=0.05;
 
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
           

            burst_length_control_outside{ii} = burst_length{ii}(bursts_control_outside{ii});
            nr_bursts_control_outside        = length(burst_length_control_outside{ii});
            burst_length_control_inside{ii}  = burst_length{ii}(bursts_control_inside{ii}); 
            nr_bursts_control_inside         = length(burst_length_control_inside{ii});
            burst_length_stim_outside{ii}    = burst_length{ii}(bursts_stim_outside{ii});
            nr_bursts_stim_outside           = length(burst_length_stim_outside{ii});
            burst_length_stim_inside{ii}     = burst_length{ii}(bursts_stim_inside{ii});
            nr_bursts_stim_inside            = length(burst_length_stim_inside{ii});

                if (nr_bursts_stim_inside+nr_bursts_stim_outside + nr_bursts_control_inside + nr_bursts_control_outside> 100)


                    subplot_h{figure_cycle}(ch_nr_in_plot,1)=subplot(4,4,plot_nrs(ch_nr_in_plot,1));
                    a=hist(burst_length_control_outside{ii},0: burst_length_bin_width:max(burst_length_control_outside{ii}));
                    bar(0:burst_length_bin_width:max(burst_length_control_outside{ii}),a./length(burst_length_control_outside{ii}),1);
                    %title({['datname: ', num2str(datname)];['channel: ', num2str(bursting_channels_mea(ii))];['burst length distribution for bursts during control period, outside the trigger']},'Interpreter','none');
                    %xlabel('burst length [sec]')
                    ylabel(' normalized probability')
                    pos1=get(gca,'position');
                    %legend('control, outside trigger');

                    subplot_h{figure_cycle}(ch_nr_in_plot,2)=subplot(4,4,plot_nrs(ch_nr_in_plot,2));
                    a=hist(burst_length_control_inside{ii},0:burst_length_bin_width:max(burst_length_control_inside{ii}));
                    bar(0:burst_length_bin_width:max(burst_length_control_inside{ii}),a./length(burst_length_control_inside{ii}),1);
                    %title('burst length distribution for bursts during control, inside the trigger');
                    %xlabel('burst length [sec]')
                    %ylabel('normalized probability')
                    pos2=get(gca,'position');
                    pos2(1)=pos1(1)+pos1(3)+0.025;
                    set(gca,'position',pos2);
                    %legend('stimulation, outside trigger');

                    subplot_h{figure_cycle}(ch_nr_in_plot,3)=subplot(4,4,plot_nrs(ch_nr_in_plot,3));
                    a=hist(burst_length_stim_outside{ii},0:burst_length_bin_width:max(burst_length_stim_outside{ii}));
                    bar(0:burst_length_bin_width:max(burst_length_stim_outside{ii}),a./length(burst_length_stim_outside{ii}),1);
                    %title('burst length distribution for bursts during stimulation period, outside the stimulation');
                    xlabel('burst length [sec]')
                    ylabel('normalized probability')
                    pos3=get(gca, 'position');
                    pos3(2)=pos1(2)-0.18;
                    set(gca,'position',pos3)
                    %legend('control, inside trigger');

                    subplot_h{figure_cycle}(ch_nr_in_plot,4)=subplot(4,4,plot_nrs(ch_nr_in_plot,4));
                    a=hist(burst_length_stim_inside{ii},0:burst_length_bin_width:max(burst_length_stim_inside{ii}));
                    bar(0:burst_length_bin_width:max(burst_length_stim_inside{ii}),a./length(burst_length_stim_inside{ii}),1);
                    %title('burst length distribution for bursts during stimulation, inside the stimulation');
                    xlabel('burst length [sec]')
                    %ylabel('normalized probability')
                    pos4=get(gca, 'position')
                    pos4(1)=pos3(1)+pos3(3)+0.025
                    pos4(2)=pos2(2)-0.18;
                    set(gca,'position',pos4);
                    %legend('stimulation, inside trigger');

                else              %the case when there are not enough bursts to make a valuable statistics, e.g. in cases when the resp. electrode (in cylcical stim esperiments) was blanked
                continue
                end

                %some settings for the x and y axes
                set(subplot_h{figure_cycle}(ch_nr_in_plot,1:4),'xlim',[0 2]);
                for jj=1:4
                y_range=get(subplot_h{figure_cycle}(ch_nr_in_plot,jj),'ylim');
                y_max(jj)=y_range(2);
                end

                %   compare the plots between the conditions outside and inside
                %   seperately, therefore make the same scale on the y_axis for these
                %   cases, i.e. same scale for plot (1,3) and (2,4)
                if y_max(1) > y_max(3)
                    set(subplot_h{figure_cycle}(ch_nr_in_plot,3), 'ylim',[0 y_max(1)])
                else
                    set(subplot_h{figure_cycle}(ch_nr_in_plot,1), 'ylim',[0 y_max(3)])
                end


                if y_max(2) > y_max(4) 
                    set(subplot_h{figure_cycle}(ch_nr_in_plot,4), 'ylim',[0 y_max(2)])
                else
                    set(subplot_h{figure_cycle}(ch_nr_in_plot,2), 'ylim',[0 y_max(4)])
                end

                title(subplot_h{figure_cycle}(ch_nr_in_plot,1),{['channel: ', num2str(bursting_channels_mea(ii))]});
        end   %end for the current channel in the resp plot
        
        legend(subplot_h{figure_cycle}(1,1),'control, outside trigger');
        legend(subplot_h{figure_cycle}(1,2),'control, inside trigger');
        legend(subplot_h{figure_cycle}(1,3),'stimulation, outside trigger');
        legend(subplot_h{figure_cycle}(1,4),'stimulation, inside trigger');

        textbox_h{figure_cycle} = annotation(gcf,'textbox', [0.4 0.89 0.1 0.1]);
        set(textbox_h{figure_cycle},'string',{['datname: ',num2str(datname)];['stimulation period ', num2str(STIM_PERIOD_NR),', burst length distribution for various conditions' ]},'FitHeightToText','on','Interpreter','none')

        
end %end of the plotcycle loop







    