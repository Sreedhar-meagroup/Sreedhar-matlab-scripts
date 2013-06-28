% this makes a high resolution rate plot (small binwidth) for a selected
% set of channels
%09/01/07
                
recording_end=ls.time(end);   % recording length in seconds;
recording_begin=ls.time(1);
recording_length=recording_end-recording_begin;
recording_length_hrs=recording_length/(60*60);
recording_beg_hrs=recording_begin/(60*60);
recording_end_hrs=recording_end/(60*60);



bin_width=5;
selected_channels_MEA=[13 23 65 66];
selected_channels=cr2hw(selected_channels_MEA);
no_channels=length(selected_channels);
    
totalbins=ceil(recording_length/bin_width);
spikecount=zeros(no_channels,totalbins);    %spikecount(CHANNEL, BIN NO) is the vector where to put in the counts 

for bin=1:totalbins;
    %bin
    all_find=find(ls.time < bin*bin_width+recording_begin & ls.time > (bin-1)*bin_width+recording_begin);  %this finds the indices for ALL channels that are in the current timewindow
    for ch_ind  = 1:no_channels;
        ch      = selected_channels(ch_ind);
        ch_find = find(ls.channel(all_find)==ch);
        spikecount(ch_ind,bin)=length(ch_find);
    end
end;


rate_limits = [4 8 16 32];  %rate in HZ [rubbish, partly_active, active, going crazy]
count_limits = rate_limits.*bin_width;  % since bin_width is given in seconds
color_spec=get(gca, 'Colororder');  %take from the gca the colororder to obtaina color table
time_vec=1:totalbins;
x_hrs_scale=floor(recording_length_hrs/15);
xtick=floor(recording_beg_hrs:x_hrs_scale:recording_end_hrs);
x_hrs=(xtick-floor(recording_beg_hrs)).*3600/bin_width;
x_hrs=floor(x_hrs);  %to get rounded values;


subplotsizecolumn=ceil(no_channels);
subplotsizerow=ceil(no_channels/subplotsizecolumn);
selectedfig=figure;

for ch_ind = 1:no_channels;
     ch                  = selected_channels(ch_ind);
     selectedhsub(ch_ind)= subplot(subplotsizecolumn, subplotsizerow,ch_ind);% a figure handle for every subplot
     max_count       = max(spikecount(ch_ind,:));
     rate_limit      = count_limits-max_count;
     take_limit      = find(rate_limit>0);
     take_limit_ind  = take_limit(1);  %take the first positive value, this will be the indes for the the ylimit in count_limits
     take_limit      = count_limits(take_limit_ind);
     y_ticks         = 0:take_limit/5:take_limit;
     y_tickslabel    =num2str(y_ticks'./bin_width);
     stairs(time_vec,spikecount(ch_ind,:),'Color',color_spec(take_limit_ind,:));
     set(selectedhsub(ch_ind),'XLim',[0 totalbins], 'YLim',[0 take_limit],'XColor',color_spec(take_limit_ind,:),'XTick',x_hrs,'XTickLabel',xtick, 'YColor',color_spec(take_limit_ind,:),'YTick',y_ticks,'YTickLabel',y_tickslabel,'FontSize',10)
     ylabel(['rate [Hz]'],'Fontsize', 10); 
     
    title(['channel ', num2str(hw2cr(selected_channels(ch_ind)))], 'FontSize',10)
end;
   subplot(subplotsizecolumn, subplotsizerow,1)
   title({['dataset: ',num2str(datname)];['bin width: ', num2str(bin_width),' sec'];[', channel ', num2str(hw2cr(selected_channels(1)))]}, 'FontSize',10,'Interpreter', 'none')
xlabel(['time [hrs]'],'FontSize',10);
    
     
     
     
     
     
     
     
     
     
     
     
     
     