%plot the rate profiels and runa FFT for power spectrum estimation on it


%this is for the rate profiles
recording_begin=ls.time(1);
%recording_begin=3600*60
recording_end=ls.time(end);   % recording length in seconds;
%recording_end=3600*12;
recording_length=recording_end-recording_begin;
recording_length_hrs=recording_length/(60*60);
recording_beg_hrs=recording_begin/(60*60);
recording_end_hrs=recording_end/(60*60);
                
                
%A VERY NEW WAY OF CALCULATING THE RATE< MUCH EASIER & FASTER
bin_width=5;
bin_vec=0:bin_width:recording_end;
totalbins=length(bin_vec);
spikecount=zeros(64,totalbins);
for ch=0:63;
    ch
    ch_spikes=find(ls.channel==ch & ls.time <recording_end &ls.time>recording_begin);
    ch_spikes=ls.time(ch_spikes);   %this vec has all the spike times for the resp. channel
    spikecount(ch+1,:)=hist(ch_spikes,bin_vec);
end;








selected_mea=[17 26 48 53 78];% 
selectedchannels=cr2hw(selected_mea);
channelcount=length(selectedchannels);
subplotsizecolumn=2;
subplotsizerow=channelcount;
recording_begin=3600*0;
recording_end=3600*2;
recording_period_length_hrs=(recording_end-recording_begin)/3600;
rate_fft_sub=[];
smooth_length=10;
triang_vec=triang(smooth_length)/(smooth_length/2);
ma_ps=cell(1,4);
figure;
for CH_NR     = 1:length(selected_mea);
ch               = selectedchannels(CH_NR);
ch_spikes        = find(ls.channel==ch & ls.time <recording_end &ls.time>recording_begin);
ch_spikes        = ls.time(ch_spikes);   %this vec has all the spike times for the resp. channel
bin_width = 10;

bin_vec   = ch_spikes(1):bin_width:ch_spikes(end);
totalbins = length(bin_vec);
rate_timeseries_offset  = hist(ch_spikes,bin_vec);
rate_timeseries         = rate_timeseries_offset-mean(rate_timeseries_offset);  %substract a mean, i.a. an offset

%make the ususal rate profile plot

     max_count=max(rate_timeseries_offset);
     rate_limit=count_limits-max_count;
     take_limit=find(rate_limit>0);
     take_limit_ind=take_limit(1);  %take the first positive value, this will be the indes for the the ylimit in count_limits
     take_limit=count_limits(take_limit_ind);
     %figure;
     rate_fft_sub(CH_NR,1)=subplot(subplotsizerow,subplotsizecolumn,(CH_NR-1)*2+1);
     stairs(bin_vec,rate_timeseries_offset./bin_width,'Color',color_spec(take_limit_ind,:));
     set(gca, 'XLim',[ch_spikes(1) ch_spikes(end)],'YLim',[0 take_limit/bin_width],'XColor',color_spec(take_limit_ind,:),'YColor',color_spec(take_limit_ind,:)); 
     ylabel(['rate [Hz]'],'Fontsize', 10); 
     xlabel('time [sec] ','FontSize', 10);
     title(['channel ', num2str(selected_mea(CH_NR)),', bin width: ', num2str(bin_width),' sec'], 'FontSize',10)
   
 %now prepare the power spectrum plot by calculating nyqvist freq and frequecncy resolution    
nyqvist_freq   = 1/(2*bin_width);
freq_res(CH_NR)       = 1/(ch_spikes(end)-ch_spikes(1));
freq_vec              = 0:freq_res(CH_NR):nyqvist_freq;
nr_freq(CH_NR)        = length(freq_vec);

nr_freq_ranges=30;
freq_steps = length(freq_vec)/nr_freq_ranges;
freq_ind_start= floor([0:(nr_freq_ranges-1)]*freq_steps+1);
freq_ind_end=  floor([1:nr_freq_ranges]*freq_steps);
freq_ind_bin_center = floor([freq_ind_start+freq_ind_end]/2);


rate_fft       = fft(rate_timeseries)/length(rate_timeseries);
%power_spec     = rate_fft.*conj(rate_fft)/length(rate_fft);
power_spec=abs(rate_fft).^2;
%normalize w.r. to the mean "power" value. This should make the caclulation
%independent of the length of the recording. it doesn't make sense to
%normalize on the maximum power, since absoulte values do depend on the
%recording length. But that shouldn't be the case for mean values
norm_factor=mean(abs(rate_fft).^2);
power_spec_norm=power_spec/norm_factor;
ma_ps{CH_NR}                 = conv(power_spec_norm,triang_vec);
rm_indices=[1:length(triang_vec)/2-1 (length(ma_ps{CH_NR})-length(triang_vec)/2):length(ma_ps{CH_NR})];
ma_ps{CH_NR}(rm_indices)=[];
% for ii=1:nr_freq_ranges
% power_spec_ranges{ii}           = power_spec_norm(freq_ind_start(ii):freq_ind_end(ii));
% power_spec_avg(CH_NR,ii)          = mean(power_spec_ranges{ii}); 
% end
     rate_fft_sub(CH_NR,2)=subplot(subplotsizerow,subplotsizecolumn,(CH_NR)*2);
     %semilogx(freq_vec,power_spec(1:nr_freq));
