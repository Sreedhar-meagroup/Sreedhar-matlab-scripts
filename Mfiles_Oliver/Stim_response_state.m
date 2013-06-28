%01/11/06
% this file characterizes different stimulus efficiencies. that means how
% does the response of the stimulus depend on the state of the network. I
% have seen in data set 010906_229stim.spike that the spike count of the
% response suppposively depends on the activity going on prior to the
% stimulation. 
% I plan to to some kind of phase plot (x-y-plane)
% spikes_preceeding_stim_trial "state" vs. spikes_after_stim_trial
% "response"
%this file is useful for single channel analysis and specifying the
%stimulation trail (e.g. day 1,2,3) is necessary

addpath('C:\Meabench\Data\Stimulus')%  location of Data files
addpath('C:\Meabench\Data\Incubator')%  location of Data files
addpath('C:\Program Files\Matlab71\work\mfiles\') %mfiles from michael
addpath('C:\Program Files\Matlab71\work\Meabench\matlab\') %Mfiles from meabench
%
datname='010906_229stim.spike';
GAIN=1;
ls=loadspike_noc(datname) % ohne Kontext


%delete the 100 first samples
ls.time(1:100)=[]; 
ls.channel(1:100)=[]; 
ls.height(1:100)=[]; 
ls.width(1:100)=[]; 
ls.thresh(1:100)=[]; 

excludechannels=[15 27  57];  %MEA style
excludechannels=cr2hw(excludechannels);
for i=1:length(excludechannels)
    indices=find(ls.channel==excludechannels(i));
    ls.time(indices)=[];
    ls.channel(indices)=[];
    ls.height(indices)=[]; 
    ls.width(indices)=[]; 
    ls.thresh(indices)=[]; 
    clear indices;
end


samplestep=0.00004;
UNITLENGTH=25; %i.e. 25 samples are one ms
PRESTIMULI=UNITLENGTH*1000; %i.e. 20*25 samples
POSTSTIMULI=UNITLENGTH*1000;
%timestamps of stimuli
positionen=find(ls.channel==61);
zeitpunkte=ls.time(positionen);
TRIALS=length(zeitpunkte);

day=3;
first_trial=(day-1)*180+1;
last_trial=day*180-2;
trial_vec=first_trial:last_trial;
total_trials=last_trial-first_trial;
channel_mea=55;
channel=cr2hw(channel_mea);



    channel
    chindex=find(ls.channel==channel);
    chtimestamps=ls.time(chindex);
    for i=1:total_trials  %i.e for every trial
        trial=trial_vec(i);
    pre_spikes=find( chtimestamps > (zeitpunkte(trial)-PRESTIMULI)& ( chtimestamps < zeitpunkte(trial)));
    post_spikes=find(chtimestamps > zeitpunkte(trial) & (chtimestamps < zeitpunkte(trial)+POSTSTIMULI));
    no_pre_spikes(i)=length(pre_spikes);
    no_post_spikes(i)=length(post_spikes);
    end;


    figure
    color_order=get(gca, 'ColorOrder');
    for i=1:length(pre_post_sort)
  %plot(no_pre_spikes,no_post_spikes,'*');
  p_handle(i)=plot(pre_post_sort(i).pre_spikes,pre_post_sort(i).post_spikes,'*','Color', color_order(i,:));
  %xlim([-5 max(no_pre_spikes)+5]);
  hold on
  xlabel([' spikes in pre stimulation trial']);
  %ylabel([' spikes in ', num2str(POSTSTIMULI/UNITLENGTH),' ms window post stimulation trial']);
   ylabel([' spikes in  post stimulation trial']);
  title({['dataset: ', num2str(datname), ' , channel ',num2str(channel_mea), ' , trials ',num2str(first_trial), '- ',num2str(last_trial)];['pre stimulation window: ', num2str(PRESTIMULI/UNITLENGTH), ' ms'];['post stimulation window: ', num2str(POSTSTIMULI/UNITLENGTH), ' ms']});                                       
    end; 
    

legend(p_handle(1:end),strcat('channel ',num2str([pre_post_sort(1:end).channel]),' ', ' day ', num2str([pre_post_sort(1:end).day])),1)













