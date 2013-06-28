%function Stim_response_length_sort
% 
%This function should extract the stim responses and calcultae  the response length, 
% then sort the stim trials according to response length and plot it in this
% way 
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
function [Response_raster noofspikes] = Stim_response_length_sort(datname,ls,burst_detection,CHANNELS,Stim_start,Stim_end)

nr_ch = length(CHANNELS);
hw_ch = cr2hw(CHANNELS);

Stim_times  = ls.time(find(ls.time>=Stim_start*3600 & ls.time<Stim_end*3600 & ls.channel==61));
Stim_trials = length(Stim_times); 

Response_window  = 0.25;
Max_response_ISI = 0.1;

%initialize the cells
Response_length = cell(nr_ch,1);
Response_spikes = cell(nr_ch,1);
Response_length_sort = cell(nr_ch,1)

for ii=1:nr_ch
    
    %initialize the nested cells
    Response_length{ii} = cell(Stim_trials,3);
    Response_spikes{ii} = cell(Stim_trials,2);
    
    Responding_trial     = [];
    Non_responding_trial = [];
    
    
    %extract all the spike in bursts first, to  later check if a stim comes
    %in a burst
    burst_spikes = [burst_detection{1,hw_ch(ii)+1}{:,3}];
    burst_during_stim_trial{ii} = [];
    for jj=1:Stim_trials
        
        %if the current Stim trial is during a burst or not
       
        if find(burst_spikes - Stim_times(jj) > -0.2 & burst_spikes-Stim_times(jj) <0)
            burst_during_stim_trial{ii} = [burst_during_stim_trial{ii},jj];
        else

                 %if there are any spikes at all after the stim in the
                 %Response_window period
            if  find(ls.time>Stim_times(jj) & ls.time<Stim_times(jj)+Response_window & ls.channel==hw_ch(ii))

                %define a maximum window where for a response is looked for (e.g.
                %2 sec) and calculate the resp. times rel. to the stim time
                ch_response  = ls.time(find(ls.time>Stim_times(jj) & ls.time<Stim_times(jj)+2 & ls.channel==hw_ch(ii))) ;%- Stim_times(jj);

                %this gives the spike times in the response and the trial nr
                Response_spikes{ii}{jj,1} = ch_response;
                Response_spikes{ii}{jj,2} = jj*ones(1,length(ch_response));
                Responding_trial         = [Responding_trial,jj];
            else
                Response_spikes{ii}{jj,1} = [];
                Response_spikes{ii}{jj,2} = [];
                Non_responding_trial      = [Non_responding_trial,jj];
            end
            
        end 
            
            
    end
        Responses.time    = [Response_spikes{ii}{:,1}];
        Responses.channel = hw_ch(ii)*ones(1,length([Response_spikes{ii}{:,1}]));
        Responses.trial   = [Response_spikes{ii}{:,2}];
        
        
        Response_burst_detection = Response_burst_detection_single_ch(Responses,hw_ch(ii));
        Burst_response_trials    = [];
        for kk =1:size(Response_burst_detection,1)
           Burst_response_trials = [Burst_response_trials,Response_burst_detection{kk,4}(1)];    
        end
        
        %Find those trials that have two (or more) burst in a row, i.e.
        %those trials that have multile entries in Burst_respons_trials
        multiple_burst_trials                            = find(diff(Burst_response_trials)==0);
        Burst_response_trials(multiple_burst_trials+1)   = [];
        %delete it also from the detected Burst responses
        Response_burst_detection(multiple_burst_trials+1,:)= [];

   
        
        
        Response_length_sort{ii} = cell(Stim_trials,3)       
        %again, cycle through the stim trials, now assign th eresponse
        %length etc
        for jj = 1:Stim_trials
            
            if ismember(jj,Responding_trial)
                if ismember(jj,Burst_response_trials)
                    Response_length{ii}{jj,1} = Response_burst_detection{find(Burst_response_trials==jj),3}(end) - Stim_times(jj);
                    Response_length{ii}{jj,2} = jj;
                    Response_length{ii}{jj,3}  = 'Br';
                else
                    Response_length{ii}{jj,1} = Response_spikes{ii}{jj,1}(end) - Stim_times(jj);
                    Response_length{ii}{jj,2} = jj;
                    Response_length{ii}{jj,3}  = 'R';
                end
            else
                
                if ismember(jj,burst_during_stim_trial{ii})
                    
                    Response_length{ii}{jj,1} = [];
                    Response_length{ii}{jj,2} = jj;
                    Response_length{ii}{jj,3} = 'BdurR';
                    
                else

                    Response_length{ii}{jj,1} = 0;
                    Response_length{ii}{jj,2} = jj;
                    Response_length{ii}{jj,3} = 'Nr';
                end
            end
        end
        
        
        %sort only on those trials that don't have a burst during stim
        sorting_trials = setdiff(1:Stim_trials,burst_during_stim_trial{ii})
