%plot all spike cutouts around some trigger time
%function all_ind=spikecutout_around_trig(ls,CHANNEL_VEC,trig_times,time_window_on, time_window_off)
% 
% 
% 
% 
% 
% 
%
%
%
%
%
%
%
%function all_ind=spikecutout_around_trig(ls,CHANNEL_VEC,trig_times,time_window_on, time_window_off)


function all_ind=spikecutout_around_trig(ls,CHANNEL_VEC,trig_times,time_window_on, time_window_off)


x_vec       = (-2+0.04):0.04:(3-0.04);

nr_ch = length(CHANNEL_VEC);
hw_ch = cr2hw(CHANNEL_VEC);




for ii=1:nr_ch
    cutout_fig = screen_size_fig();
    nr_trig    = length(trig_times);
    all_ind    = [];
    
    for jj=1:nr_trig
        
        
        if time_window_on >= 0
            spike_ind     = find(ls.time>trig_times(jj) & ls.time<trig_times(jj)+time_window_off & ls.time>trig_times(jj)+time_window_on & ls.channel==hw_ch(ii));
        else
            spike_ind     = find(ls.time<trig_times(jj) & ls.time>trig_times(jj)+time_window_on & ls.time<trig_times(jj)+time_window_off & ls.channel==hw_ch(ii));
        end
        
        all_ind = [all_ind spike_ind];
    end

    nr_cutouts  = length(all_ind);

    %%first of all find the context minus the mean offset,
    %the mean offset should be calculated in a period at the beginning of
    %the recorded trace, e.g. 1.5 msec or 37 samplesteps
    
    all_pos_spikes = [];
    all_neg_spikes = [];
    
    for jj=1:nr_cutouts
         mean_offset(jj) = mean(ls.context(1:37,all_ind(jj)),1);
         if ls.context(50,all_ind(jj)) - mean_offset(jj) >=0 
             all_pos_spikes = [all_pos_spikes all_ind(jj)];
             %define a 1 for positive spikes
             spike_sign(jj) =1;
         else
             all_neg_spikes = [all_neg_spikes all_ind(jj)];
              %define a -1 for neg. spikes
             spike_sign(jj) = -1;
         end
    end
    
    
    %all_pos_spikes = all_ind(find(ls.context(50,all_ind)>0));
    %all_neg_spikes = all_ind(find(ls.context(50,all_ind)<0));
    
    if ~isempty(all_pos_spikes)
        mean_cutout_pos   = mean(ls.context(:,all_pos_spikes),2);
        %subtract the mean offset from all the pos spikes
        mean_cutout_pos   = mean_cutout_pos - mean(mean_offset(find(spike_sign==1)));
    end
    if ~isempty(all_neg_spikes)
        mean_cutout_neg   = mean(ls.context(:,all_neg_spikes),2);
        mean_cutout_neg   = mean_cutout_neg - mean(mean_offset(find(spike_sign==-1)));
    end
    
    
    subplot(2,1,2)
    for kk=1:nr_cutouts;
        %mean_offset(kk) = mean(ls.context(1:37,all_ind(kk)),1);
        plot(x_vec,ls.context(:,all_ind(kk))-mean_offset(kk),'--','Color',[.8 .8 .8]);
        %plot(x_vec,ls.context(:,all_ind(kk)),'--','Color',[.8 .8 .8]);
        hold on;
    end
    
    %plot the mean cutout
    if ~isempty(all_pos_spikes)
        plot(x_vec,mean_cutout_pos,'g', 'LineWidth', 2);
    end
    if ~isempty(all_neg_spikes)
        plot(x_vec,mean_cutout_neg,'r', 'LineWidth', 2);
    end
    
    title({[num2str(nr_cutouts),' spike cutouts from channel ',num2str(CHANNEL_VEC(ii)),' in a period between ', num2str(time_window_on),' and ', num2str(time_window_off),' sec after a given trigger plotted in gray'];...
           [ num2str(length(all_pos_spikes)),' pos. spikes and ', num2str(length(all_neg_spikes)),' neg. spikes']; ['mean cutout shape plotted in green (pos) and red (neg)']});
    xlabel('time [msec]');
end
    
    
    