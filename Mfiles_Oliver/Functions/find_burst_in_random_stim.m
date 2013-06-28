%function find_burst_in_random_stim


%this function looks (in random stimulation experiments) for stimulation
%trials that are overlapping with a burst, i.e when the burst has already
%started before the stim. This can be done for a set of electrodes

%input:
%ls:                  usual structure with the spike data

%burst_detetction:    cell that holds the information about the detected
%                     bursts


%channel_vec;         this vector holds the channel nrs. (MEA) for which
%                     the analysis should be made



%%%%output:
%burst_dur_stim:      this is a cell, in each column it holds the information 
%                     for one channel about those stimulation trials that overlap 
%                     with a spontaneous burst. It stores the (sequential)
%                     nr. of such a case, the stimulation trial and the
%                     according burst nr on the respective channel 
%                                           



function [burst_dur_stim_sort ch_fig]=find_burst_in_random_stim(ls,burst_detection,channel_vec)

disp('busy...')

nr_ch           = length(channel_vec);
%define the hardware channel nrs
hw_ch           = cr2hw(channel_vec);

%find the stimulation times
stim_times      = ls.time(find(ls.channel==60));
nr_stim         = length(stim_times);


burst_end_times   = cell(nr_ch,1);
burst_start_times = cell(nr_ch,1);


%find the end time and start time of the bursts for each channels separatly and store them
%in burst_end_times
for ii=1:nr_ch
    
    act_ch            = hw_ch(ii)+1;
    %a counter
    burst_in_stim_det = 0;
    
    %initialize with 0s
    burst_end_times{ii,1}    = zeros(1,size(burst_detection{1,act_ch},1));
    burst_start_times{ii,1}  = zeros(1,size(burst_detection{1,act_ch},1));
    
    for jj=1:size(burst_detection{1,act_ch},1)
        burst_end_times{ii}(jj)   = burst_detection{1,act_ch}{jj,3}(end);
        burst_start_times{ii}(jj) = burst_detection{1,act_ch}{jj,3}(1);
    end
    
    %when this was done, cycle throught the stim times
    for kk=1:nr_stim
        %the burst should have started a certain time BEFORE the stim
        %already, i.e. not that there was e.g. just one spike before the
        %stimulation and and actual response (==high density of spikes) is
        %actually detected by the burst detection algorithm as a burst
        burst_id=find(burst_end_times{ii} >stim_times(kk) & burst_start_times{ii}+0.05 <stim_times(kk));
        if ~isempty(burst_id)
            %increment the counter
            burst_in_stim_det                       = burst_in_stim_det+1;
            burst_dur_stim{ii}(burst_in_stim_det,1) = burst_in_stim_det;
            burst_dur_stim{ii}(burst_in_stim_det,2) = kk;                      %this is the stimulation trial nr when the burst during stim occurs
            burst_dur_stim{ii}(burst_in_stim_det,3) = burst_id;                %this is the actual burst_nr
            burst_dur_stim{ii}(burst_in_stim_det,4) = burst_start_times{ii}(burst_id);  %the start time of the burst
            burst_dur_stim{ii}(burst_in_stim_det,5) = burst_end_times{ii}(burst_id);  %the end time of the burst
            burst_dur_stim{ii}(burst_in_stim_det,6) = burst_start_times{ii}(burst_id) - stim_times(kk);  %this is the relative time of the burst begin vs. the stimulation time
            burst_dur_stim{ii}(burst_in_stim_det,7) = burst_end_times{ii}(burst_id) - stim_times(kk);  %this is the relative time of the burst end vs. the stimulation 
        end
    end
      %[sort_start sort_ind]   = sort(burst_dur_stim{ii}(:,6),'descend');  %sort according to relative difference between burst onset and stim time
      %burst_dur_stim_sort{ii} = burst_dur_stim{ii}(sort_ind,:);
      %[sort_end sort_ind]      = sort(burst_dur_stim{ii}(:,7));  %sort according to relative difference between burst end and stim time
      %burst_dur_stim_sort{ii}  = burst_dur_stim{ii}(sort_ind,:);
      
      %don't sort:
      burst_dur_stim_sort = burst_dur_stim;
      
    
end




%%plot thise results for visualisation

X_EXTEND=5;

%comp_fig = figure;
for ii=1:nr_ch
 
    ch_fig(ii)=figure;
    %subplot(ceil(nr_ch/2), floor(nr_ch/2),ii)
    
    for jj=1:size(burst_dur_stim_sort{ii},1)
        stim_nr   = burst_dur_stim_sort{ii}(jj,2);
        stim_time = stim_times(stim_nr);
        burst_nr  = burst_dur_stim_sort{ii}(jj,3);
        
        ch_spikes       = ls.time(find(ls.time>stim_time-X_EXTEND & ls.time<stim_time+X_EXTEND & ls.channel==hw_ch(ii)));
        rel_spike_times = ch_spikes-stim_time;
        %rel_spike_times = ch_spikes - burst_dur_stim_sort{ii}(jj,4);
        plot(rel_spike_times,jj*ones(1,length(rel_spike_times)),'ok','markersize',2,'markerfacecolor','k');
        hold on;
        %plot(burst_detection{1,hw_ch(ii)+1}{burst_nr,3}(1)-stim_time,jj,'or', 'markersize',4,'markerfacecolor','r'); %mark the burst begin, relative to stim_time
        plot(burst_dur_stim_sort{ii}(jj,5)- stim_time,jj,'ob', 'markersize',4,'markerfacecolor','b')% mark the burst end, relative to stim_tim
        plot(0,jj,'or','markersize',4,'markerfacecolor','r')% mark the stim time red
        %plot(stim_time - burst_dur_stim_sort{ii}(jj,4),jj,'or','markersize',4,'markerfacecolor','r') % mark the stim time, relative to burst begin
        %plot(burst_dur_stim_sort{ii}(jj,5)- burst_dur_stim_sort{ii}(jj,4),jj,'ob', 'markersize',4,'markerfacecolor','b')% mrak the burst end, relative to burst begin
        
        
    end
    xlabel('time r.t. stimulus [sec]');
    ylabel('trial nr');
    title(['stimulation trials with bursts during stimulation, for channel: ', num2str(channel_vec(ii))]);
    xlim([-X_EXTEND X_EXTEND])
    ylim([0 jj]);
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

