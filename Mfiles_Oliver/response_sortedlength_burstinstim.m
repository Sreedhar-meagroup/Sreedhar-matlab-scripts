%for the dataset 24_11_06_331stim, 
%sort the response trials according to some criterions
%e.g. trials with burst in between the stim_time, very short responses
%or the long responses
%this can reveal some structure in the response length, i.e. what
%determines a response length
%there are indications that bursting 

channel_mea=[53];

%day specifications
day=1;
first_trial=(day-1)*180+1;
last_trial=day*180-1;
trial_vec=first_trial:last_trial;
total_trials=last_trial-first_trial+1;

%channel specifications
channel_hw=cr2hw(channel_mea);
channelcount=length(channel_mea);

%figure specifications
subplotsizecolumn=ceil(channelcount);
subplotsizerow=ceil(channelcount/subplotsizecolumn);
selectedfig=figure;

%look trough burst_detection, which here holds the burst during trials and
%find those trials which have a burst at stim_time
%find it by looking at the last spikes in the last burst in the respective
%trial and see if this spike is considerably close to the stim_time

MAX_BURSTEND_STIM_DISTANCE=0.15;                                           %this defines the max interval possible between a last spike in a burst and the start of the stim, to count as an overlap between stim & burts

%initialize data vectors
  bursting_response         = cell(length(channel_mea));
  extract_noburst           = cell(length(channel_mea));
  response_lengthsort_burst = cell(length(channel_mea));
  
for ch_ind=1:length(channel_hw);
    channel=channel_hw(ch_ind);
    
    for i = 1:length(burst_detection);
        if ~isempty(burst_detection{ch_ind,i})
            if burst_detection{ch_ind,i}{end,3}(end)+MAX_BURSTEND_STIM_DISTANCE > stim_times(i)
                bursting_response{ch_ind}(i,1) = 1;
                bursting_response{ch_ind}(i,2) = i;                                        %these values give a boolena value (1) if the case is fulfilled and the respective trial no
            else
                bursting_response{ch_ind}(i,1) = 0;
                bursting_response{ch_ind}(i,2) = i;
            end
        else
                bursting_response{ch_ind}(i,1) = 0;
                bursting_response{ch_ind}(i,2) = i;
        end
    end

    %sort the vector bursting_response accordingly
    [bursting_response{ch_ind} b_resp_ind] = sort(bursting_response{ch_ind},1,'ascend');
    bursting_response{ch_ind}(:,2) = bursting_response{ch_ind}(b_resp_ind(:,1),2);
    
    
    indices             = find(bursting_response{ch_ind}(:,1)==0);
    indices_burstinstim = find(bursting_response{ch_ind}(:,1)==1);
    noburst_trials      = bursting_response{ch_ind}(indices,2);
    
   %to make it a little bit more complicated, sort the trials that have a
   %burst during stimulation w.r. to the onset of this burst, strting
   %with the most recent one (w.r. to stim time)
   
    bursting_trials=bursting_response{ch_ind}(indices_burstinstim,2);
    burst_instim_sort=zeros(length(bursting_trials),2);
    burst_instim_sort(:,1)= bursting_trials;
    for k = 1: length(bursting_trials)
        active_trial=bursting_trials(k);
        burst_start_rel_to_stim = burst_detection{ch_ind,active_trial}{end,3}(1) - stim_times(active_trial)       %this gives me the timedifference between the burst on set and the stimtimes, note that this are negative values
                                                                                                                   %later, I sort for these values
        burst_instim_sort(k,2)= burst_start_rel_to_stim
    end
   
    [burst_instim_resort ind] = sort(burst_instim_sort,1,'descend')
    burst_instim_resort(:,1) = burst_instim_sort(ind(:,2),1)
    burst_instim_sort = burst_instim_resort;                                            %trila are hereby sorted according to the time when the burst started (rel. to stimulus)
    
          
    
     %also sort the trials which are not disturbed by a burst during stimulation
    %according to their response length
    for i = 1:length(noburst_trials)
    noburst_ind = find(response_sorted{ch_ind}(:,2)==noburst_trials(i));
    extract_noburst{ch_ind}(i,1) = response_sorted{ch_ind}(noburst_ind,1);
    extract_noburst{ch_ind}(i,2) = response_sorted{ch_ind}(noburst_ind,2);
    end
    %extract_noburst has the response length inthe first column, the resp.
    %trail no in the second column, all for trials which have no burts during
    %stimulation
    %now sort this vector 
    [extract_noburst{ch_ind} e_nb_ind] = sort(extract_noburst{ch_ind},1,'ascend');
    extract_noburst{ch_ind}(:,2)       = extract_noburst{ch_ind}(e_nb_ind(:,1),2); 

    %the vector response_lengthsort_burst holds the trial numbers in the order
    %they should be plotted, i.e starting with increasing response length and
    %then all the bursting responses
    %response_lengthsort_burst{ch_ind} = cat(1,extract_noburst{ch_ind}(:,2),bursting_response{ch_ind}(indices_burstinstim,2));
    response_lengthsort_burst{ch_ind} = cat(1,extract_noburst{ch_ind}(:,2),burst_instim_sort(:,1));



    %plot the result

        selectedhsub(ch_ind)=subplot(subplotsizecolumn, subplotsizerow,ch_ind);% a figure handle for every subplot
         for j = 1:length([response_lengthsort_burst{ch_ind}])
             active_trial=response_lengthsort_burst{ch_ind}(j);
    plot(stimulusraster(channel_hw(ch_ind)+1,1:noofspikes(channel_hw(ch_ind)+1,active_trial),active_trial),j*ones(noofspikes(channel_hw(ch_ind)+1,active_trial),1),'*k','MarkerSize',2);
    hold on;
        end;
        title(['channel ', num2str(hw2cr(channel_hw(ch_ind)))], 'FontSize',14)
        xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
        ylabel('trials sorted for response characteristic', 'Fontsize',14); 
        
       selectedchil=get(selectedfig,'Children');
       set(selectedchil(:),'FontSize',24);
       set(selectedchil(:),'FontWeight','Normal');
    set(selectedchil(:),'YLim',[0 length([bursting_response{ch_ind}])]); % manuell
    set(selectedchil(:),'YTick',[],'YTickLabel',[]);
    set(selectedchil(:),'XLim',[-PRESTIM_BURSTWINDOW POSTSTIMULI]); 
    set(selectedchil(:),'FontSize',12);
end                                                                        %end the channel for loop
subplot(subplotsizecolumn,subplotsizerow,1);
title({['dataset: ',num2str(datname)];['trials sorted for response length (lower part) and trials with bursts during stimulation'];...
                             ['channel ', num2str(hw2cr(channel_hw(1)))]},'Fontsize',14,'Interpreter','none');
























    