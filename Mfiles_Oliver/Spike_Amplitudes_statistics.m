%this mfile makes a statistic of the spike amplitudes. the height
%of each spike (as saved in the spikeinfo) is extracted and used to make a
%statistic for positiv and negative spikes, and for different periods of
%recording. BE AWARE of the gain setting of the amplifier during
%stimulation, this affects the conversion from digital steps to electrode
%volts
%NOTE the first few detected spikes (upto 100) have to be discared.
%When looking at them you get unexpectable high values for height and
%cutouts.(maximum possible value for the height and the cutouts of 680 uv
%for example) This would affect the calculation of the mean and std
%considerably

%26/10 add scaling normalized to 1



addpath('C:\Meabench\Data\Stimulus')% Here are the data files
addpath('C:\Meabench\Data\Incubator')% Here are the data files
addpath('C:\Program Files\Matlab71\work\mfiles') %here are Michaels mfiles 
addpath('C:\Program Files\Matlab71\work\Meabench\matlab') %here are Meabenchs internal mfiles
%
datname='24_10_06_287stim3.spike' %SET THE RIGHT GAIN
GAIN=2;
%

ls=loadspike_noc(datname,GAIN,25) % without context, but specifying the gain setting. In this way, electrode volts are automatically converted to uvolts.
                               % even for digital values, negative spikes
                               % have a negative value, this holds of
                               % course also true for electrode volts
                                 
samplestep=0.00004;  %i.e 40 us

%delete the 100 first samples
ls.time(1:100)=[]; 
ls.channel(1:100)=[]; 
ls.height(1:100)=[]; 
ls.width(1:100)=[]; 
ls.thresh(1:100)=[]; 


%analog channels spike seem to have 0 height, easy to correct for that.
%they come from the trigger signal and are obviously only there during
%periods of stimulation. however, this would affect the further analysis
%during this period, so just throw 'em out

analog_out=find(ls.height==0);
ls.time(analog_out)=[];
ls.channel(analog_out)=[];
ls.height(analog_out)=[]; 
ls.width(analog_out)=[]; 
ls.thresh(analog_out)=[]; 

%for error correction purposes, due to unproper working of blanking etc...
excludechannels=[15 27 57];  %MEA style
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compile this part if analysis should be done for specified channels
ana_channel=[52];
channel_spikes=find(ls.channel==ana_channel)
    ls.time=ls.time(channel_spikes)
    ls.height=ls.height(channel_spikes); 
    ls.width=ls.width(channel_spikes); 
    ls.thresh=ls.thresh(channel_spikes); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make the differentiation between pos and neg spikes
pos_spikes=find(ls.height>0);
%pos_spikes=find(ls.height>0 & ls.channel==39);     %to address a special channel
pos_spike_times=ls.time(pos_spikes);         %times are in seconds
pos_spike_channels=ls.channel(pos_spikes);
pos_spikes_height=ls.height(pos_spikes);
no_of_pos_spikes=length(pos_spikes);

neg_spikes=find(ls.height<0);
neg_spike_times=ls.time(neg_spikes);
neg_spike_channels=ls.channel(neg_spikes);
neg_spikes_height=ls.height(neg_spikes);
no_of_neg_spikes=length(neg_spikes);



%bin the data, specify bin characteristic
figure

subplot(2,1,1)
pos_mean_total=mean(pos_spikes_height);
pos_std_total=std(pos_spikes_height);
pos_total_ctr=(pos_mean_total - 4*pos_std_total):(pos_std_total/4):(pos_mean_total + 4*pos_std_total); 
pos_spikes_hist=hist(pos_spikes_height, pos_total_ctr);
bar(pos_total_ctr, pos_spikes_hist);
xlabel('spike amplitude [uv]');
ylabel('no of occurrences');
title({['dataset ',datname];[' distribution of (positive) spike amplitudes, with a total of ', num2str(no_of_pos_spikes), ' pos spikes']}, 'Interpreter', 'none');
hold on
%for the negative spikes
subplot(2,1,2)
neg_mean_total=mean(neg_spikes_height);
neg_std_total=std(neg_spikes_height);
neg_total_ctr=(neg_mean_total - 4*neg_std_total):(neg_std_total/4):(neg_mean_total + 4*neg_std_total); 
neg_spikes_hist=hist(neg_spikes_height, neg_total_ctr);
bar(neg_total_ctr, neg_spikes_hist);
xlabel('spike amplitude [uv]');
ylabel('no of occurrences');
title(['distribution of (negative) spike amplitudes, with a total of ', num2str(no_of_neg_spikes), ' neg spikes']);





%get the length of the recording, in minutes
recording_length=ls.time(end)/60;
recording_hrs=recording_length/60;
recording_hrs=ceil(recording_hrs);    % gives the recording length in hrs
if recording_hrs >8 & recording_hrs <24
    timeperiod = 2;                   %timeperiod is the timeinterval for the different periods where the calculations are done
    recording_periods=floor(recording_hrs/timeperiod);
elseif recording_hrs >24 & recording_hrs <48
    timeperiod = 4;
    recording_periods=floor(recording_hrs/timeperiod);
