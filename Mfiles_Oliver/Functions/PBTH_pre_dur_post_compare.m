% %for some stimulation trials with bursts in them,
% extract those trials. Then plot PSTHs with allignemnt on the bursts
%that come during the stimulatiom, that come after the stimulation or that come before the stimulaton 
% But, to be able to compare PSTHs for bursts within stimulation, and for bursts before stimulation, do the following:
% Extract the burst_nr of bursts within stimulation, and then take the previous, (or next burst nr for post-)
%     as those bursts that happen before (or after) the stimulation..
%     Sort the burst times accordinf to the length of the burst, starting with the shortest.
%     Then calculate an 'artificial' trigger time (what would be sth. like an imaginary  stim position)
%     by adding the delay from the burst onset to the (real) stim time in the comparable case of the stimulated bursts.
%     Imagine stimulated burst in trial nr. 10 had its onset at 10 sec, the stim came at 10.1 sec, so the delay was 0.1 sec.
%     For the burst in the pre condition, I take the 10th longest burst, add 0.1 sec to its onset time and take this time as the trigger time for the PSTH 
%     of the pre condition. I do this for all cases, but excluding the extrema of very short and very long delays.
%     I.e. taking only 2/3 of the actual stimulated bursts (the middle-length bursts of pre and post case)

% 
% 
% input:
% 
% ls:                     the usual list with spike information
% 
% 
% burst_detection:        the cell array, for each channel one cell, where I store the burst information,as extracted from burst_detection_all_ch  
% 
% 
% CHANNEL_VEC:           An vector of Channels, for which this calculation
%                        should be done
% 
% 
% 
%Output:  
%so far none, only a figure that shows the result


function PBTH_pre_dur_post_compare(ls,burst_detection,CHANNEL_VEC);


nr_ch  = length(CHANNEL_VEC);
hw_ch  = cr2hw(CHANNEL_VEC);

%%%%%%%%%%%This should be the same as in the MAKE_PSTH calculation
PRE_TRIG_TIME       = 0.5;
POST_TRIG_TIME      = 1;

PSTH_BIN_WIDTH      = 0.01;

