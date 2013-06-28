%write a function solely for the purpose to show stim rasters in it's raw
%shape and sorted according to the length of the elicited response.
%[Response_burst Prestim_burst] =  Stim_modul_spont_act(datname,ls,CHANNELS,stim_raster,nr_spikes, stim_times)
%
%
%
% INPUT:
% 
% datname;                name of the dataset
% 
% ls:                     structure with spike information
% 
% CHANNELS:                CHANNELS to include in analysis, bursting channels
% 
% 
% stim_ratser nr_spikes   Return values from StimulusEffect
%                         stim_raster stores the spike times pre and post
%                         stimulus for each stimulation trial, for each
%                         channel. It is a 1^60 cell array
%                         nr_spikes simply stores the nr of elicited spikes in the response, for each channel, for each trial                  
% 
% stim_times              stimulation times, should be the same  as used
%                          for StimuusEffect calculation
% 
% varargin:                 A couple of arguments to determine parameters
% for the burst detection in the response and prestimulus spikes.
%Loading those parameters wotks with the fct pvpmod,, which automatically assigns parameter /value pairs which are stored in the input cell array
%                           varargin{1} = RESPONSE_MAX_INT;
%                           varargin{2} = RESPONSE_MAX_BURST_INT;
%                           varargin{3} = RESPONSE_MIN_NO_SPIKES;
%                           varargin{4} = PRESTIM_MAX_INT;
%                           varargin{5] = PRESTIM_MAX_BURST_INT;
%                           varargin{6} = PRESTIM_MIN_NO_SPIKES;
%
% 
% 
% OUTPUT:                
%Response burst           A cell array, one cell for each channel. stores
%                         the responses, detected as bursts, in an ordered amnner. It stores also
%                         the corresponding stimulation trial, and the actual response length,
%                         claculated from stim start to burst end
% 
% 
%Prestim_burst            Stores the bursts that were detected inthe
%                         periods BEFORE the stimulation. Depending on how I choose my pre
%                         time wondow in StimulusEffect, I can have more or less bursts detected as
%                         being before stimulation trials. therefore, it might be advisable to
%                         choose the prewindow large, If I want to concentrate on the things that
%                         happened before the stimulation
%
% Response_stat           Some statistics of the reponse length distribution. It saves the std, mean and CV of each response length distribution     

%
function [Response_burst Prestim_burst Response_stat]= Stim_modul_spont_act(datname,ls,CHANNELS,stim_raster,nr_spikes, stim_times,varargin)

 %assigne the standard values of the parameters first, overwrite them
 %later if according input is given. 
 RESPONSE_MAX_INT       = 0.1;
 RESPONSE_MAX_BURST_INT = 0.2;
 RESPONSE_MIN_NO_SPIKES = 3;
 PRESTIM_MAX_INT        = 0.15;
 PRESTIM_MAX_BURST_INT  = 0.3;
 PRESTIM_MIN_NO_SPIKES  = 3;
 LONG_TERM_COMPONENT    = 0.025;  %defining the start of the long term component
 RESPONSE_MAX_ONSET     = 1;     %this defines the maximal window post stimulus where for a spike is searched that can belong to a response
 PRE_STIM_PERIOD        = 15;
 POST_STIM_PERIOD       = 5;
 PLOT_OUTPUT            = 1; %true if plot desired  


%determining the input 
if nargin>6
    pvpmod(varargin{1}); %this assigns the parameter value pairs
end
   
    
nr_channels = length(CHANNELS);
hw_channels = cr2hw(CHANNELS)
%run the StimulusEffect fct
%[stim_raster nr_spikes] = StimulusEffect(datname,ls,61,0,0,PRE_time,POST_time,stim_times);
%close(gcf);
TRIALS        = length(nr_spikes);

Nr_ch_per_fig = 2;
Nr_fig        = ceil(nr_channels/Nr_ch_per_fig);
new_fig_ch    = 1:Nr_ch_per_fig:nr_channels;
nr_figs       = 0;

