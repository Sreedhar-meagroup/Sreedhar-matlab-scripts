% A function that calculates and sort stimulation trials with burst during
% stimulation
%according to activity prior to stimulation



% %input:
%ls:                        the usual list with spike information
% 
% 
% 
% burst_dur_stim:           cell that holds, for each channel, information
%                           about stim trials that have a burst in it
% 
% 
% 
%CHANNEL_VEC:               stores the different (MEA) channels 
% 
% 
% activity_window:          length of the window prior to stimulation where
%                            activity should be measured





function [burst_dur_stim_sort]=sort_stim_trials_activity(ls, burst_dur_stim, CHANNEL_VEC, activity_window)

stim_times      = ls.time(find(ls.channel==60));

nr_ch = length(CHANNEL_VEC);
hw_ch = cr2hw(CHANNEL_VEC);

for ii=1:nr_ch
    
    nr_trials    = length(burst_dur_stim{ii});
    avg_activity = zeros(1,nr_trials);
    for jj=1:nr_trials
        
        burst_start  = burst_dur_stim{ii}(jj,4);
        
        prior_spikes = ls.time(find(ls.channel==hw_ch(ii) & ls.time <burst_start & ls.time>burst_start-activity_window));
        nr_spikes    = length(prior_spikes);
        
        if (nr_spikes > 0)
            avg_activity(jj) = nr_spikes/activity_window;   %just a gross measure about activity, i.e rate in Hz
        end %the zeros case is treated already during initializing
    end
    
    [sort_activity sort_ind] =sort(avg_activity)
    burst_dur_stim_sort{ii} = burst_dur_stim{ii}(sort_ind,:);
end







X_EXTEND=9;

%comp_fig = figure;
for ii=1:nr_ch
 
    ch_fig(ii)=figure;
    %subplot(ceil(nr_ch/2), floor(nr_ch/2),ii)
    
    for jj=1:size(burst_dur_stim_sort{ii},1)
        stim_nr      = burst_dur_stim_sort{ii}(jj,2);
        stim_time    = stim_times(stim_nr);
        burst_start  = burst_dur_stim_sort{ii}(jj,4);
        burst_end    = burst_dur_stim_sort{ii}(jj,5);
        
        
        ch_spikes       = ls.time(find(ls.time>stim_time-X_EXTEND & ls.time<stim_time+X_EXTEND & ls.channel==hw_ch(ii)));
        rel_spike_times = ch_spikes-stim_time;
        plot(rel_spike_times,jj*ones(1,length(rel_spike_times)),'ok','markersize',2,'markerfacecolor','k');
        hold on;
        plot(burst_start-stim_time,jj,'or', 'markersize',4,'markerfacecolor','r');
        plot(burst_end-stim_time,jj,'or', 'markersize',4,'markerfacecolor','b')% plot the burst end in blue
    end
    xlabel('time r.t. stimulus [sec]');
    ylabel('trial nr');
    title({['stimulation trials with bursts during stimulation, sorted for avg. activity prior to stimulation'];...
          ['channel: ', num2str(CHANNEL_VEC(ii))]});
end
    