%sort the responses according to length
   [sorted_length sort_ind] = sort([Response_length{ii}{sorting_trials,1}]);
   %because I ahve a string here, I again have to make a loop
%   and becuase I use not all indices from Response_length, I adjust the indices
       sort_ind = sorting_trials(sort_ind);
      for jj = 1:length(sort_ind)
       
           Response_length_sort{ii}{jj,1}             = Response_length{ii}{sort_ind(jj),1};
           Response_length_sort{ii}{jj,2}             = Response_length{ii}{sort_ind(jj),2};
           Response_length_sort{ii}{jj,3}             = Response_length{ii}{sort_ind(jj),3};
       end
       
       for jj = 1:length(burst_during_stim_trial{ii})
           nr_seq_trial = length(sort_ind)+jj;
           Response_length_sort{ii}{nr_seq_trial,1}             = [];
           Response_length_sort{ii}{nr_seq_trial,2}             = Response_length{ii}{burst_during_stim_trial{ii}(jj),2};
           Response_length_sort{ii}{nr_seq_trial,3}             = Response_length{ii}{burst_during_stim_trial{ii}(jj),3};
       end
end
   


%The Response_length_sort stores the stim trials, sorted according to the
%length of the leicited responses, with the feature of the response
%'type'. The sorting criterion can always be modified





PRE_STIM_TIME       = 5;
POST_STIM_TIME      = 5;


Response_raster     = cell(nr_ch,1);

for ii=1:nr_ch
    
    %Response_raster{ii}     = cell(Stim_trials,1); 
    
    active_ch = hw_ch(ii);
    TRIALS    = length(Stim_times);
  
    %extract the spikes from the current channel
    chtimestamps =  ls.time(find(ls.channel==active_ch & ls.time>Stim_start*3600-PRE_STIM_TIME & ls.time <Stim_end*3600+POST_STIM_TIME));
    
   
    for jj = 1:TRIALS  %i.e for every trial
        active_trial              =  Response_length_sort{ii}{jj,2};
        prepostwindow             =  find((chtimestamps > (Stim_times(active_trial) - PRE_STIM_TIME)) & (chtimestamps < (Stim_times(active_trial)+POST_STIM_TIME)));
        chtimes                   =  chtimestamps(prepostwindow);
        noofspikes(ii,jj)            = length(chtimes);
        relativetimes             = chtimes-Stim_times(active_trial);
        
        Response_raster{ii}(jj,1:noofspikes(ii,jj)) = relativetimes(1:end);
    end;
  
end;


%plotting outside the big loop makes the zooming in and out faster...

Response_raster_fig = screen_size_fig();
%Go over and plot the results
nr_subplot_row      = ceil(sqrt(nr_ch));     
nr_subplot_col      = ceil(nr_ch/nr_subplot_row);

for ii=1:nr_ch
     hsub(ii) = subplot(nr_subplot_row,nr_subplot_col,ii);
    for jj=1:length(noofspikes(ii,:))
        plot(Response_raster{ii}(jj,1:noofspikes(ii,jj)),jj*ones(1,noofspikes(ii,jj)),'*k','Markersize',2)
        hold on
    end
    xlabel('time r.t. stimulus [sec]');
    ylabel('trial nr. (sorted)');
     title({['datname ',num2str(datname)]; ['Channel: ', num2str(CHANNELS(ii))];...
         ['Hr. ',num2str(Stim_start),' to ', num2str(Stim_end),' of recording']},'FontSize',12,'Interpreter', 'none');
end


disp('hallo');
            