elseif recording_hrs >48
    timeperiod=6;
    recording_periods=floor(recording_hrs/timeperiod);
else
    timeperiod = 1;
    recording_periods=recording_hrs;
end



%prepare data for a plot that plots the distributions for different TIME
%PERIODS

pos_spike_amplitude=cell(recording_periods,1)                              %creates a recording_periods x 1 dimensional cell 
for i=1:recording_periods
    lowerbound=(i-1)*timeperiod*3600;
    upperbound=i*timeperiod*3600;
    indices=find(pos_spike_times>lowerbound & pos_spike_times<upperbound);  %the indices for the pos. spikes in the respective time period
    pos_spikes_amplitude{i,:}=pos_spikes_height(indices)';                %use the same indices for the height of the respective spikes
    no_of_pos_spikes_time(i)=length(indices);
end

%find the mean of the spike amplitudes in each timeperiod to get the right
%histogram bins
%also calculate the std in each period and find the right bins used inthe
%histogram
for i=1:recording_periods
pos_ampl_mean(i)=mean(pos_spikes_amplitude{i,1});
pos_ampl_std(i)=std(pos_spikes_amplitude{i,1});
pos_center(i,:) = (pos_ampl_mean(i)-3*pos_ampl_std(i)):(pos_ampl_std(i)/10):(pos_ampl_mean(i)+3*pos_ampl_std(i));
pos_spikes_time_hist(i,:)=hist(pos_spikes_amplitude{i,:}, pos_center(i,:));   %this is where the actual histogram is calculated
%pos_spikes_time_hist_norm(i,:)=pos_spikes_time_hist(i,:)/no_of_pos_spikes_time(i);   %scale to 1
end


%make subplot for the positive spikes
ylimit_pos=max(max(pos_spikes_time_hist))*1.1;  %10pct plus the maximum binvalue for same scaling on each diagram
histfig=figure;
for i=1:recording_periods
    if recording_periods <=4
        hsub(i)=subplot(2,recording_periods,i);
    elseif recording_periods <=6
        hsub(i)=subplot(2,3,i);
    elseif recording_periods <=12
        hsub(i)=subplot(3,4,i);
    end
bar(pos_center(i,:),pos_spikes_time_hist(i,:));
ylim([0 ylimit_pos]);
xlabel('spike amplitude [uv]');
ylabel({['total ',num2str(no_of_pos_spikes_time(i)), ' spikes'];['no of occurrences']});
title(['mean: ',num2str(pos_ampl_mean(i)),' uV, hr. ',num2str(i*timeperiod)]);
end

%hchil=get(histfig, 'Children');
title(hsub(1),{['dataset ',num2str(datname)];[];[' mean: ',num2str(pos_ampl_mean(1)),' uV, hr. ',num2str(1*timeperiod)]},'Interpreter','none');





%the same for the negative spikes

neg_spike_amplitude=cell(recording_periods,1)                              %creates a recording_periods x 1 dimensional cell 
for i=1:recording_periods
    lowerbound=(i-1)*timeperiod*3600;
    upperbound=i*timeperiod*3600;
    indices=find(neg_spike_times>lowerbound & neg_spike_times<upperbound);  %the indices for the neg. spikes in the respective time period
    neg_spikes_amplitude{i,:}=neg_spikes_height(indices)';                %use the same indices for the height of the respective spikes
    no_of_neg_spikes_time(i)=length(indices);
end

%same procedures as above
for i=1:recording_periods
neg_ampl_mean(i)=mean(neg_spikes_amplitude{i,1});
neg_ampl_std(i)=std(neg_spikes_amplitude{i,1});
neg_center(i,:) = (neg_ampl_mean(i)-4*neg_ampl_std(i)):(neg_ampl_std(i)/10):(neg_ampl_mean(i)+4*neg_ampl_std(i));
neg_spikes_time_hist(i,:)=hist(neg_spikes_amplitude{i,:}, neg_center(i,:));   %this is where the actual histogram is calculated
%neg_spikes_time_hist_norm(i,:)=neg_spikes_time_hist(i,:)/no_of_neg_spikes_time(i);  
end


%make the plot
ylimit_neg=max(max(neg_spikes_time_hist))*1.1; 
 if recording_periods <=4
        histfig
 else 
      histfig_neg=figure;
    end

for i=1:recording_periods
    if recording_periods <=4
        hsub(i)=subplot(2,recording_periods,i+recording_periods);
    elseif recording_periods <=6
        hsub(i)=subplot(2,3,i);
    elseif recording_periods <=12
        hsub(i)=subplot(3,4,i);
    end
bar(neg_center(i,:),neg_spikes_time_hist(i,:));
ylim([0 ylimit_neg]);
xlabel('spike amplitude [uv]');
ylabel({['total ',num2str(no_of_neg_spikes_time(i)), ' spikes,'];['no of occurrences']});
title(['mean: ',num2str(neg_ampl_mean(i)),' uV, hr. ',num2str(i*timeperiod)]);
end
hchil=get(histfig, 'Children');
title(hsub(1),{['dataset ',num2str(datname)];[];[' mean: ',num2str(neg_ampl_mean(1)),' uV, hr. ',num2str(1*timeperiod)]},'Interpreter','none');























































