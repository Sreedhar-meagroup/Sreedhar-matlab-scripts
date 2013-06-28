%A dataset that has many triggers in a feedback experiment can't be used
%with the previous mfiles. Therfore, this one analyses that kind of data that
%gives feedback on very low intervals. sometimes, with minimal inter
%stimulus intervals (e.g. 1 sec), there can be more that one trigger in one burst


bursting_channels_mea=[17 25 26 31 42 51 52 56 64 72 74 84];
bursting_channels      = cr2hw(bursting_channels_mea)+1;
no_bursting_ch         = length(bursting_channels);


%find the triggers
trig_ind    = find(ls.channel==60);
trig_times  = ls.time(trig_ind);
trig_num    = length(trig_times);

b_length_all   = cell(no_bursting_ch,1);
b_interval_all = cell(no_bursting_ch,1);
%calculate the burst length of all detected bursts on several channels
%and also calculate the burst intervals
%and calculate the percentage of spikes in bursts 
for b_ch=1:no_bursting_ch
    burst_ch=bursting_channels(b_ch);
    for b_ct=1:size([burst_detection{1,burst_ch}],1)-1
        b_length_all{b_ch}(b_ct)   = burst_detection{1,burst_ch}{b_ct,3}(end) - burst_detection{1,burst_ch}{b_ct,3}(1);
        b_interval_all{b_ch}(b_ct) = [burst_intervals_ch{1,b_ch}{b_ct,1}];
    end
    %find those 'intervals'that are actually blanking periods. easiest way to
    %check if the max burst interval is larger than e.g. 1hr (hardly a real
    %burst interval) and delete it or set it 0
    [max_val max_ind]=max(b_interval_all{b_ch});
    if (max_val > 3600)
        b_interval_all{b_ch}(max_ind) = NaN;
        b_length_all{b_ch}(max_ind)   = NaN;
    end
    
    
     spikes_in_bursts_percentage(b_ch) = sum([burst_detection{1,burst_ch}{:,2}])/length(find(ls.channel==bursting_channels(b_ch)-1));
end;

%make a moving average of the burst_length and the burst intervals
b_length_all_ma   = cell(no_bursting_ch,1);
b_interval_all_ma = cell(no_bursting_ch,1);
AVERAGE_EX=10;
for b_ch = 1:no_bursting_ch
    no_bursts=size([b_length_all{b_ch}],2);
    for b_ct=1:no_bursts
        if b_ct==1 | b_ct==no_bursts;
            b_length_all_ma{b_ch}(b_ct)   = b_length_all{b_ch}(b_ct);
            b_interval_all_ma{b_ch}(b_ct) = b_interval_all{b_ch}(b_ct);
        elseif b_ct < AVERAGE_EX +1
            b_length_all_ma{b_ch}(b_ct)   = (1/(2*b_ct-1))*(sum(b_length_all{b_ch}(1:b_ct)) + sum(b_length_all{b_ch}(b_ct+1:(2*b_ct-1))));
            b_interval_all_ma{b_ch}(b_ct) = (1/(2*b_ct-1))*(sum(b_interval_all{b_ch}(1:b_ct)) + sum(b_interval_all{b_ch}(b_ct+1:(2*b_ct-1))));
        elseif b_ct > no_bursts - (AVERAGE_EX+1)
            b_length_all_ma{b_ch}(b_ct)   = (1/(2*(no_bursts-b_ct)+1))*(sum(b_length_all{b_ch}(b_ct-(no_bursts-b_ct):b_ct)) + sum(b_length_all{b_ch}((b_ct+1):end)));
            b_interval_all_ma{b_ch}(b_ct) = (1/(2*(no_bursts-b_ct)+1))*(sum(b_interval_all{b_ch}(b_ct-(no_bursts-b_ct):b_ct)) + sum(b_interval_all{b_ch}((b_ct+1):end)));
        else
            b_length_all_ma{b_ch}(b_ct)   = (1/(2*AVERAGE_EX+1))*(sum(b_length_all{b_ch}((b_ct-AVERAGE_EX):(b_ct+AVERAGE_EX))));
            b_interval_all_ma{b_ch}(b_ct) = (1/(2*AVERAGE_EX+1))*(sum(b_interval_all{b_ch}((b_ct-AVERAGE_EX):(b_ct+AVERAGE_EX))));
        end
    end
    
end
        



%give two kinds of datasets, one with stimulation, one without:
load  19_01_07_400_fbonburst_fakestim.spike.mat datname bursting_channels bursting_channels_mea no_bursting_ch time_vec spikecount bin_width b_length_all b_length_all_ma spikes_in_bursts_percentage burst_onset b_interval_all b_interval_all_ma ;



