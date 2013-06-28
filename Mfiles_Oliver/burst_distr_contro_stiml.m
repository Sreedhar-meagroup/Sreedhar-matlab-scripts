%16/03/07
%As an outcome of the progress report and discussion with Uli, he suggested
%to plot burst_length distributions for various conditions, e.g. in the
%control case outside the trigger, in the control case inside the trigger,
%in the stim case outside the stim, in the stim case inside the stim.
%to see how the stimulation does interfere with with the burst, i.e. if they
%can possibly terminate them


STIM_START=7000;  %given in sec 


%first of all find the control and stim triggers
control_trigger = find(ls.channel==60 & ls.time<STIM_START);
control_trigger = ls.time(control_trigger);
stim_trigger    = find(ls.channel==60 & ls.time>STIM_START);
stim_trigger    = ls.time(stim_trigger);


%define a cell burst_end with entries for each channel when the burst ends,
%then, the burts length can easily be calculated with burst_end-burst_onset
burst_end=cell(1,no_bursting_ch);
burst_length=cell(1,no_bursting_ch);
for ii=1:no_bursting_ch
    active_ch=bursting_channels(ii);
    for jj=1:length(burst_detection{1,active_ch})
        burst_end{1,ii}{jj,1}=burst_detection{1,active_ch}{jj,3}(end);
        burst_length{ii}(jj)=burst_end{1,ii}{jj,1}-burst_onset{1,ii}{jj,1};
    end
end


bursts_control_inside = cell(1,no_bursting_ch);
bursts_stim_inside    = cell(1,no_bursting_ch);
for ii=1:no_bursting_ch
 ii
    for jj=1:length(control_trigger)
        control_inside_ind=find([burst_onset{1,ii}{:}] < STIM_START & [burst_onset{1,ii}{:}] <control_trigger(jj)  & ([burst_onset{1,ii}{:}]+burst_length{ii}) >control_trigger(jj));
        if ~isempty(control_inside_ind)
            bursts_control_inside{ii}=cat(2,bursts_control_inside{ii},control_inside_ind);
        end
    end
 
    for kk=1:length(stim_trigger)
        stim_inside_ind = find([burst_onset{1,ii}{:}] > STIM_START & [burst_onset{1,ii}{:}] <stim_trigger(kk)  & ([burst_onset{1,ii}{:}]+burst_length{ii}) >stim_trigger(kk));
        if ~isempty(stim_inside_ind)
            bursts_stim_inside{ii} = cat(2,bursts_stim_inside{ii},stim_inside_ind);
        end
    end
    
    bursts_control_outside{ii} = setdiff(1:length(find([burst_onset{1,ii}{:}] < STIM_START)),bursts_control_inside{ii})
    bursts_stim_outside{ii}    = setdiff(find([burst_onset{1,ii}{:}] > STIM_START), bursts_stim_inside{ii})
end


    
    
    burst_length_bin_width=0.05;
for ii=1:no_bursting_ch
    figure_h(ii)=figure;
    set(figure_h(ii),'position',[ -3 39 1600 1086])
    
    burst_length_control_outside{ii} = burst_length{ii}(bursts_control_outside{ii});
    nr_bursts_control_outside        = length(burst_length_control_outside{ii});
    burst_length_control_inside{ii}  = burst_length{ii}(bursts_control_inside{ii}); 
    nr_bursts_control_inside         = length(burst_length_control_inside{ii});
    burst_length_stim_outside{ii}    = burst_length{ii}(bursts_stim_outside{ii});
    nr_bursts_stim_outside           = length(burst_length_stim_outside{ii});
    burst_length_stim_inside{ii}     = burst_length{ii}(bursts_stim_inside{ii});
    nr_bursts_stim_inside            = length(burst_length_stim_inside{ii});
    
    subplot_h(ii,1)=subplot(2,2,1)
    a=hist(burst_length_control_outside{ii},0: burst_length_bin_width:max(burst_length_control_outside{ii}))
    bar(0:burst_length_bin_width:max(burst_length_control_outside{ii}),a./length(burst_length_control_outside{ii}),1);
    title({['datname: ', num2str(datname)];['channel: ', num2str(bursting_channels_mea(ii))];['burst length distribution for bursts during control period, outside the trigger']},'Interpreter','none');
    xlabel('burst length [sec]')
    ylabel(' normalized probability')
    
    subplot_h(ii,2)=subplot(2,2,2)
    a=hist(burst_length_control_inside{ii},0:burst_length_bin_width:max(burst_length_control_inside{ii}));
    bar(0:burst_length_bin_width:max(burst_length_control_inside{ii}),a./length(burst_length_control_inside{ii}),1);
    title('burst length distribution for bursts during control, inside the trigger');
    xlabel('burst length [sec]')
    ylabel('normalized probability')
    
    subplot_h(ii,3)=subplot(2,2,3)
    a=hist(burst_length_stim_outside{ii},0:burst_length_bin_width:max(burst_length_stim_outside{ii}));
    bar(0:burst_length_bin_width:max(burst_length_stim_outside{ii}),a./length(burst_length_stim_outside{ii}),1);
    title('burst length distribution for bursts during stimulation period, outside the stimulation');
    xlabel('burst length [sec]')
    ylabel('normalized probability')
    
    subplot_h(ii,4)=subplot(2,2,4)
    a=hist(burst_length_stim_inside{ii},0:burst_length_bin_width:max(burst_length_stim_inside{ii}));
    bar(0:burst_length_bin_width:max(burst_length_stim_inside{ii}),a./length(burst_length_stim_inside{ii}),1);
    title('burst length distribution for bursts during stimulation, inside the stimulation');
    xlabel('burst length [sec]')
    ylabel('normalized probability')
    
    set(subplot_h(ii,:),'xlim',[0 2]);
    for jj=1:4
    y_range=get(subplot_h(ii,jj),'ylim');
    y_max(jj)=y_range(2);
    end
    
    %   compare the plots between the conditions outside and inside
    %   seperately, therefore make the same scale on the y_axis for these
    %   cases, i.e. same scale for plot (1,3) and (2,4)
    if y_max(1) > y_max(3)
        set(subplot_h(ii,3), 'ylim',[0 y_max(1)])
    else
        set(subplot_h(ii,1), 'ylim',[0 y_max(3)])
    end
    
    
    if y_max(2) > y_max(4) 
        set(subplot_h(ii,4), 'ylim',[0 y_max(2)])
    else
        set(subplot_h(ii,2), 'ylim',[0 y_max(4)])
    end
    
end
    
        
        
        
        
%     control_ind = find([burst_onset{1,ii}{:}] < STIM_START);
%     stim_ind    = find([burst_onset{1,ii}{:}] > STIM_START);
%     control_burst_onsets{ii} = [burst_onset{1,ii}{control_ind}];
%     stim_burst_onsets{ii}    = [burst_onset{1,ii}{stim_ind}];
%     for jj=1:length(control_trigger)
    