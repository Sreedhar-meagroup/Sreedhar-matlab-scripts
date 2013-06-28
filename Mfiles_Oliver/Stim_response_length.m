%determine the length of the response to the stimulation. After the
%stimulation, the response usually consists of multiple spikes with short
%ISIs. If the first ISI is larger than a settable value (e.g.100-150 ms)
%then the reponse is considered as finished


channel_mea=[53];

%day specifications
day=1;
first_trial=(day-1)*180+1;
last_trial=day*180-1;
trial_vec=first_trial:last_trial;
total_trials=last_trial-first_trial+1;

%find the trigger information
stim_trigger=find(ls.channel==61);  %not a Schmitt-trigger
stim_times=ls.time(stim_trigger);   

%channel specifications
channel_hw=cr2hw(channel_mea);

%time periods where to look for responses
UNITLENGTH=25; %i.e. 25 samples are one ms
PRESTIMULI=0; 
POSTSTIMULI=5;
MAX_RESP_INT=0.150;   %criterion for the maximal interval that can occurr and still belong to the reponse



%initialize data vector
responses=cell(length(channel_mea),total_trials);
    
for ch_ind=1:length(channel_hw);
    channel=channel_hw(ch_ind);
    channel_spikes=find(ls.channel==channel);
    channel_spike_times=ls.time(channel_spikes);

    for i=1:total_trials
        trial_no=trial_vec(i);
        resp=find(channel_spike_times > (stim_times(trial_no)-PRESTIMULI) & channel_spike_times < (stim_times(trial_no)+POSTSTIMULI) );
        resp=channel_spike_times(resp);
        responses{ch_ind,i}=resp;
    end;
 %now there are timestamps in the cell response_length, for all the spikes
 %in a window POSTSTIMULI after stimulation. however, we are only
 %interested in the direct response. so set a criterion (see above) for the
 %end of the response.
 
 
    for i=1:total_trials;
        trial_no=trial_vec(i);

         if  ~isempty(responses{ch_ind,i})                                           %checks if there is a response at all
             trial_response=responses{ch_ind,i};
             if trial_response(1)-stim_times(trial_no) < 0.20                   %if the response comes within that time window
                 for j=1:(length(trial_response)-1)                             %make the check for the ISIs

                     if (trial_response(j+1) - trial_response(j)) > MAX_RESP_INT
                         trial_response((j+1):end)=[];                          %empty the rest
                         break
                     end
                 end
                 response_length{ch_ind,i} = (trial_response(end) - stim_times(trial_no));
             else
                response_length{ch_ind,i} = 0;                                        %assign 0 in the case the response did not came in a period 0.2 sec after the stim (i.e. say there is no response)
             end
         else
           response_length{ch_ind,i} = NaN;
         end;
    end;

    response_matrix{ch_ind}(:,1)=[response_length{ch_ind,:}]';
    response_matrix{ch_ind}(:,2)=trial_vec(1:end)';    % this is done to better sort the data later

    %the matrix is sorted to have ascending response length and the respective
    %trial no in the column 2
    [response_sorted{ch_ind} indices] = sort(response_matrix{ch_ind},1,'ascend');
    response_sorted{ch_ind}(:,2)=indices(:,1);
end






 
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
    
     
     
     
     
     
     
 





