TRIAL_TIME_VEC      = -PRE_TRIG_TIME:PSTH_BIN_WIDTH:POST_TRIG_TIME-PSTH_BIN_WIDTH;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%first call the function find_burst_in_random_stim
%to get those stimulation trials that have bursts in them

    burst_dur_stim  =  find_burst_in_random_stim(ls,burst_detection,CHANNEL_VEC);
    
    
    for ii=1:nr_ch;
        
        %a=100;b=300;
        %rand_val = ceil(a + (b-a)*rand(length(burst_dur_stim{ii}),1))
        pre_trial_nr  = burst_dur_stim{ii}(:,3)-1;
        dur_trial_nr  = burst_dur_stim{ii}(:,3);
        post_trial_nr = burst_dur_stim{ii}(:,3)+1;
    
        for jj=1:length(burst_dur_stim{ii})
            if pre_trial_nr(jj) > 0 & post_trial_nr(jj)<length(burst_dur_stim{ii})
            pre_stim_burst_time{ii}(jj)    = burst_detection{1,hw_ch(ii)+1}{pre_trial_nr(jj),3}(1);
            pre_stim_burst_length{ii}(jj)  = burst_detection{1,hw_ch(ii)+1}{pre_trial_nr(jj),3}(end) - pre_stim_burst_time{ii}(jj);
            dur_stim_burst_time{ii}(jj)    = burst_detection{1,hw_ch(ii)+1}{dur_trial_nr(jj),3}(1);
            dur_stim_burst_length{ii}(jj)  = burst_dur_stim{ii}(jj,5) - burst_dur_stim{ii}(jj,4);
            post_stim_burst_time{ii}(jj)   = burst_detection{1,hw_ch(ii)+1}{post_trial_nr(jj),3}(1);
            post_stim_burst_length{ii}(jj) = burst_detection{1,hw_ch(ii)+1}{post_trial_nr(jj),3}(end) - post_stim_burst_time{ii}(jj);
            end
        end
        
        
        %sort the burst length of the bursts before and after
        [pre_stim_burst_length{ii} sort_ind]  = sort(pre_stim_burst_length{ii});
        pre_stim_burst_time{ii}               = pre_stim_burst_time{ii}(sort_ind);
        [post_stim_burst_length{ii} sort_ind] = sort(post_stim_burst_length{ii});
        post_stim_burst_time{ii}              = post_stim_burst_time{ii}(sort_ind);
        
        %the pre_stim_burst_time and post _stim_burst_time (absolute values) are now sorted
        %so that the times of the shortes bursts come first, then taking
        %the times with of increasing burst length
        
        %$ as a next step, I take as trigger times for the pre-burst the
        %burst times PLUS the artificially created relative stim time. This
        %relative stim time is the time between the burst onset in the dur-burst and the actual stim.
        %I.e. I do as if the bursts pre (and post) were 'stimulated'at a
        %comparable phase of their time course. Then I calculate PSTHs
        %alligned on those (artificial stim_times
        %Furthermore, take only the 'medium' burst lengths and with the corresponding trials, not the extrema of short and long bursts 
        indices = ceil(length(pre_stim_burst_time{ii})/6):5*ceil(length(pre_stim_burst_time{ii})/6);
        
        
        %now call the MAKE_PSTH function to plot a PSTH for each condition
        trig_times{ii}{1} = pre_stim_burst_time{ii}(indices) - burst_dur_stim{ii}(indices,6)';  %SINCE THE RELATIVE STIM TIMES ARE STORED AS NEG VALUES, I substract here to make it additive
        %trig_times{ii}{2} = dur_stim_burst_time{ii};
        trig_times{ii}{2} = dur_stim_burst_time{ii}(indices) - burst_dur_stim{ii}(indices,6)';  %set the allignment time to stim time
        trig_times{ii}{3} = post_stim_burst_time{ii}(indices) - burst_dur_stim{ii}(indices,6)' ;
        
        ch_vec    = CHANNEL_VEC(ii)*ones(1,3);
        cond_PSTH = MAKE_PSTH(ls,ch_vec,trig_times{ii},0);
        
        %cond_PSTH holds the PSTH information for all three conditions
        
%         %to fit an exponential data to it, first extract the relevant part
%         %i.e. only that part that can approx. be described as an
%         %exponential
%         
%         %the start index is the one after the middle index
%         %The end index is 2 secs later
%         start_ind = length(cond_PSTH)/2+1;
%         end_ind   = start_ind + 2/PSTH_BIN_WIDTH;
%         
         norm_fact = length(pre_trial_nr)*PSTH_BIN_WIDTH; %all conditions have equal length
%         pre_data  = cond_PSTH(1,start_ind:end_ind)/norm_fact;
%         dur_data  = cond_PSTH(2,start_ind:end_ind)/norm_fact;
%         post_data = cond_PSTH(3,start_ind:end_ind)/norm_fact;
%         
%         time_vec  = TRIAL_TIME_VEC(start_ind:end_ind);
%         
%         %now call the fit function
%         [pre_fit_param pre_fct_hdl]   = exp_datafit(time_vec,pre_data);
%         [dur_fit_param dur_fct_hdl]   = exp_datafit(time_vec,dur_data);
%         [post_fit_param post_fct_hdl] = exp_datafit(time_vec,post_data);
%         
%         %I now have the parameters for a fitted function of the form
%         %y=A*exp(-lambda.*x) for each of the datasets
%         %the fct_hdl are used to plot the fitted functions, given the
%         %parameters
%          [sqerr_pre  pre_data_fit]  = pre_fct_hdl(pre_fit_param);
%          [sqerr_dur  dur_data_fit]  = dur_fct_hdl(dur_fit_param);
%          [sqerr_post post_data_fit] = post_fct_hdl(post_fit_param);
         
         fit_pbth_fig=screen_size_fig();
         
         max_count = max(cond_PSTH,[],2);
         plot(TRIAL_TIME_VEC,cond_PSTH(1,:)/norm_fact/max_count(1),'b','Linewidth',0.5);
         hold on;
         plot(TRIAL_TIME_VEC,cond_PSTH(2,:)/norm_fact/max_count(2),'r','Linewidth',0.5);
         plot(TRIAL_TIME_VEC,cond_PSTH(3,:)/norm_fact/max_count(3),'g','Linewidth',0.5);
         
%          plot(time_vec,pre_data_fit,'b','Linewidth',2.5);
%          plot(time_vec,dur_data_fit,'r','Linewidth',2.5);
%          plot(time_vec,post_data_fit,'g','Linewidth',2.5);
        
         xlabel('time r.t. stimulation [sec]');
         ylabel('rate in trial [Hz]');
         title({['PBTH for three different types of bursts. For bursts before a stimulation trial'];['bursts in stimulation trials and for those afterwards'];...
             [num2str(length(pre_trial_nr)),' trials in total'];['channel: ', num2str(CHANNEL_VEC(ii))]});
         legend('pre','during','post');
        
        
    end
    
    
        

        
        