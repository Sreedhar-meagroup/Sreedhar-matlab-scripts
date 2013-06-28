%function plot_8x8_PSTH
% 
%If 8x8 PSTHs are calcualted on the server, here ist the function that
%plots it. Furthermore, the ditribution of the first spike delay was also
%calculated (also a return value from the fct PSTH_8X8). Here I can
%calculate the average delay and use this e.g as a sorting criteria for
%plotting, or for comparision with onsets in NBs, or corrleation with
%stim-site...
% 
% 
%
% INPUT:
% datname:            the name of the dataset
% 
%ch_psth              The cell array which stores the PSTHs for each channel. a return value from the function  
%                     MAKE_PSTH_8X8
% 
%
%ch_delay_first_spike The cell array of first-spike delay ditribution for each channel.      
%                     Note that it makes only sense to calculate an average
%                     delay when the channel has responde often enough.
% 
%
% nr_triggers         The nr of stimuli over which the PSTh was averaged
% 
% PRE_TRIG_TIME       The extend of the PSTh pre and post stimulus, in sec
% POST_TRIG_TIME
% 
%PSTH_BIN_WIDTH       the bin width of the PSTH
%
% 
%
%OUTPUT
%
%hsub                 A handle vector, with one entry for each subplot of
%t                    he 8X8 plot
%
%
% hsub =  plot_8X8_PSTH(datname,ch_psth,ch_delay_firts_spike,nr_triggers,PRE_TRIG_TIME,POST_TRIG_TIME,PSTH_BIN_WIDTH)
% 
% 
function hsub = plot_8X8_PSTH(datname,ch_psth,ch_delay_first_spike,nr_triggers,PRE_TRIG_TIME,POST_TRIG_TIME,PSTH_BIN_WIDTH)




TRIAL_TIME_VEC = -PRE_TRIG_TIME:PSTH_BIN_WIDTH:POST_TRIG_TIME-PSTH_BIN_WIDTH;
nr_ch          = 64;


%Calculate the average spike delay for the interesting channels and sort those delays.
%This should be given as an output on the screen (for information when
%plotting etc.)


%first find how often each channel has a response (consider that when doing
%this calculation a window was set to some msec, so there might be
%responses that don't fall in this window of interest)

%the chanenls should have responded in at least a fraction of the total
%trials
MINIMUM_RESPONSE_NR = nr_triggers/25;
%exclude the analog channels
%construct the right function handle
fct_handle = @(x) length(find(~isnan(x)));
all_ch_trial_length = cellfun(fct_handle,ch_delay_first_spike(1,:));
%find those chs that do respond often enough
many_trial_ch       = find(all_ch_trial_length>MINIMUM_RESPONSE_NR);

%via the cellfun function, calculate the average delay of the interesting
%channels
mean_delay_first_spike = cellfun(@nanmean,ch_delay_first_spike(1,many_trial_ch));

%sort the delays
[sorted_delays sort_ind] = sort(mean_delay_first_spike,2,'ascend');
%also sort the according channels, in MEA notation
sorted_channels = many_trial_ch(sort_ind);
sorted_channels = hw2cr(sorted_channels-1);

%So sorted_delays and sorted_channels are the vectors that store the
%extracted information



%There are some bins that should be removed due to artifacts etc. Which
%%bins and how many depends on the PSTH_BIN_width etc...
remove_length   = 6;  %How many MSEC after 0 should the bins be emptied
NR_bins_removed = ceil(remove_length/1000/PSTH_BIN_WIDTH);

%the first bin in a histogram generated with histc that comes after 0 (i.e.including all the values >=0 and <0+bin_width )is
first_remove_bin = PRE_TRIG_TIME/PSTH_BIN_WIDTH+1;

for ii=1:60  %only for the recording electrodes
    ch_psth{1,ii}(first_remove_bin:first_remove_bin+NR_bins_removed-1)=NaN;
end



PSTH_8x8_fig = screen_size_fig;
color_spec = get(gca,'Colororder');
rate_limits  = [16 32 64 128 256 512 1024 2048];  

for ii=1:nr_ch
    %find the rigt position
    [xposi,yposi]=hw2cr(ii-1);
    
    plotpos         = xposi+8*(yposi-1);
    hsub(ii)        = subplot(8,8,plotpos);
    plot_handle(ii) = plot(TRIAL_TIME_VEC,ch_psth{1,ii}/(PSTH_BIN_WIDTH*nr_triggers));
    xlim([-PRE_TRIG_TIME POST_TRIG_TIME]);
    ylimits = get(gca,'Ylim');
    max_ylim(ii) = ylimits(2);
    %determine the "activity"of the current electrode, for later color
    %coding
    firing_range_diff = rate_limits - max_ylim(ii);
    firing_range_ind  = find(firing_range_diff>0);
    %take the first positive value
    firing_range_ind  = firing_range_ind(1);
    color_limit_ch(ii)=firing_range_ind;
    rate_limit_ch(ii) = rate_limits(firing_range_ind);
    set(plot_handle(ii),'color',color_spec(firing_range_ind,:));
    set(hsub(ii),'Ylim',[0 rate_limit_ch(ii)])
    title(['channel: ', num2str(hw2cr(ii-1))]);
end


 %set(hsub(1:59),'Ylim',[0 max(max_ylim(1:59))])
 subplot(8,8,1)
 xlabel(' time r.t. trigger [sec]');
 ylabel('rate in trial [Hz]');
 title({['datname ',num2str(datname)];[' PSTH, averaged over ', num2str(nr_triggers),' trials'];...
        ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: 61']},'Interpreter', 'none');
  

    %Display the information about the delay of tehe first spike and the
    %channels
disp(' Note that the average delay of the first response-spike is distributed across the channels like: ' )
sorted_delays
disp(' The according channels are: ' );
sorted_channels   
    
    
    
disp('Now give some Channels that should be plotted enlarged \n');


nr_plots           = input('How many plots?')

selected_mea_input = cell(1,nr_plots);

for ii=1:nr_plots
selected_mea_input{ii} = input('Give channels (MEA-style, vector type) to show enlarged.\n ');
end


for jj = 1:nr_plots
    Sel_ch_PSTH_fig = screen_size_fig;
    
    ch_input_hw = cr2hw(selected_mea_input{jj})
    
    for kk = 1:length(ch_input_hw)
       
      subplot(length(ch_input_hw),1,kk)
      active_hw_ch = ch_input_hw(kk)+1;
      plot(TRIAL_TIME_VEC,ch_psth{1,active_hw_ch}/(PSTH_BIN_WIDTH*nr_triggers),'Color',color_spec(color_limit_ch(active_hw_ch),:));
      xlim([-PRE_TRIG_TIME POST_TRIG_TIME]);
      ylim([0 rate_limit_ch(active_hw_ch)]);
      xlabel(' time r.t. stimulus [sec]');
      ylabel('rate in trial [Hz]');
      title(['channel: ',num2str(selected_mea_input{jj}(kk))]);
    end     
    subplot(length(ch_input_hw),1,1)
     title({['datname: ', num2str(datname)];['PSTH, averaged over ', num2str(nr_triggers),' trials'];...
        ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: ',num2str(selected_mea_input{jj}(1))]},'Interpreter', 'none');
end
        
        
        
    
    
    
    