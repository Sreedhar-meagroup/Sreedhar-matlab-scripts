%this makes another type of spikesorting, i.e plotting the max and min
%value observed in a spike over time. If for example both values monotonically go up over
%timescale of hours, this could be an indication for a drift. 
%But meabench does not store max and min values of one spike, so I have to
%look through all the cutouts and determine these
% values by hand. E.g. if a spike was saved as negative, I have to
% determine the corresponding positive part of the biphasic spike. The same holds true for the other way round.
%Of course, it is better to do this analysis on a single-channel basis.

datname='25_10_06_287stim3.spike'
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

%make a fast detection of the most active spikes
n=hist(ls.channel,0:60);
for ch=1:60
    activity(ch,1)=ch-1;
    activity(ch,2)=n(ch);
end

%sort the channels according to activity
[activity_sort activity_sort_ind]=sort(activity,1,'descend');
 activity_sort(:,1)=activity(activity_sort_ind(:,2),1);
 activity_sort_MEA=hw2cr(activity_sort(:,1)');

%channel under investigation
channel_MEA=[activity_sort_MEA(1)];
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
recording_secs=ch_spike_times(end)-ch_spike_times(1);
recording_hrs=recording_secs/(60*60);


%find the spike timepoints for each successive hour
for i=1:floor(recording_hrs)
    hrs=ch_spike_times-(60*60*i);
    hrs=abs(hrs);
    hrs_ind=find(hrs==min(hrs));
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
fig2plot=plot(ch_spike_times,spike_stat,'*','MarkerSize',5)
xlabel({['spiketimes [sec]']},'FontSize',14);
ylabel('electrode Voltage [\mu V]','FontSize',14);
title({['dataset: ', num2str(datname),'; channel ',num2str(channel_MEA)];['amplitude for  pos and neg phase in spikes, over time']},'Fontsize',14,'Interpreter','none');




 %we can also make an average (let's say over a couple of spikes or a
 %some timeperiod) and plot this result over time
 
 no_in_average=50;
 average_pos_neg=zeros(floor(length(spike_stat)/no_in_average),2);
 for i=1:length(spike_stat)/no_in_average
     average_pos_neg(i,1)=mean(spike_stat((no_in_average*(i-1)+1):no_in_average*i,1));
     average_pos_neg(i,2)=mean(spike_stat((no_in_average*(i-1)+1):no_in_average*i,2));
 end
 
 amplfig3=figure;
 fig3plot=plot(1:length(average_pos_neg),average_pos_neg);
ylabel('electrode Voltage [\mu V]','FontSize',14);
xlabel({['bin nr. for pooled spikes, averaging ',num2str(no_in_average),' spikes']},'FontSize',14);
title({['dataset: ', num2str(datname),'; channel ',num2str(channel_MEA)];[' averaged amplitude for pos and neg spike phase, development over time'];['dataset has a total'...
        'of ',num2str(length(spike_stat)),' spikes']},'Fontsize',14,'Interpreter','none');



    







 
 
 
 
 