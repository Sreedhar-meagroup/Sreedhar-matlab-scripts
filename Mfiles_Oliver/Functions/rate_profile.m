% this makes a rate plot over time to better see changes in activity
% %01/11/06
% %
% function rate_profile
% rate_profile(datname,ls,time_start,time_end,bin_width)  
% creates a 8x8 rate profile with the possibility to have interactive input
% to determine some channels and see their rate profiles more indetail
% (enlarged)
% 
% input:
% datname:          the file name
% 
% ls:               the usual structure with the spike information 
% 
% 
% time_start;       strat and end time (in hrs) whenthe rate shoukd be
%                   calculated
% 
% bin_width         bin width in sec 
% 
% 
% 
% 
% 


function rate_vec=rate_profile(datname,ls,time_start,time_end,bin_width)              

recording_begin    = time_start*3600;
recording_end      = time_end*3600;   


recording_length     = recording_end-recording_begin;
recording_length_hrs = recording_length/(60*60);
recording_beg_hrs    = recording_begin/(60*60);
recording_end_hrs    = recording_end/(60*60);


                
                
%A VERY NEW WAY OF CALCULATING THE RATE< MUCH EASIER & FASTER
%bin_width=5;
%bin_vec     = 0:bin_width:recording_end;
bin_vec     = recording_begin:bin_width:recording_end;
totalbins   = length(bin_vec);
spikecount  = zeros(64,totalbins);

for ch=0:63;
    ch
    ch_spikes           = find(ls.channel==ch & ls.time <recording_end &ls.time>recording_begin);
    ch_spikes           = ls.time(ch_spikes);   %this vec has all the spike times for the resp. channel
    spikecount(ch+1,:)  = hist(ch_spikes,bin_vec);
end;



subfig=figure;
rate_limits  = [16 32 64 128 256 512];  %rate in HZ [rubbish, partly_active, active, going crazy]
count_limits = rate_limits.*bin_width;  % since bin_width is given in seconds
color_spec=get(gca, 'Colororder');  %take from the gca the colororder to obtaina color table
x_hrs_scale   = floor(recording_length_hrs/5);
xtick_label   = floor(recording_beg_hrs:x_hrs_scale:recording_end_hrs);
xtick         = (xtick_label).*3600;
xtick         = floor(xtick);  %to get rounded values;

for ch=0:63;
    [xposi,yposi]= hw2cr(ch);
    plotpos      = xposi+8*(yposi-1);
    hsub(ch+1)   = subplot(8,8,plotpos);
     % use the stairs fct, is probably better than the normal plot command since it does not plot diagonal connection lines between values
     max_count       = max(spikecount(ch+1,:));
     rate_limit      = count_limits-max_count;
     take_limit      = find(rate_limit>0);
     take_limit_ind  = take_limit(1);  %take the first positive value, this will be the indes for the the ylimit in count_limits
     take_limit      = count_limits(take_limit_ind);
     %stairs(bin_vec,spikecount(ch+1,:),'Color',color_spec(take_limit_ind,:));
     stairs(bin_vec./3600,spikecount(ch+1,:)./bin_width,'Color',color_spec(take_limit_ind,:));
     %set(hsub(ch+1), 'XLim',[recording_begin recording_end],'YLim',[0 take_limit],'XColor',color_spec(take_limit_ind,:),'XTick',xtick,'XTickLabel',xtick_label, 'YColor',color_spec(take_limit_ind,:),'YTick',[0 take_limit],'YTickLabel',[0 rate_limits(take_limit_ind)]);
     set(hsub(ch+1), 'XLim',[recording_beg_hrs recording_end_hrs],'YLim',[0 take_limit/bin_width],'XColor',color_spec(take_limit_ind,:), 'YColor',color_spec(take_limit_ind,:))
     
    title([num2str(hw2cr(ch))]);
end;
subplot(8,8,1);
title({['rate profile for all channels, dataset: ',num2str(datname)];['binwidth = ', num2str(bin_width),' sec.'];['channel 11']},'Interpreter','none'); 
ylabel('rate [Hz]');
xlabel('time [hrs]');



disp('Now give some Channels that should be plotted enlarged \n');

nr_plots           = input('How many plots?')

selected_mea_input = cell(1,nr_plots);

for ii=1:nr_plots

selected_mea_input{ii} = input('Give channels (MEA-style, vector type) to show enlarged.\n ');
end



for ii=1:nr_plots
    selected_mea = selected_mea_input{ii};
    
    selectedchannels   = cr2hw(selected_mea);  %select channels based on Hardware specifications
    channelcount       = length(selectedchannels);
    subplotsizecolumn  = ceil(channelcount);
    subplotsizerow     = ceil(channelcount/subplotsizecolumn);
    selectedfig        = figure;

    %if I work with datasets that have cyclical stim, it is useful to indicate
    %the stim times. Do this by a bar on the x-axis during the stim time
    %assuming I plo in hrs timescale
    %stim_hrs     = [1.0556];
    %stim_hrs     = [stim_hrs;stim_hrs+1];

    for i=1:channelcount;
        ch              = selectedchannels(i);
        selectedhsub(i) = subplot(subplotsizecolumn, subplotsizerow,i);% a figure handle for every subplot
        max_count       = max(spikecount(ch+1,:));
         rate_limit     = count_limits-max_count;
         take_limit     = find(rate_limit>0);
         take_limit_ind = take_limit(1);  %take the first positive value, this will be the indes for the the ylimit in count_limits
         take_limit     = count_limits(take_limit_ind);
         stairs(bin_vec/3600,spikecount(ch+1,:)./bin_width,'Color',color_spec(take_limit_ind,:));
        % plot(bin_vec./3600,spikecount(ch+1,:)./bin_width,'Color',color_spec(take_limit_ind,:));
         %bar(bin_vec./3600,spikecount(ch+1,:)./bin_width);
         %line(stim_hrs,zeros(2,length(stim_hrs)),'Linewidth',3,'Color','b');
         %set(selectedhsub(i), 'XLim',[recording_begin recording_end],'YLim',[0 take_limit/bin_width],'XColor',color_spec(take_limit_ind,:),'YColor',color_spec(take_limit_ind,:));
         set(selectedhsub(i), 'XLim',[recording_beg_hrs recording_end_hrs],'YLim',[0 take_limit/bin_width],'XColor',color_spec(take_limit_ind,:), 'YColor',color_spec(take_limit_ind,:))
         set(selectedhsub(i), 'XLim',[recording_beg_hrs recording_end_hrs],'XColor',color_spec(take_limit_ind,:), 'YColor',color_spec(take_limit_ind,:))
         ylabel(['rate [Hz]'],'Fontsize', 10); 

        title(['channel ', num2str(hw2cr(selectedchannels(i)))], 'FontSize',10)
    end;
       subplot(subplotsizecolumn, subplotsizerow,1)
       title({['dataset: ',num2str(datname)];['bin width ' num2str(bin_width),' sec'];[' channel ', num2str(hw2cr(selectedchannels(1)))]}, 'FontSize',10,'Interpreter', 'none')
    xlabel(['time [hrs]'],'FontSize',10);

end


rate_vec = spikecount./bin_width;












     
     
     
     
     