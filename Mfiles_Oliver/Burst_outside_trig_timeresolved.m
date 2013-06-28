%22/01/07
%make a time resolved analysis of datasets with triggers (stimulation or fakestim). 
%I.e. look how he stimulaion influences the burst_length, burst_intervals over TIME.
%also look how the bursts  that are not  around the trigger (burts outside) are affected
% by the stimulation. therefore find the bursts that are around a trigger
% and those that are not around a trigger and store them in separate
% arrays.
% This mfile works on one dataset, not as the mfile burst_aroundtrig, which
% compares a control and a stim case.

%several other mfiles have to be run to carry out the analysis in this mfile
%StimulusEffect to get stimulusraster
%burst_detection_all_ch to do a burst detection on all channels and get the
%                       necessary arrays
%burst_characteristics to get the burst onsets and calculation of burst
%                      intervals
% THE CAHNNELS under investigation must al be the same in all
% of the mfiles, most of the time stored in an array bursting_channels




%choose a set of channels under imnvestigation first;
bursting_channels_mea=[47];
bursting_channels      = cr2hw(bursting_channels_mea)+1;
no_bursting_ch         = length(bursting_channels);


%find the triggers
trig_ind    = find(ls.channel==60);
trig_times  = ls.time(trig_ind);
trig_num    = length(trig_times);

TRIG_WINDOW=0.1;

clear burst_outside_trig;
clear b_length_outside_trig;
for b_ch=1:no_bursting_ch
    burst_ch = bursting_channels(b_ch)
    trig_ct          = 1;
    burst_outside_ct = 0;
    for burst_ct=1:size([burst_detection{1,burst_ch}],1)-1  %cycle through all bursts, size along the rows, i.e how many bursts
        if (find( burst_detection{1,burst_ch}{burst_ct,3} > trig_times(trig_ct) & ( burst_detection{1,burst_ch}{burst_ct,3}  < (trig_times(trig_ct)+TRIG_WINDOW))  ) > 0 & trig_ct < trig_num)  %i.e. if there are spike in a window around a trigger
           %burst_around_trig{b_ch,trig_ct}    = burst_ct;  %this stores the burst index which has a
           %b_length_after_trig{b_ch, trig_ct} = burst_detection{1,burst_ch}{burst_ct,3}(end) - trig_times(trig_ct);
           trig_ct = trig_ct+1;

        elseif (burst_detection{1,burst_ch}{burst_ct,3}(1) < trig_times(trig_ct) & burst_detection{1,burst_ch}{burst_ct+1,3}(1)-TRIG_WINDOW > trig_times(trig_ct)  & trig_ct < trig_num)   %i.e,. if two subsequent bursts taht lie between a trigger dont have burst around the trigger 
            %burst_around_trig{b_ch,trig_ct}   = NaN;
            %b_length_after_trig{b_ch,trig_ct} = 0;
            burst_outside_trig{b_ch,burst_outside_ct+1}    = burst_ct;
            b_length_outside_trig{b_ch,burst_outside_ct+1} = burst_detection{1,burst_ch}{burst_ct,3}(end) - burst_detection{1,burst_ch}{burst_ct,3}(1);
            trig_ct                                        = trig_ct+1;
            burst_outside_ct                               = burst_outside_ct+1;
        else
            burst_outside_trig{b_ch,burst_outside_ct+1}    = burst_ct;
            b_length_outside_trig{b_ch,burst_outside_ct+1} = burst_detection{1,burst_ch}{burst_ct,3}(end) - burst_detection{1,burst_ch}{burst_ct,3}(1);
            burst_outside_ct                               = burst_outside_ct+1;

        end
    end
 
    outside_ind=[burst_outside_trig{b_ch,:}];
    b_interval_outside_trig{b_ch,:}=[burst_intervals_ch{1,b_ch}{outside_ind,:}];   %TAKE CARE, this is now a no_bursting_ch X 1 cell with the column entries in the resspective cell
    
end  %of the b_ch loop



%make also a moving average for the burst length of the bursts that are
%outside the trigger
 b_interval_outside_trig_ma=cell(1,no_bursting_ch);