for ii=1:nr_channels
    %check if plots are desired or not
    if PLOT_OUTPUT==0
        break
    end
   if intersect(new_fig_ch,ii)
       nr_figs = nr_figs+1
       stim_raster_ch_fig(nr_figs)       = screen_size_fig;
       [plot_pos subplot_r subplot_c]    = get_subplot_position(Nr_ch_per_fig*2);
   end
   selectedhsub((ii-1)*2+1)              = subplot(subplot_r,subplot_c,plot_pos((ii-1)*2+1-(nr_figs-1)*Nr_ch_per_fig*2)); 
    
     for trial=1:TRIALS
         plot(stim_raster(hw_channels(ii)+1,1:nr_spikes(hw_channels(ii)+1,trial),trial),trial*ones(nr_spikes(hw_channels(ii)+1,trial),1),'ok','MarkerSize',2,'Markerfacecolor', 'k');
         hold on;
     end;
    title(['channel ', num2str(CHANNELS(ii))], 'FontSize',14)
    xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
    ylabel('Trial Nr', 'FontSize', 14)
    ylim([0 TRIALS]);
    htit=title({[datname];['Stimulation  for ',num2str(TRIALS),' trials'];...
     ['channel ',num2str(CHANNELS(ii))]},'Interpreter','none','Fontsize',14);
end;
 


%make a burst detection for the resp channels during the resp period, FROM
%the RESPONSE SPIKES
Responses = struct('time',[],'channel',[]);
NoResp    = struct('time',[],'channel',[],'trial',[]);
Prestim   = struct('time',[],'channel',[]);
for ii=1:nr_channels
    for jj=1:TRIALS
        trial_ind     = find(stim_raster(hw_channels(ii)+1,:,jj) >0 );
        %find all the PRE_Spikes in a window of defined length before the
        %stim
        prestim_ind   = find(stim_raster(hw_channels(ii)+1,:,jj) <0);
        if ~isempty(trial_ind) 
            Responses.time    = [Responses.time stim_raster(hw_channels(ii)+1,trial_ind,jj) + stim_times(jj)];
            Responses.channel = [Responses.channel hw_channels(ii)*ones(1,length(trial_ind))]; 
        else
            %it can of course also happen that here was no post activity (i.e. also no response)  at all,
            %consider those cases separatly
            NoResp.time       = [NoResp.time stim_times(jj)];
            NoResp.channel    = [NoResp.channel hw_channels(ii)];
            NoResp.trial      = [NoResp.trial jj];
            
        end
        
        if~isempty(prestim_ind)
             Prestim.time    = [Prestim.time stim_raster(hw_channels(ii)+1,prestim_ind,jj) + stim_times(jj)];
             Prestim.channel = [Prestim.channel hw_channels(ii)*ones(1,length(prestim_ind))]; 
        end
    end
end


%NOW make a burst detection on the responses
Response_burst = burst_detection_all_ch(Responses,RESPONSE_MAX_INT,RESPONSE_MAX_BURST_INT,RESPONSE_MIN_NO_SPIKES);

%Note that this can also include bursts which come some time later than the
%stim, depending on the window that was choosen for the stim_raster
%calculation, therefore define the burst onsets now

