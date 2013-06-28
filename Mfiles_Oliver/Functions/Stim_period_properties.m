%This file is intended to extract different features of the stimulation
%period and the spont. activity on the stimulaion electrode. The usage is
%in trying to find criteria that have to be fulfilled to exert e.g. a
%superburst-stopping effect with a certain stimulaion electrode. Therfore,
%this file was run for different elecrodes that showed such an effect anf
%for such that did not show such an effect. The results are listed in a structure and
%%later saved in an excel sheet.
% 
%The file does not exist yet as a function, but the datname and the structure ls
%should exist in the work space. Then this script can almost be used in
%free run, at least for random and stimulation_in_silence paradigm.
% For feedback experiments, the case looks different because there, a
% direct response, e.g. as the nr. of spikes is not easily accessible.
% This could only be extracted from PBTHs for stimulated vs. unstimulated
% bursts. Therefore, this script includes some lines of code for feedback
% experiments that do all that from already calculated PBTHs. (Taking the
% cell array save_array that was previoulsy used from calculations of PBTHs
% on the Loki server)
% 
% 
%
%At the beginning, some basic settings have to be made.



Stim_start = 6991;   %give the start time of the Stimulation in seconds
Stim_end   = 13886; %same for the end of the stimulation


Control_start = 0;
Control_end   = 6990;

Stim_channel    = 44;   %first of all in MEA notation
Stim_channel_hw = cr2hw(Stim_channel);


%find the stimulation times
stim_times = ls.time(find(ls.time>Stim_start & ls.time<Stim_end & ls.channel==61)); 


Nr_stim = length(stim_times);    
%Nr of stimulations per second on average
Stim_per_sec = Nr_stim/((Stim_end-Stim_start));


%Plot a StimulusEffect figure to estimate the nr. of responding electrodes;
%plot maximally 500 trials

start_plot = stim_times(1)/3600;
if Nr_stim >500
    end_plot = stim_times(500)/3600;
else
    end_plot = stim_times(end)/3600; 
end