AVERAGE_EX=10;
for b_ch=1:no_bursting_ch;
      %burst_ch=bursting_channels(b_ch)
     
    for i = 1:size([b_length_outside_trig{b_ch,:}],2);
        if i < AVERAGE_EX+1
            b_length_outside_trig_ma{b_ch,i }   = 1/(2*AVERAGE_EX+1)*((AVERAGE_EX+1)*b_length_outside_trig{b_ch,i} + sum([b_length_outside_trig{b_ch,(i+1):(i+AVERAGE_EX+1)}]));
            b_interval_outside_trig_ma{b_ch}(i) = 1/(2*AVERAGE_EX+1)*((AVERAGE_EX+1)*b_interval_outside_trig{b_ch}(i) + sum([b_interval_outside_trig{b_ch}(i+1:(i+AVERAGE_EX+1))])); 
        elseif i > size([b_length_outside_trig{b_ch,:}],2) -(AVERAGE_EX+1)
            b_length_outside_trig_ma{b_ch,i}    = 1/(2*AVERAGE_EX+1)*(sum([b_length_outside_trig{b_ch,(i-AVERAGE_EX):i-1}]) + (AVERAGE_EX+1)*b_length_outside_trig{b_ch,i} );
            b_interval_outside_trig_ma{b_ch}(i) = 1/(2*AVERAGE_EX+1)*(sum([b_interval_outside_trig{b_ch}((i-AVERAGE_EX):i-1)]) + (AVERAGE_EX+1)*b_interval_outside_trig{b_ch}(i) );
        else
            b_length_outside_trig_ma{b_ch,i}    = 1/(2*AVERAGE_EX+1)*sum([b_length_outside_trig{b_ch,i-AVERAGE_EX:i+AVERAGE_EX}]);
            b_interval_outside_trig_ma{b_ch}(i) = 1/(2*AVERAGE_EX+1)*sum([b_interval_outside_trig{b_ch}(i-AVERAGE_EX:i+AVERAGE_EX)]);
        end
    end
end
        



TRIALS_LIM  = 100;
PSTH_EXTEND = 2.5;
PSTH_BIN_WIDTH = 0.01;
psthvec_first = zeros(no_bursting_ch,2*PSTH_EXTEND/PSTH_BIN_WIDTH);  % for the first few trials
psthvec_last  = zeros(no_bursting_ch,2*PSTH_EXTEND/PSTH_BIN_WIDTH);  % for the last few trials
trig_last  = (trig_num-TRIALS_LIM+1):trig_num;
psthxvec=([-PSTH_EXTEND:PSTH_BIN_WIDTH:PSTH_EXTEND-PSTH_BIN_WIDTH])+PSTH_BIN_WIDTH/2;

%make a modified psthvector for the first x trials and the last x trials
%seperatly
%the psthvec_first/last(b_ch,bin_nr) store the psth counts for the
%respective channel under investigation (see bursting_channels) in the bin bin_nr
%bin_nr are from 1:2*PSTH_EXTEND/PSTH_BIN_WIDTH and are also the index in
%psthxvec, which gives the time relative to the trigger_time in the
%specified stepsize (i.e. PSTH_BIN_WIDTH)
for b_ch=1:no_bursting_ch
    burst_ch=bursting_channels(b_ch);
    spiketimes_ind = find(ls.channel==burst_ch-1);
    spiketimes     = ls.time(spiketimes_ind);
    
    for trig_ct = 1:TRIALS_LIM
        trig_ct_first = trig_ct;
        trig_ct_last  = trig_last(trig_ct);
        trigger_time_first    = trig_times(trig_ct_first);
        trigger_time_last     = trig_times(trig_ct_last);
        spike_ind_first       = find (spiketimes > (trigger_time_first-PSTH_EXTEND) & spiketimes < (trigger_time_first+PSTH_EXTEND));
        spike_ind_last        = find (spiketimes > (trigger_time_last-PSTH_EXTEND) & spiketimes < (trigger_time_last+PSTH_EXTEND));
        ch_spikes_first       = spiketimes(spike_ind_first);
        ch_spikes_last        = spiketimes(spike_ind_last);
        
        for bin_nr = 1: length(psthvec_first)
            left_edge_first            = trigger_time_first - PSTH_EXTEND + (bin_nr-1)*PSTH_BIN_WIDTH;
            left_edge_last             = trigger_time_last  - PSTH_EXTEND + (bin_nr-1)*PSTH_BIN_WIDTH;
            insidebin_first            = length(find(ch_spikes_first >= left_edge_first & ch_spikes_first < (left_edge_first+PSTH_BIN_WIDTH)));
            insidebin_last             = length(find(ch_spikes_last >= left_edge_last & ch_spikes_last < (left_edge_last+PSTH_BIN_WIDTH)));
            psthvec_first(b_ch,bin_nr) = psthvec_first(b_ch,bin_nr) + insidebin_first;
            psthvec_last(b_ch,bin_nr)  = psthvec_last(b_ch,bin_nr) + insidebin_last;
        end
        
    end
    
end


%determine the burstno (outside-bursts) that comes right before the
%TRIALS_LIM burst, to see which bursts lie before the "first trials" and which
%lie after the "last trials"

time_lim_first = trig_times(TRIALS_LIM);
time_lim_last  = trig_times(trig_num-TRIALS_LIM+1);
lim_first = zeros(1,no_bursting_ch);
lim_last  = zeros(1,no_bursting_ch);
for b_ch=1:no_bursting_ch
    lim_ind_first = find([burst_onset{1,b_ch}{:,1}]> time_lim_first);
    lim_ind_last  = find([burst_onset{1,b_ch}{:,1}]> time_lim_last);
    if isempty(lim_ind_last)
        lim_last(b_ch)=size([burst_onset{1,b_ch}],1)-1;
    else
        lim_first(b_ch) = lim_ind_first(1)-1;  %this stores just the burst no, not the real time, but this is sufficient to plot it
        lim_last(b_ch)  = lim_ind_last(1)-1;
    end
    %lim_last(b_ch)  = lim_ind_last(1)-1;
    %however, this stores the burst no as they appear on the channels, but
    %in the one plot below, I plot the bursts only as they appear outside,
    %so the numbering is not equal, correct for that
    lim_ind_outside_first   = find([burst_outside_trig{b_ch,:}]>=lim_first(b_ch));
    lim_ind_outside_last    = find([burst_outside_trig{b_ch,:}]>=lim_last(b_ch));
    lim_outside_first(b_ch) = lim_ind_outside_first(1);
    lim_outside_last(b_ch)  = lim_ind_outside_last(1);
