%05/03/07
%Fir analysis of datasets with cyclical feedback stimulation, construct
%files that analyse rasterplots, PSTHs and other (e.g. corrleation between
%stim and recording electrode) during control, stimperiod and conrol again.
%Because the various stimperiods are appearing at specific times of the
%experiment, it should be possible to specify which stimperiod is
%considered. 


controlperiod_length =  10800;
stimperiod_length    =  3600;
no_stim_electrodes   = 7;
stimulus_el          = [31 52 44 25 72 57 17];
control_starttime    = [11 14422 28826 43230 57634 72038 86443 100843];  %the last entry is artificially created
stim_starttime       = control_starttime+controlperiod_length;

CONTROL_STIM_CONTROL_CYCLE = 1;
SELECT_CHANNELS_MEA        = [25];
RASTER_PSTH_PRE_PERIOD     = 5;
RASTER_PSTH_POST_PERIOD    = 5;
PSTH_BIN                   = 0.01;



select_channels = cr2hw(SELECT_CHANNELS_MEA);
no_sel_ch       = length(SELECT_CHANNELS_MEA);
csc             = CONTROL_STIM_CONTROL_CYCLE;
%b_ch needed in array burst_onset
b_ch=find(bursting_channels_mea==SELECT_CHANNELS_MEA);
%burst_ch is needed for array burst_detection
burst_ch=bursting_channels(b_ch);

%to account for same lengths of conrol and stim AT LEAST in the analysis
%(in the PSTHs) I shift the times of start and end periods
control_start_add=controlperiod_length-stimperiod_length
window_length=stimperiod_length
period_starts   = [control_starttime(csc)+control_start_add stim_starttime(csc) control_starttime(csc+1)]; 
period_ends     = [period_starts(1)+window_length period_starts(2)+window_length period_starts(3)+window_length];  %this rather difficult way of assigning times is due to changes control and stim length in various datasets 

% I have to cycle through the selected channels and the
% control-stim-control periods and do for each the respective calculation

for ii=1:no_sel_ch
    sel_ch=select_channels(ii);
    for jj=1:3  %because there are 3 periods that I'm looking at
        period_start  = period_starts(jj);
        period_end    = period_ends(jj);
        %period_start=period_end-60*20;
        %this hives th eindex in burst_onset for the burst (onsets) in the
        %respective period for the respective channel
        chburst_onset_period_index=find([burst_onset{1,b_ch}{:}]>period_start & [burst_onset{1,b_ch}{:}]<period_end);
        chburst_onset_period_times=[burst_onset{1,b_ch}{chburst_onset_period_index}];
        trigger_times = find(ls.channel==61 & ls.time>period_start & ls.time<period_end);
        trigger_times = ls.time(trigger_times);
        ch_spikes     = find(ls.channel==sel_ch & ls.time>period_start & ls.time<period_end);
        ch_spikes     = ls.time(ch_spikes);
        psth_all      = zeros(1,length(-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD));
        raster        = cell(length(trigger_times),1);
        
        
        nr_spikes_after_trig=zeros(1,length(trigger_times));
        nr_spikes_all_burst =zeros(1,length(trigger_times));
        burst_nr_intrigger  =[];
        for kk=1:length(trigger_times);
            prepost_spikes                       = find(ch_spikes > (trigger_times(kk)-RASTER_PSTH_PRE_PERIOD) & ch_spikes < (trigger_times(kk)+RASTER_PSTH_POST_PERIOD));
            prepost_spikes                       = ch_spikes(prepost_spikes);
            prepost_times                        = prepost_spikes-trigger_times(kk);
            %length(prepost_times)
            raster{kk}                           = prepost_times;
            psth_tr                              = hist(prepost_times,-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD);
            psth_all                             = psth_all+psth_tr;
            %now also look if there are bursts around the trigger, I have
            %already the burst onset times for the resp period, look around
            %the trigger times -0.2 sec, +0.2 sec if there is some onset
            burst_inside_trig_ind=find(chburst_onset_period_times>trigger_times(kk)-0.2 & chburst_onset_period_times<trigger_times(kk));
            if (~isempty(burst_inside_trig_ind))
                burst_nr            = chburst_onset_period_index(burst_inside_trig_ind);  %this is the index in burst_onset for the current burst that was found to be in an trigger
                burst_nr_intrigger(end+1)=burst_nr;
                nr_spikes_after_trig(kk) = length(find(burst_detection{1,burst_ch}{burst_nr,3}>trigger_times(kk)));
                nr_spikes_all_burst(kk)  = length(burst_detection{1,burst_ch}{burst_nr,3});
            end
        end
        
        raster_cycles{ii,jj}               = raster;
        psth_cycles{ii,jj}                 = psth_all;
        nr_spikes_after_trig_cycles{ii,jj} = nr_spikes_after_trig;
        nr_spikes_all_burst_cycles{ii,jj}  = nr_spikes_all_burst; 
    end
    psth_cycles{ii,2}(ceil(length(psth_cycles{ii,2})/2))=NaN;