%plot the StimulusEffect function to estimate the Nr. of responding electrodes 
    StimulusEffect(datname,ls,61,start_plot,end_plot,0.5,1)
    
    %Give the nr. of responding electrodes as an input
    
    nr_resp_electrodes = input('How many determined responding electrodes?\n');
    
    Analysis_Electrodes = input('Which electrodes to analyze for nr. spikes/stimtrial?\n');
    
    %%%% THE FOLLOWING IS FOR 'RANDOM' AND 'STIMULAION_IN_SILENCE PARADIGM'
    %%%
    %from the function extract_short_term_response, I can conveniently get
    %all the response spikes, up to a defined window after the stimulatin.
    %If I set this to approx. 0.5 sec, I get most of the response spikes, or
    %at least I operate in a defined window after the stimulation;
    %I should do the described analysis for the same period of stimulation
    %as above (i.e. maximally 500 stim trials
    
    %give a time window post stim in msec where the spikes should be
    %detected
    Time_window_post_stim = 500;  %gibe
    Response_spikes = extract_short_term_response(ls,Analysis_Electrodes,Time_window_post_stim,start_plot,end_plot);
    
    Nr_ana_electrodes = length(Analysis_Electrodes);
    Nr_trials         = size(Response_spikes,1);
    
    %cycle throught the relevant electrodes and determine all the response
    %spikes
    for ii=1:Nr_ana_electrodes
        hw_el               = cr2hw(Analysis_Electrodes(ii));
        All_resp_spikes(ii) = length([Response_spikes{:,hw_el+1}]);
    end
    
    Resp_spikes_trial(:,2) = All_resp_spikes/Nr_trials;
    Resp_spikes_trial(:,1) = Analysis_Electrodes;
    
    
    
    
    %%%%%%FOR THE FEEDBACK PARADIGM, HAVE THE CELL ARRAY SAVE_ARRAY IN THE
    %%%%%%WORKSPACE THAT WAS STORED AS A RESULT FROM CALCULATIONS OF PBTHS
    %%%%%%ON THE SERVER. The "response" to the stimulaion is defined as the
    %%%%%%nr. of spikes per trial solely elicited by the stimulaion. This
    %%%%%%is achieved by taking the difference between the stimualated and
    %%%%%%unstimulated bursts and summing over the same time window as
    %%%%%%above for the other paradigms.
    
    Time_window_post_stim = 500;  %given in msec
    
    %defien the stimperiod (in cyclical stimulaion), also needed is the pre
    %and post timewindow and the binwith
    period         = 1
    pre_window     = 0.5;  %given in sec
    post_window    = 1;
    PBTH_bin_width = 0.01;
    
    %define the inside and outside PBTH
    inside_PBTH  = save_array{period,1};
    outside_PBTH = save_array{period,2};
    inside_trigger_times  = save_array{period,3};
    outside_trigger_times = save_array{period,4};
    
    %define the "difference PBTH"as the difference between inside and
    %outside condition for each bin
    diff_PBTH = inside_PBTH - outside_PBTH;
    
    %set the Nr of trials (should be the same for inside and outside
    %condition)
    Nr_trials = size(outside_trigger_times,1);
    %in order to work properly, I need to know which channels are stored
    %where in the save_array, the vecor CHANNELS as generated with th
    %ePBTHs helps here
    
    %Define the starting bin and end_bin
    start_bin = pre_window/PBTH_bin_width+2;    %because the first bin is filled wth a NaN
    end_bin = start_bin+Time_window_post_stim/1000/PBTH_bin_width-2;
    
    for ii = 1:Nr_ana_electrodes
        ch_ind = find(Analysis_Electrodes(ii)==CHANNELS);
        Resp_spikes_trial(ii,2) = sum(diff_PBTH(ch_ind,start_bin:end_bin))/Nr_trials;
    end
    Resp_spikes_trial(:,1) = Analysis_Electrodes
    
    %%%
    %%%
    %%END OF THE FEEDBACK_STIM RESPONSE DETERMINATION
   
    
    %define the InterStimulusInterval, to determine properties of the
    %stimulation times
    IstimI      = diff(stim_times);
    Mean_IstimI = mean(IstimI);
    Std_IstimI  = std(IstimI);    
    
    %finished with the properties of the stimulation, going over tp
    %properties of the stimualtion electrode itself
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%make a burst detection first
burst_detection = burst_detection_all_ch(ls);
all_bursts      = size(burst_detection{1,Stim_channel_hw+1},1)

for ii = 1:all_bursts
    burst_onsets(ii) = burst_detection{1,Stim_channel_hw+1}{ii,3}(1);
end

%find the relevant bursts in the control period
burst_ind = find(burst_onsets>=Control_start & burst_onsets<=Control_end);
Nr_bursts = length(burst_ind);

%determine the nr. of bursts/minute in the control period on the stim
%channel
Burst_per_min = Nr_bursts/((Control_end - Control_start)/60);


%determine also the average nr. of spikes/burst in the control period at
%the stimulation channel
Avg_spikes_per_burst = mean([burst_detection{1,Stim_channel_hw+1}{burst_ind,2}]);
Std_spikes_per_burst = std([burst_detection{1,Stim_channel_hw+1}{burst_ind,2}]);


%go over to the Network burst properties of this particular electrode
%make the network burts detection on those channels that also respond
%tostimualtion, this is somewhat arbitrary, but nevertheless practicable
[b_ch_mea network_burst NB_onset]= Networkburst_detection(datname,ls,burst_detection,nr_resp_electrodes);

%deternine the Nr. of network bursts in the control period
NB_ind_control = find(NB_onset(:,2)>Control_start & NB_onset(:,2)<Control_end);
Nr_NB_control = length(NB_ind_control);

stim_el_participation =0;
for jj = 1:Nr_NB_control
    if find(network_burst{NB_ind_control(jj),1} == Stim_channel_hw+1)
        stim_el_participation = stim_el_participation+1;
    end
end

Stim_el_NB_percentage = stim_el_participation/Nr_NB_control;


%determine the nr. of NBs that are started by the stim el
NB_starts = length(find(NB_onset(NB_ind_control,1) ==Stim_channel_hw+1));

%find the avg. position in th eNB-firing with the functin burst_sequence
EL_position = burst_sequence(datname,network_burst,NB_onset,b_ch_mea,Control_start/3600,Control_end/3600);
%take only thoise NB where the stim_channel is not NaN
el_nr_ind =find(b_ch_mea==Stim_channel);
%exclude all the NaNs
burst_ind     = find(EL_position(el_nr_ind,:)>=1);
Avg_burst_pos = mean(EL_position(el_nr_ind,burst_ind))

    
    
    


%by plotting the function ISI_inburst_distribution, I can coneniently check
%if the stim electrode has uni-modal or bimodal (meaning alot of ISIs<5ms)
%ISI distribution

ISI_inburst_distribution(datname,burst_detection,Stim_channel);
ISI_mode = input('Considerable nr. of ISIs <5ms? (give yes, no or undet\n)','s')


%Finally, check the rateprofile with its potential Superbursts.
% Is the firing between superburst steadily increasing,or, as also sometimes observed,
% first a sudden increase, then a drop towards the beginning of the next superburst.
% There seem to be two fundamental different firing behaviors between superbursts


ch_spikes = ls.time(find(ls.channel==Stim_channel_hw & ls.time>Control_start & ls.time<Control_end));
bin_width = 5;
bin_vec     = Control_start:bin_width:Control_end;
spike_hist  = hist(ch_spikes,bin_vec);
figure;
stairs(bin_vec./3600,spike_hist./bin_width);
ylim([0 2*max(spike_hist/bin_width)]);
xlim([Control_start Control_end]/3600)
title({['rate profile for Stimulation channel ', num2str(Stim_channel),' dataset: ',num2str(datname)];['binwidth = ', num2str(bin_width),' sec.']},'Interpreter','none'); 
ylabel('rate [Hz]');
xlabel('time [hrs]');

disp('Shape of rate profile between two SBs, increasing, decreasing, or undetermined?\n');
SB_rate_prof_shape = input('give increasing, decreasing or undet', 's');
    
    
    
%%%%%%%%%%%%%%%%%%%%
% END CHECKING THE Acitvity properties of the stim channel,now
% assmeble all the extracted parameters
%     
Stim_period_property(1).type      = 'Dataset Name';
Stim_period_property(1).val       = datname;

Stim_period_property(end+1).type  = 'Stimulation electrode';
Stim_period_property(end).val     = Stim_channel; 

Stim_period_property(end+1).type  = 'Stimulation period (hrs)' 
Stim_period_property(end).val     = [Stim_start Stim_end]/3600;

Stim_period_property(end+1).type  = 'Control period (hrs)' 
Stim_period_property(end).val     = [Control_start Control_end]/3600;

Stim_period_property(end+1).type  = ' Nr. stimulation/second' 
Stim_period_property(end).val     = Stim_per_sec;

Stim_period_property(end+1).type  = ' Nr. responding electrodes';
Stim_period_property(end).val     = nr_resp_electrodes;

Stim_period_property(end+1).type  = 'Electrodes analyzed for nr. spikes/response'  
Stim_period_property(end).val     = Analysis_Electrodes;

Stim_period_property(end+1).type  = ' Avg. nr.spikes/response in chosen electrodes' 
Stim_period_property(end).val     = Resp_spikes_trial;

Stim_period_property(end+1).type  = ' Mean and Std of InterStimulusInterval distribution' 
Stim_period_property(end).val     = [Mean_IstimI Std_IstimI];

Stim_period_property(end+1).type  = ' Nr of bursts/minute in control period at the stim channel'
Stim_period_property(end).val     = Burst_per_min;

Stim_period_property(end+1).type  = ' Avg. nr. spikes/burst and std of spikes per burst distribution';
Stim_period_property(end).val     = [Avg_spikes_per_burst Std_spikes_per_burst];

Stim_period_property(end+1).type  = ' Percentage of participation in NBs';
Stim_period_property(end).val     = Stim_el_NB_percentage;

Stim_period_property(end+1).type  = 'Nr. of NB starts / total nr of NBs'
Stim_period_property(end).val     = [NB_starts Nr_NB_control]

Stim_period_property(end+1).type  = 'Avg. position in NB'
Stim_period_property(end).val     = Avg_burst_pos

Stim_period_property(end+1).type  = 'Considerbale nr. of ISIs <5ms';
Stim_period_property(end).val     = ISI_mode;

Stim_period_property(end+1).type  = 'SB rate profile between two SBs';
Stim_period_property(end).val     = SB_rate_prof_shape;

% Stim_period_property(end+1).type  = 
% Stim_period_property(end).val     = 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
