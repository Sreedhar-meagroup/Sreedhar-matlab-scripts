%this makes another type of spikesorting, i.e plotting the max and min
%value observed in a spike over time. If for example both values monotonically go up over
%timescale of hours, this could be an indication for a drift. 
%But meabench does not store max and min values of one spike, so I have to
%look through all the cutouts and determine these
% values by hand. E.g. if a spike was saved as negative, I have to
% determine the corresponding positive part of the biphasic spike. The same holds true for the other way round.
%Of course, it is better to do this analysis on a single-channel basis.




datname='23_10_06_291stim.spike'
GAIN=2;
ls=loadspike_shortcutouts(datname,GAIN,25) % mit Kontext


%delete the 100 first samples
ls.time(1:100)=[]; 
ls.channel(1:100)=[]; 
ls.height(1:100)=[]; 
ls.width(1:100)=[]; 
ls.thresh(1:100)=[];
ls.context(:,1:100)=[];

%correct the wrong import of the context data (the values are given as
%digital ones)
gain_table=GAIN+1;
electrode_range_table = [3410 1205 683 341];
ls.context=ls.context-electrode_range_table(gain_table);

samplestep=0.00004;
UNITLENGTH=25; %i.e. 25 samples are one ms

%channel under investigation
channel_MEA=[41];
channel=cr2hw(channel_MEA);

channelindex=find(ls.channel==channel);
%get all the cutouts for the respective channel
ch_cutouts=ls.context(:,channelindex);




%save all the max and min values in a spike in spike_stat
spike_stat=zeros(length(ch_cutouts),2);
for i=1:length(ch_cutouts)
    spike_stat(i,1)=max(ch_cutouts(:,i));
    spike_stat(i,2)=min(ch_cutouts(:,i));
end



ch_spike_times=ls.time(channelindex);
recording_secs=ch_spike_times(end);
recording_hrs=recording_secs/(60*60);


%find the spike timepoints for each successive hour
for i=1:floor(recording_hrs)
    hrs=ch_spike_times-(60*60*i);
    hrs=abs(hrs);
    hrs_ind=find(hrs==min(hrs));
    hrs_ind
    hrs_spikes(i,1)=hrs_ind; %gives the index in ch_spike_times for each successive hour
    clear hrs;
end


amplfig=figure;
%plot the figure and give axis labels, title...
plot(1:length(spike_stat),spike_stat(:,:));
set(gca,'XTick',hrs_spikes,'XTickLabel',1:length(hrs_spikes));
xlabel({['time of recording [hrs]'];['absolute length on axis \propto no. of spikes']},'FontSize',14);
ylabel('electrode Voltage [\mu V]','FontSize',14);
title({['dataset: ', num2str(datname),'; channel ',num2str(channel_MEA)];['amplitude for  pos and neg phase in spikes, over time']},'Fontsize',14,'Interpreter','none');


amplfig2=figure;
figplot=plot(ch_spike_times,spike_stat,'*','MarkerSize',5)
xlabel({['spiketimes [sec]']},'FontSize',14);
ylabel('electrode Voltage [\mu V]','FontSize',14);
title({['dataset: ', num2str(datname),'; channel ',num2str(channel_MEA)];['amplitude for  pos and neg phase in spikes, over time']},'Fontsize',14,'Interpreter','none');




 chindex=find(ls.channel==channelnr);
    chtimestamps=ls.time(chindex);
   spikefig=figure;
%Channelspikes(context,spike number in trial, trial)  
Channelspikes=zeros(74,10,TRIALS);
    for i=1:TRIALS  %i.e for every trial
    %chindex is the indes in ls.channel and all others where a spike on the specified channel is stored
    prepoststimulusspikes=find(chtimestamps>(zeitpunkte(i)-PRESTIMULI) & (chtimestamps<(zeitpunkte(i)+POSTSTIMULI))); %the indices for the spikes around a stimuli
    Channelspikes(:,1:length(prepoststimulusspikes),i)=ls.context(:,prepoststimulusspikes);
    end;
    for j=1:10;
    startpoint=zeitpunkte(trialno);
    endpoint=(zeitpunkte(trialno)+73);
    plot((startpoint:endpoint),Channelspikes(:,j,trialno))
    hold on
    end;
    minimumaxes=min(Channelspikes(:,:,trialno));
    
    ylim([minimumaxes(1)-100 max(max(Channelspikes(:,:,trialno)))+100]);
    title(['verify biological spikes, dataset: ', num2str(datname),'for trial ', num2str(trialno)])
    clear Channelspikes;