%plot the results
for b_ch=1:no_bursting_ch;
    burst_ch=bursting_channels(b_ch);
    fig_handle(b_ch)  = figure;
    set(fig_handle(b_ch),'Position',[0 0 1600 1120]);
    sub_handle(b_ch,1)= subplot(3,2,1);
    %plot a rate profile first
    stairs(bin_vec,spikecount(burst_ch,:));
    rate_ticks       = ceil(max(spikecount(burst_ch,:))/4)
    y_ticks_rate     = 0:rate_ticks:max(spikecount(burst_ch,:))+rate_ticks;
    y_ticklabel_rate = y_ticks_rate./bin_width; 
    set(sub_handle(b_ch,1),'XLim', [0 max(bin_vec)],'YTick',y_ticks_rate,'YTickLabel',num2str(y_ticklabel_rate'),'XTick',xtick,'XTickLabel',xtick_label,'FontSize',12);
    title({[' dataset: ',num2str(datname)];['channel ',num2str(bursting_channels_mea(b_ch))];[' rate-profile ' ]},'FontSize',12, 'Interpreter' ,'none'); 
    xlabel('burst no. ', 'FontSize',12);
    ylabel( 'rate [Hz]', 'FontSize',12);
    
    
    sub_handle(b_ch,3)=subplot(3,2,3);
    bar(b_length_all{b_ch});
    hold on;
    plot(1:size([b_length_all_ma{b_ch}],2),b_length_all_ma{b_ch},'r','LineWidth',2);
    xlabel('burst no.','FontSize',12);
    ylabel('burst length [sec]','FontSize',12);
    title(['percentage of spikes in bursts: ',num2str(spikes_in_bursts_percentage(b_ch))], 'FontSize',12) 
    set(sub_handle(b_ch,3),'XLim',[0 size(b_length_all{b_ch},2)],'FontSize',12);
    
    
    sub_handle(b_ch,5)=subplot(3,2,5);
    bar(b_interval_all{b_ch});
    hold on;
    plot(1:size([b_interval_all_ma{b_ch}],2),b_interval_all_ma{b_ch},'r','LineWidth',2);
    xlabel('burst no.','FontSize',12);
    ylabel('Inter burst interval [sec]','FontSize',12);
    set(sub_handle(b_ch,5),'XLim',[0 size(b_interval_all{b_ch},2)],'FontSize',12);
    
    
    %set the xlabel in plot 1 according to the burst no as they appear
    %during recording
    clear x_tick_burst;
    clear x_tick_burst_to_time;
    x_tick_burst=[get(sub_handle(b_ch,3),'XTick')];
    x_tick_burst_to_time(1)=0;
    x_tick_burst_to_time(2:length(x_tick_burst))=[burst_onset{1,b_ch}{x_tick_burst(2:end),1}]';
    set(sub_handle(b_ch,1),'XTick',x_tick_burst_to_time,'XTicklabel',num2str(x_tick_burst'));
end

    %clear all;
    load 19_01_07_400_fbonburst.spike.mat datname bursting_channels bursting_channels_mea no_bursting_ch time_vec spikecount bin_width b_length_all b_length_all_ma spikes_in_bursts_percentage burst_onset b_interval_all b_interval_all_ma ;
for b_ch=1:no_bursting_ch;
    burst_ch=bursting_channels(b_ch);
    figure(fig_handle(b_ch));
    sub_handle(b_ch,2)= subplot(3,2,2);
    %plot a rate profile first
    stairs(time_vec,spikecount(burst_ch,:));
    %rate_ticks       = ceil(max(spikecount(burst_ch,:))/4)

    %y_lim_stim_max=y_lim_stim(end);
    set(sub_handle(b_ch,2),'XLim', [0 max(time_vec)],'YTick',get(sub_handle(b_ch,1),'YTick'), 'YTickLabel',num2str(get(sub_handle(b_ch,1),'YTickLabel')),'YLim' ,get(sub_handle(b_ch,1),'YLim'), 'FontSize',12);
    title({[' dataset: ',num2str(datname)];['channel ',num2str(bursting_channels_mea(b_ch))];[' rate-profile ' ]},'FontSize',12, 'Interpreter' ,'none'); 
    xlabel('burst no. ', 'FontSize',12);
    ylabel( 'rate [Hz]', 'FontSize',12);
    
    
    sub_handle(b_ch,4)=subplot(3,2,4);
    bar(b_length_all{b_ch});
    hold on;
    plot(1:size([b_length_all_ma{b_ch}],2),b_length_all_ma{b_ch},'r','LineWidth',2);
    xlabel('burst no.','FontSize',12);
    ylabel('burst length [sec]','FontSize',12);
    title(['percentage of spikes in bursts: ',num2str(spikes_in_bursts_percentage(b_ch))], 'FontSize',12) 
    set(sub_handle(b_ch,4),'XLim',[0 size(b_length_all{b_ch},2)],'FontSize',12);
    
    
    sub_handle(b_ch,6)=subplot(3,2,6);
    bar(b_interval_all{b_ch});
    hold on;
    plot(1:size([b_interval_all_ma{b_ch}],2),b_interval_all_ma{b_ch},'r','LineWidth',2);
    xlabel('burst no.','FontSize',12);
    ylabel('Inter burst interval [sec]','FontSize',12);
    set(sub_handle(b_ch,6),'XLim',[0 size(b_interval_all{b_ch},2)],'FontSize',12);
    
    
    %set the xlabel in plot 1 according to the burst no as they appear
    %during recording
    clear x_tick_burst;
    clear x_tick_burst_to_time;
    x_tick_burst=[get(sub_handle(b_ch,4),'XTick')];
    x_tick_burst_to_time(1)=0;
    x_tick_burst_to_time(2:length(x_tick_burst))=[burst_onset{1,b_ch}{x_tick_burst(2:end),1}]';
    set(sub_handle(b_ch,2),'XTick',x_tick_burst_to_time/bin_width,'XTicklabel',num2str(x_tick_burst'));
end
    
