end
            
      

for ii=1:no_sel_ch
    figure;
    for jj=1:3;
         hsub(jj)=subplot(3,3,jj);
        for kk=1:length(raster_cycles{ii,jj})
            plot(raster_cycles{ii,jj}{kk},kk*ones(1,length(raster_cycles{ii,jj}{kk})),'*k','MarkerSize',2);
            hold on;
        end
        title({['channel ', num2str(SELECT_CHANNELS_MEA(ii))];['control period ']});
        xlabel('time  r.t. trigger [sec]');
        ylabel('trial nr.' );
        ylim([0 length(raster_cycles{ii,jj})]);
        if jj==2
            title({['channel ', num2str(SELECT_CHANNELS_MEA(ii))];['stimulation period ', num2str(CONTROL_STIM_CONTROL_CYCLE)]});
            xlabel('time r.t. stimulus [sec]');
            ylabel('trial nr.' );
            ylim([0 length(raster_cycles{ii,jj})]);
        end
        
        hsub(jj+3) = subplot(3,3,jj+3);
        plot((-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD)+PSTH_BIN/2,psth_cycles{ii,jj});
        xlabel('time [sec]');
        ylabel('counts');
        ylim([0 max(max([psth_cycles{ii,:}]))]);
        xlim([-1 1]);
        
        
        
    end
    subplot(3,3,1)
    title({['datname:', num2str(datname)];['channel ', num2str(SELECT_CHANNELS_MEA(1))];['stimulation period ', num2str(CONTROL_STIM_CONTROL_CYCLE)]},'Interpreter','none');
end

  

%look if a stimulation at a particular electrode (i.e. for a particular
%cycle) gave a response at all. therefore define the cycle nr. and a set of electrodes whose psth should be plotted
 for CONTROL_STIM_CONTROL_CYCLE = 5;
SELECT_CHANNELS_MEA        = [84 ];
select_channels = cr2hw(SELECT_CHANNELS_MEA);
no_sel_ch       = length(SELECT_CHANNELS_MEA);
csc             = CONTROL_STIM_CONTROL_CYCLE;   

subplot_rows=round(no_sel_ch/2);
subplot_cols=ceil(no_sel_ch/subplot_rows);

psth_channels=cell(1,no_sel_ch);
selch_fig=figure;
for ii=1:no_sel_ch
    sel_ch=select_channels(ii);
 
        period_start  = stim_starttime(csc);
        period_end    = control_starttime(csc+1);
        trigger_times = find(ls.channel==61 & ls.time>period_start & ls.time<period_end);
        trigger_times = ls.time(trigger_times);
        ch_spikes     = find(ls.channel==sel_ch & ls.time>period_start & ls.time<period_end);
        ch_spikes     = ls.time(ch_spikes);
        psth_all      = zeros(1,length(-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD));
        for kk=1:length(trigger_times);
            prepost_spikes                       = find(ch_spikes > (trigger_times(kk)-RASTER_PSTH_PRE_PERIOD) & ch_spikes < (trigger_times(kk)+RASTER_PSTH_POST_PERIOD));
            prepost_spikes                       = ch_spikes(prepost_spikes);
            prepost_times                        = prepost_spikes-trigger_times(kk);
            %length(prepost_times)
            psth_tr                              = hist(prepost_times,-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD);
            psth_all                             = psth_all+psth_tr;
        end
        psth_channels{ii}   = psth_all;
        psth_channels{ii}(ceil(length(psth_channels{ii})/2))=NaN;
        hsub(ii)=subplot(subplot_rows,subplot_cols,ii);
        plot((-RASTER_PSTH_PRE_PERIOD:PSTH_BIN:RASTER_PSTH_POST_PERIOD)+PSTH_BIN/2,psth_channels{ii});
        xlim([-0.5 1])
        title(['channel: ',num2str(SELECT_CHANNELS_MEA(ii))]);  
        xlabel('time r.t. stimulus [sec]')
        ylabel('counts');
end
subplot(subplot_rows,subplot_cols,1);
title({['datname: ',num2str(datname)]; ['PSTH for various channels, during stimulation period ',num2str(csc),' (at el. ',num2str(stimulus_el(csc)),'), PSTH bin width = ', num2str(PSTH_BIN),' sec'];['channel: ',num2str(SELECT_CHANNELS_MEA(1))]},'Interpreter', 'none');
            
 end