%      semilogx(freq_vec,power_spec(1:nr_freq));
%      hold on;
     semilogx(freq_vec,power_spec_norm(1:nr_freq(CH_NR)));
     hold on;
     semilogx(freq_vec,ma_ps{CH_NR}(1:nr_freq(CH_NR)),'r');
     xlabel('frequency [Hz]');
     ylabel('power');
     title(['channel ', num2str(selected_mea(CH_NR))])
     
end  

subplot(subplotsizerow, subplotsizecolumn,1)
title({['rate profile, channel ', num2str(selected_mea(1))];['bin width for calculating rate profile: ', num2str(bin_width),' sec'];...
      ['datname: ', num2str(datname)]},'Interpreter', 'none')
subplot(subplotsizerow, subplotsizecolumn,2)
title({['power spectrum of the rate profile, channel ', num2str(selected_mea(1))];...
      ['frequency resolution: ',num2str(freq_res(1)),' Hz, red curve is a moving average']},'Interpreter', 'none')
%power_lims=get(rate_fft_sub(:,2),'ylim');
%if CH_NR ~= 1
%max_power_lim=max([power_lims{:,1}]);
%else
%    max_power_lim=max(power_lims);
%end
%set(rate_fft_sub(:,2),'ylim',[0 max_power_lim]);
     


%this would be for the control dataset;     
ma_ps_control{1,1} = ma_ps;
ma_ps_control{1,2} = nr_freq;
ma_ps_control{1,3} = freq_res;
control_length     = (recording_end-recording_begin)/3600;




%this is the stim dataset
ma_ps_stim{1,1} = ma_ps;
ma_ps_stim{1,2} = nr_freq;
ma_ps_stim{1,3} = freq_res;
stim_length     = (recording_end-recording_begin)/3600;


figure;
bandwidth_freqs = [0.003 0.006 0.008 0.01  0.015 0.025 0.05];
nr_bw_freqs    = length(bandwidth_freqs);
for CH_NR=1:length(selected_mea)
    control_res         = ma_ps_control{1,3}(CH_NR);
    control_nr_freq     = ma_ps_control{1,2}(CH_NR);
    stim_res            = ma_ps_stim{1,3}(CH_NR);
    stim_nr_freq        = ma_ps_stim{1,2}(CH_NR);
    %due to different recording lengths and therefore diff. freq
    %resolutions, the vactors have different lengths, consider that
    control_freqs = (0:control_nr_freq-1)*control_res;
    stim_freqs    = (0:stim_nr_freq-1)*stim_res;
    for jj=1:nr_bw_freqs
        control_bw_ind    = find(control_freqs<=bandwidth_freqs(jj));
        control_bw_ps(jj) = mean(ma_ps_control{1,1}{CH_NR}(control_bw_ind));
        
        stim_bw_ind    = find(stim_freqs<=bandwidth_freqs(jj));
        stim_bw_ps(jj) = mean(ma_ps_stim{1,1}{CH_NR}(stim_bw_ind));
    end
    
    %res_ratio        = stim_res/control_res;
    %freq_ind_control = round([1:stim_nr_freq]*res_ratio);
    %define the contrast between the two cases, i.e a function that varies
%betwern -1 and 1, where 0 stands for no net effect. contrast =
%(control-stim)/(control+stim)
% control_values         = ma_ps_control{1,1}{CH_NR}(freq_ind_control);
% stim_values            = ma_ps_stim{1,1}{CH_NR}(1:stim_nr_freq);
% ps_contrast{CH_NR}  = (control_values-stim_values)./(control_values+stim_values);
% ma_ps_contrast{CH_NR}=conv(triang_vec,ps_contrast{CH_NR});
% rm_indices=[1:length(triang_vec)/2-1 (length(ma_ps_contrast{CH_NR})-(length(triang_vec)/2-1)):length(ma_ps_contrast{CH_NR})];
% ma_ps_contrast{CH_NR}(rm_indices)=[];
%plot_freq_vec          = ((1:stim_nr_freq)-1)*stim_res;
%semilogx(plot_freq_vec,ma_ps_contrast{CH_NR});

ps_bw_contrast{CH_NR}=(control_bw_ps-stim_bw_ps)./(control_bw_ps+stim_bw_ps)
bw_freqs_plot=bandwidth_freqs-[bandwidth_freqs(1)/2 diff(bandwidth_freqs)/2];
semilogx(bw_freqs_plot,ps_bw_contrast{CH_NR})
%plot(freq_vec(freq_ind_bin_center),power_spec_bandfrq_ratio{ii});
channel_string{CH_NR,1}=['channel: ', num2str(selected_mea(CH_NR))];
hold all;
end
legend(channel_string);
line([0.0001 0.1],[0 0]);
title({['datname: ', num2str(datname)];['contrast in power (P_control-P_stim) / (P_control+P_stim)) in frequency bands'];...
      ['band limits are: ', num2str(bandwidth_freqs),' Hz'];...
       ['nyqvist frequency: ', num2str(nyqvist_freq),' Hz, control:', num2str(control_length),' hrs, stim: ', num2str(stim_length),'hr']},'Interpreter', 'none');
xlabel('frequency [Hz]');
ylabel('contrast');
xlim([ 0 2*nyqvist_freq]);










