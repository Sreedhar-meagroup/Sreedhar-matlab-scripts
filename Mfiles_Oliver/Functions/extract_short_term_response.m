%function extract_short_term_response

%from datasets with stimulation, extract the short term response, which can
%be between 0-100 msec long. The window should be variable and the occurrence of artifacts
%should be considered. Extract the responses for each trial, for a given set of electrodes,
%in a specified period of time of the recording

%input:
%
% datname:             The file name
% ls:                  the usual list with spike information
% 
% 
% CHANNELS             the channel vector for which the current analysis
%                      should be made
% 
% Time_window          Time window after stimulation trigger where responses shoule be extracted, in msec! 
% 
% START_time, END_time  Start and end time of the analysis, in hrs
% 


function RESPONSE_spikes = extract_short_term_response(datname,ls, CHANNELS,Time_window,START_time,END_time)


nr_channels = length(CHANNELS)
HW_channels = cr2hw(CHANNELS);

TRIG_CH = 61;

stim_times      = ls.time(find(ls.channel==TRIG_CH & ls.time>=START_time*3600 & ls.time<=END_time*3600));

NR_trials       = length(stim_times)
ARTIFACT_WINDOW = 0.006;

RESPONSE_spikes= cell(NR_trials,nr_channels);

%loop through all trials and channels to search for response spikes
for ii=1:NR_trials
    if ~rem(ii,100)
        %just displaying each 100th cycle
        ii
    end
    %exclude the artifacts already here
     TRIAL_spikes    = ls.time(find(ls.time>=stim_times(ii)+ARTIFACT_WINDOW & ls.time<stim_times(ii)+Time_window/1000));
     TRIAL_channels  = ls.channel(find(ls.time>=stim_times(ii)+ARTIFACT_WINDOW & ls.time<stim_times(ii)+Time_window/1000));
     
    for jj=0:61
        if find(jj==HW_channels)
            response_spikes = TRIAL_spikes(find(TRIAL_spikes>stim_times(ii) & TRIAL_spikes<stim_times(ii)+Time_window/1000  & TRIAL_channels==jj));
            
            %this saves the RELATIVE stim times!
            RESPONSE_spikes{ii,jj+1} = response_spikes - stim_times(ii);
        end
    end
end


%
Nr_intervals = 10;
IstimI       = diff(stim_times);
%find the indices in IstimI where it is either 1,2,3,...sec
%work in discrete steps
%BUT BE CAREFUL, the fct diff gives as a result a vector which has at its
%ith position the difference between i+1 and i, i.e. the IstimI i is the
%difference between stim i+1 and i, so actually the stimulation at times
%i+1 should be assigned the IsimI value i
for jj=1:Nr_intervals;
    IstimI_ind{jj} = find(IstimI>=jj-1 +0.5 & IstimI<=jj+0.5);
    %for all intervals, for the sum of channels
   
end

%give rasters with different examples for stim trials that have a long,
%medium or short IstimI; the rasters, i.e the responses sould look
%different. The rasters, i.e. the spike responses should have been
%extracxted previously, e.g. with the fct extract_short_term_response
diff_istim_rasters_fig = screen_size_fig

intervals_plotted = 8
subplot_r         =  intervals_plotted;
subplot_c         = nr_channels;


for ii=1:intervals_plotted
    
    Nr_trials = length(IstimI_ind{ii});
    
    for jj=1:nr_channels
        
        sub_h((ii-1)*nr_channels+jj) = subplot(subplot_r,subplot_c,(ii-1)*nr_channels+jj);
        for kk = 1:Nr_trials
            %the +1 goes in here because of the mentioned problem above
            st = RESPONSE_spikes{IstimI_ind{ii}(kk)+1,HW_channels(jj)+1};
            plot(st,kk*ones(1,length(st)),'ko', 'markeredgecolor','k','markerfacecolor', 'k');
            hold on
        end
    end
end
for ii=1:nr_channels
    axes(sub_h(ii))
    title(['channel ', num2str(CHANNELS(ii))]);
    xlabel('Time r.t. stimulus [sec]')
   
end


for jj=1:intervals_plotted
    axes(sub_h(1+(jj-1)*nr_channels))
     ylabel({['Trials with'];[' IstimI >', num2str(jj-1+0.5)];['and <= ',num2str(jj+0.5)];['Trial Nr']},'FontSize', 12)
end

axes(sub_h(1))
title({['datname: ',num2str(datname)];['between hr', num2str(START_time),' and ', num2str(END_time)];['channel ', num2str(CHANNELS(ii))]});











