%burst analysis for the dataset 010906_229stim.spike
%observed different response properties depending on the previous activity
%in the network. period of increased bursting seem to have an effect on the
%stimulation response. if there was a sufficient amount of bursts, the
%response (length, spike count) is drastically shortened)

%look for periods of bursting (at least one,two,... burst in each 20sec
 %window and this for at least 2,3,... of these windows
%THIS FILE IS AN ADDITION TO THE ANALYSIS IN Stim_Response_Length.m 
 
 
 burst_windows=2;
 
for i=3:length(burst_detection)
    trial_no=trial_vec(i);
     for j=1:burst_windows
         if ~isempty(burst_detection{1,i-(j-1)})
             burst_in_trial(j)=burst_detection{1,i-(j-1)}{end,1};
             burst_sorted(i,1)=trial_no
         else
             burst_in_trial(j)=0;
             burst_sorted(i,1)=trial_no
         end
     end
    if sum(burst_in_trial > 0)==burst_windows 
      
        burst_sorted(i,2)=1;
    else
        burst_sorted(i,2)=0;
    end;
    clear burst_in_trial
end;
 


%in some way manual choice of the trials to plot is necessary, put in the
%trials HERE:
%I plot the periods of increased bursting and one trial after that in a
%subplot, having several subplots on one figure, each for one period of
%bursting

plot_cycles=cell(1,100);
cycle=1;
plot_trials=[];
sort_vector=find(burst_sorted(:,2)==1);
period_start=trial_vec(sort_vector(1))-2;
for i=1:length(sort_vector)-1
    if (sort_vector(i) - sort_vector(i+1)) < -1
        plot_cycles{1,cycle}=[period_start:trial_vec(sort_vector(i))+1];
        cycle=cycle+1;
        period_start=trial_vec(sort_vector(i+1))-2;   %the next index whic as a larger gap than one is also the start of the next burst period
    end;
end;

%plot_cycles has all the trials that belong to a period of bursting plus
%the one trial after the end of that period. each column in the cell stands
%for one such a period, now plottting should be possible
%the last entry might miss.
plot_cycles{1,cycle}=[period_start:sort_vector(end)+1];




sub_nr=6;
no_figures=ceil(cycle/sub_nr);  % if I want to have 6 subplots on one figure
for fig=1:no_figures
    sub_fig(fig)=figure
    for subax=1:sub_nr;
    hsub(fig,subax)=subplot(sub_nr,1,subax)
    cycle_no=subax+sub_nr*(fig-1)
    for trial=1:length(plot_cycles{1,cycle_no}) 
        which_trial=plot_cycles{1,cycle_no}(trial);
        plot(stimulusraster(selectedchannels(1)+1,1:noofspikes(selectedchannels(1)+1,which_trial),which_trial),trial*ones(noofspikes(selectedchannels(1)+1,which_trial),1),'*k','MarkerSize',2);
        hold on;
    end;
    set(hsub(fig,subax), 'YTick',[ceil(length(plot_cycles{1,cycle_no})/2)],'YTickLabel',[ which_trial])
    ylabel(hsub(fig,subax),'trial no.', 'FontSize',14);
    end
    xlabel(hsub(fig,sub_nr),'time r.t. stimulus [ms] ', 'Fontsize',14)
    
    title(hsub(fig,1),{['dataset: ', num2str(datname)];['response on channel ',num2str(channel_mea)]},'FontSize',14,'Interpreter','none');
end

hsub_label=get(sub_fig(:), 'Children');
for i=1:no_figures
    set(hsub_label{1,1}(sub_nr),'xlabel','time r.t. stimulus [ms] ','Fontsize' 14);
    set(hsub_label{1,:}(1),'title', {['dataset: ', num2str(datname)];['response on channel ',num2str(channel_mea)]})
    set(hsub_label(i,:),'ylabel', 'trial no. ');
end