for ii=1:nr_channels
    burst_starts{ii} = cellfun(@(x) x(1), Response_burst{1,hw_channels(ii)+1}(:,3));
    %find those bursts that are actually due to the stim
    response_burst_ind  = [];
    trial_ind           = [];
    for jj=1:TRIALS
       
        response_burst_rel_ind    =  find(burst_starts{ii}>=stim_times(jj) & burst_starts{ii}<stim_times(jj)+RESPONSE_MAX_ONSET);
       
        if ~isempty(response_burst_rel_ind)
            response_burst_ind    = [response_burst_ind response_burst_rel_ind(1)];
            trial_ind             = [trial_ind jj];
        end
        
    end
    Response_burst_temp{ii}                                 = Response_burst{1,hw_channels(ii)+1}(response_burst_ind,:);
    Response_burst_temp{ii}(1:length(response_burst_ind),1) = num2cell(1:length(response_burst_ind));
    %define a new entry, namely the trial that leads to the detected burst
    Response_burst_temp{ii}(1:length(response_burst_ind),5) = num2cell(trial_ind);
    
        %I can define certain criterias accordingto which the trials are
        %sorted:
        
        %SORT_CRITERIA = Length of whole response
        %I can conveniently define the length of the response as the time
        %between stim onset and burst end
        Response_burst_temp{ii}(1:length(response_burst_ind),6) = num2cell(cellfun(@(x) x(end), Response_burst_temp{ii}(:,3)) - stim_times(trial_ind)');
   
        %SORT_CRITERIA = Length from first to last spike in response
        %Define the response length as the time between response onset
        %(first spike) and response end (last spike)
        Response_burst_temp{ii}(1:length(response_burst_ind),7) = num2cell(cellfun(@(x) x(end), Response_burst_temp{ii}(:,3)) - cellfun(@(x) x(1),Response_burst_temp{ii}(:,3)) );
   
        %SORT_CRITERIA = NR of spikes in response
        Response_burst_temp{ii}(1:length(response_burst_ind),8) = [Response_burst_temp{ii}(:,2)];
    
        %SORT_CRITERIA = Delay of first spike
        %Another option would be to standardize on the delay of the first
        %spike in the response
        %reshaping the stim raster array for a better handling of the data
        reshaped_raster     = reshape(stim_raster(hw_channels(ii)+1,:,:),size(stim_raster,2),size(stim_raster,3));
        cell_raster{ii}     = mat2cell(reshaped_raster,size(stim_raster,2),ones(1,size(stim_raster,3)));
        %find all the spikes >0 in the considered trials
        pos_spikes = cellfun(@(x) x(find(x>0)),cell_raster{ii}(trial_ind),'UniformOutput',false);
        
        delays              = cellfun(@(x) x(1),pos_spikes);
        Response_burst_temp{ii}(1:length(response_burst_ind),9) = num2cell(delays);
        
        %A further sorting criteria:  nr_spikes/delay
        Response_burst_temp{ii}(1:length(response_burst_ind),10) = num2cell([Response_burst_temp{ii}{:,2}]./delays);
        
        %also save the Delay of the first spike in the long term
        %compponent. The start of the long-term(lt) component is defined by
        %a parameter
        %find the pos_spikes in the long-term component
        pos_spikes_lt_comp              = cellfun(@(x) x(find(x>LONG_TERM_COMPONENT &x<RESPONSE_MAX_ONSET)),cell_raster{ii}(trial_ind),'UniformOutput',false);
        %find trials that eventually do not have spikes in the lt component
        no_lt_trials                    = cellfun(@(x) length(x)==0,pos_spikes_lt_comp);
        no_lt_trials_ind                = find(no_lt_trials==1);
        lt_trials                       = setdiff(1:length(response_burst_ind),no_lt_trials_ind);
        %define the delay in those trials as infinite
        pos_spikes_lt_comp(no_lt_trials) = num2cell(Inf);
        %calculate  the delay of the lt component spike
        delays_lt_comp = cellfun(@(x) x(1),pos_spikes_lt_comp);
        %Store the result
        Response_burst_temp{ii}(1:length(response_burst_ind),11) = num2cell(delays_lt_comp);
        
        % Save the Nr of spikes in the long term component of the
        %response, i.e. >25 - 50 msec
        Response_burst_temp{ii}(1:length(response_burst_ind),12) = num2cell(cellfun(@(x) length(find(x>LONG_TERM_COMPONENT)),Response_burst_temp{ii}(:,3)));
        
        %This caculates the parameter
        %spike_length*no_of_spikes*nrspikes_lt_comp/delay
        %Response_burst_temp{ii}(1:length(response_burst_ind),13) = num2cell( [Response_burst_temp{ii}{1:length(response_burst_ind),12}].*[Response_burst_temp{ii}{:,8}].*[Response_burst_temp{ii}{:,11}])
   % end
end

%add the Noresponse trials, for each channel separatly, the NoResponses have
%length 0
for ii= 1:nr_channels
    No_resp_ind           = find(NoResp.channel ==hw_channels(ii));
    Nr_burst_responses    = length([Response_burst_temp{ii}{:,1}]);
    
    
    %So far I have considered two kinds of trials: Trials with a
    %'burst' in the response and trials that don't have activity at all
    %in the defined post stimulus window (called No_resp here). There
    %are hwoever also trials which neither fulfill the above two
    %criteria, but which have activity (bursts) not defined as a
    %response but still in the post stimulus window. These trials can
    %be found with the intersection between all trials and the already
    %extracted ones
    burst_resp_trials  = [Response_burst_temp{ii}{:,5}];
    no_activity_trials = NoResp.trial(No_resp_ind);
    spont_act_trials   = setdiff(1:TRIALS,[burst_resp_trials no_activity_trials]);  %find those trials that neither belong to one of the two above criteria.
        
    if ~isempty(spont_act_trials)

        for kk=1:length(spont_act_trials)
            %to calculate thge necessary parameters also from the
            %(response)spikes that are not detected as a (response)burst, extract the response spikes first and calculate the parameters from this timeseries
            response_spikes                = cell_raster{ii}{spont_act_trials(kk)};
            resp_window_spikes             = response_spikes(find(response_spikes<RESPONSE_MAX_ONSET & response_spikes>0));
            if ~isempty(resp_window_spikes)
                
                all_length  = resp_window_spikes(end);                                   %entry nr 6
                spikelength = resp_window_spikes(end) - resp_window_spikes(1);           %entry nr 7
                no_of_spikes   = length(resp_window_spikes);                                %entry nr 8
                delay       = resp_window_spikes(1);                                     %entry nr 9
            else
                all_length  = 0;
                spikelength = 0;
                no_of_spikes   = 0;
                delay       = Inf;
            end
                
                
                
            Spont_act_trials{ii}{kk,1}     = length(burst_resp_trials)+kk;                  %save sthe running index
            Spont_act_trials{ii}{kk,2}     = 0;                                             
            Spont_act_trials{ii}{kk,3}     = stim_times(spont_act_trials(kk));           %save the stim time here          %          
            Spont_act_trials{ii}{kk,4}     = NaN;                                   
            Spont_act_trials{ii}{kk,5}     = spont_act_trials(kk);                       %save thee trial nr here                         
            Spont_act_trials{ii}(kk,6:9)   = num2cell([all_length spikelength no_of_spikes delay]);   %this stores the whole length (beginning of stim to last spike, the actual spikelength, the nr of spikes and the delay of the first spike
            Spont_act_trials{ii}(kk,10:12) = num2cell(zeros(1,length(10:12)));
            Spont_act_trials{ii}{kk,11}    = Inf;                                        %The 11th entry stores the delay in the long term component, so when there are only spont activity spikes that are not detected as responses, they get Inf as a delay parameter
        end
        
        
    end
                
    
   
    if ~isempty(No_resp_ind)
        for jj=1:length(No_resp_ind);
            No_resp_trials{ii}{jj,1}    = length(burst_resp_trials)+length(spont_act_trials)+jj;                  %save sthe running index
            No_resp_trials{ii}{jj,2}    = 0;                                                                      %save the nr of 'spikes', which in this case is 0
            No_resp_trials{ii}{jj,3}    = NoResp.time(No_resp_ind(jj));                                           %give here the stimulation time                 
            No_resp_trials{ii}{jj,4}    = NaN;                                                                      %no spike-index for stimulation
            No_resp_trials{ii}{jj,5}    = NoResp.trial(No_resp_ind(jj));                                            %gives the stimulation trial  
            No_resp_trials{ii}(jj,6:12) = num2cell(zeros(1,length(6:12)));
            No_resp_trials{ii}{jj,9}    = Inf;  %overwrite the parameter delay, which is Inf for no response
        end
        
    end
        
        
       %make a vertical concatenation of the response_burst_temp, the spont_act_trials and the
       %No_resp_trials
       if ~isempty(No_resp_ind) & ~isempty(spont_act_trials)
          Response_burst_temp{ii} = [Response_burst_temp{ii};Spont_act_trials{ii}; No_resp_trials{ii}];
       elseif isempty(No_resp_ind)
          Response_burst_temp{ii} = [Response_burst_temp{ii};Spont_act_trials{ii}];
       elseif isempty(spont_act_trials)
           Response_burst_temp{ii} = [Response_burst_temp{ii};No_resp_trials{ii}];
       end
       %in the case that there are neither trials with spont activity or no
       %responses at all, Response_burst_temp remains
    
end

clear Response_burst;
%start to sort the burst lengths, i.e. the response length
for ii=1:nr_channels
    [rsp_length sort_ind]   = sort([Response_burst_temp{ii}{:,6}]);
    Response_burst{ii}      = Response_burst_temp{ii}(sort_ind,:);
    Response_burst{ii}(:,1) = num2cell(1:length([Response_burst{ii}{:,1}]));
end




%MAKEalso a burst detection on the prestim spikes
Prestim_burst  = burst_detection_all_ch(Prestim,PRESTIM_MAX_INT,PRESTIM_MAX_BURST_INT,PRESTIM_MIN_NO_SPIKES);

%look at the ends of the bursts in the period before the stimulation and
%check if this end is closer than some threshold value to the stim time
%define a minimum gap between a last spike before the stimulation and the
%stimulation time, in sec
Min_gap = 0.2;

for ii =1:nr_channels
    burst_end{ii}   = cellfun(@(x) x(end),Prestim_burst{1,hw_channels(ii)+1}(:,3));
    burst_start{ii} = cellfun(@(x) x(1),Prestim_burst{1,hw_channels(ii)+1}(:,3));
    %now for all stim trials, check if a burst end exists that is close to
    %it
    Trial_remove_ind{ii} = [];
    for jj=1:TRIALS
        burst_trial_ind = find([burst_end{ii}]> stim_times(jj)-Min_gap & [burst_start{ii}]<stim_times(jj));
        if ~isempty(burst_trial_ind)
            %store the trial nr in which this case happend
            Trial_remove_ind{ii} = [Trial_remove_ind{ii} jj];
        end
    end
end
            


% I can now easily go over and remove those trials that have a burst before
% the stimulation, and also store those trials that have a burst separatly

for ii=1:nr_channels
    Trial_vec                       = [Response_burst{ii}{:,5}];
    Length_vec                      = [Response_burst{ii}{:,6}];
    [no_burst_trials ind_no_burst]  = setdiff(Trial_vec, Trial_remove_ind{ii});
    [I Ind_burst_trials temp]       = intersect(Trial_vec,Trial_remove_ind{ii});
    Response_burst_temp{ii}         = Response_burst{ii}(sort(ind_no_burst),:);
    Burst_before_stim{ii}           = Response_burst{ii}(sort(Ind_burst_trials),:);
    Response_burst_temp{ii}(:,1)    = num2cell(1:length([Response_burst_temp{ii}]));
    if ~isempty(Ind_burst_trials)
    Burst_before_stim{ii}(:,1)      = num2cell(1:length([Burst_before_stim{ii}(:,1)]));
    end
end


clear Response_burst
Response_burst = Response_burst_temp;



if PLOT_OUTPUT==0
    Response_stat = cell(nr_channels);
    return;
else
    ;
end
    
   

%I can now go over and plot for example the stim raster with the sorted
%trials
clear Trial_vec
nr_figs = 0;
for ii=1:nr_channels
    
    if intersect(new_fig_ch,ii)
        nr_figs = nr_figs+1;
        figure(stim_raster_ch_fig(nr_figs))  
        [plot_pos subplot_r subplot_c]    = get_subplot_position(Nr_ch_per_fig*2);
    end
    selectedhsub(ii*2)                    = subplot(subplot_r,subplot_c,plot_pos(ii*2-(nr_figs-1)*Nr_ch_per_fig*2)); 
    
    
     Trial_vec = [Response_burst{ii}{:,5}];
     for jj=1:length(Trial_vec)
         trial = Trial_vec(jj);
         plot(stim_raster(hw_channels(ii)+1,1:nr_spikes(hw_channels(ii)+1,trial),trial),jj*ones(nr_spikes(hw_channels(ii)+1,trial),1),'ok','MarkerSize',2,'Markerfacecolor', 'k');
         hold on;
     end;
    title(['channel ', num2str(CHANNELS(ii))], 'FontSize',14);
    xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
    title(['Sort criteria: ']);
    ylim([0 length(Trial_vec)]);
    ylabel('Trial Nr', 'FontSize', 14)
end



%make a stastistics about the Response distrubutions, i.e. calculating the
%mean, and std, and also the coefficient of variation. This can for example
%be used to compare different stimulation paradigms with respect to how
%regular the responses are
for ii = 1:nr_channels
    %calculate the std of the Response_length
    Response_stat{ii}(1) = std([Response_burst{ii}{:,6}]);
    %calculate also the mean of the distribution
    Response_stat{ii}(2) = mean([Response_burst{ii}{:,6}]);
    %calculate the coefficient of variation, i.e. std/mean
    Response_stat{ii}(3) = Response_stat{ii}(1)/Response_stat{ii}(2);
end

 
 
 