end;

%plot the results
for b_ch=1:no_bursting_ch
     burst_ch=bursting_channels(b_ch);
     fig_h(b_ch)=figure;
    
     subplot(3,2,1)
     for trial=1:TRIALS_LIM
         plot(stimulusraster(bursting_channels(b_ch),1:noofspikes(bursting_channels(b_ch),trial),trial),trial*ones(noofspikes(bursting_channels(b_ch),trial),1),'*k','MarkerSize',2);
         hold on
     end;
         xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
         ylabel('trial no.', 'Fontsize', 14);  
         set(gca,'YLim',[0 TRIALS_LIM]); % manuell
         set(gca,'XLim',[XDATAPRE XDATAPOST]); 
         set(gca,'FontSize',14);
         title({['dataset: ', datname];['channel ', num2str(bursting_channels_mea(b_ch))]}, 'Interpreter', 'none');
         
         
     subplot(3,2,2)
     for trial=(trig_num-TRIALS_LIM+1):trig_num;
         plot(stimulusraster(bursting_channels(b_ch),1:noofspikes(bursting_channels(b_ch),trial),trial),trial*ones(noofspikes(bursting_channels(b_ch),trial),1),'*k','MarkerSize',2);
         hold on
     end;
         xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
         ylabel('trial no.', 'Fontsize', 14);  
         set(gca,'YLim',[trig_num-TRIALS_LIM+1 trig_num]); % manuell
         set(gca,'XLim',[XDATAPRE XDATAPOST]); 
         set(gca,'FontSize',14);
         title({['dataset: ', datname];['channel ', num2str(bursting_channels_mea(b_ch))]}, 'Interpreter', 'none');
         
        
     subplot(3,2,3)
        plot(psthxvec,psthvec_first(b_ch,:));
        xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
        ylabel('counts', 'Fontsize', 14);  
        set(gca,'YLim',[0 1.25*max(max(psthvec_first(b_ch,:),psthvec_last(b_ch,1)))]); % manuell
        set(gca,'XLim',[XDATAPRE XDATAPOST]); 
        set(gca,'FontSize',14);
     
     
     
     
     subplot(3,2,4)
        plot(psthxvec,psthvec_last(b_ch,:));
        xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
        ylabel('counts', 'Fontsize', 14);  
        set(gca,'YLim',[0 1.25*max(max(psthvec_first(b_ch,:),psthvec_last(b_ch,1)))]); % manuell
        set(gca,'XLim',[XDATAPRE XDATAPOST]); 
        set(gca,'FontSize',14);
         
    
    outside_ind = [burst_outside_trig{b_ch,:}];
    subplot(3,2,5)
    bar(1:length([b_length_outside_trig{b_ch,:}]),[b_length_outside_trig{b_ch,:}])  %plot the burst length in sec
    hold on;
    plot(1:length([b_length_outside_trig_ma{b_ch,:}]),[b_length_outside_trig_ma{b_ch,:}],'r','LineWidth',2)  %plot also the moving average of the burst length for the bursts outside the triiger
    %bar(1:length(outside_ind),[burst_detection{1,burst_ch}{outside_ind,2}])  % bar plot of the burst length (nr. of spikes) that are outside the triggers
    hold on;
    line(lim_outside_first(b_ch)*ones(1,2),0:1.5:1.5,'Color','g');
    hold on;
    line(lim_outside_last(b_ch)*ones(1,2),0:1.5:1.5,'Color','g');
    xlabel('burst nr. (outside trigger) ','FontSize',14);
    ylabel({[' burst length [sec]'];['moving averaged (red)']},'FontSize',14);
    set(gca,'XLim',[0 length(outside_ind)]);
    set(gca,'FontSize',14);
    
    subplot(3,2,6)
    bar(1:length(b_interval_outside_trig{b_ch}),b_interval_outside_trig{b_ch})
    hold on;
    plot(1:length(b_interval_outside_trig_ma{b_ch}),b_interval_outside_trig_ma{b_ch},'r','Linewidth',2);
    xlabel('burst nr. (outside trigger)','FontSize',14);
    ylabel('Inter burst interval [sec]','FontSize',14);
    set(gca,'XLim',[0 length(b_interval_outside_trig{b_ch})]);
    set(gca,'FontSize',14);
end
    
    
    
    
    
    
    
    
    




