% The first part is mainly doing a simple raster plot for all channels. It
% can be choosen if the time scale is hrs (for long term recordings) or
% seconds. Accordingly, the data has to be imported with two additional
% parameters or not.
%
%
%%%
% 
% 
% % input:
% 
% datname:         the filename 
% 
% ls:             the usual structure with the spike information
% 
% raster_start    start time of raster plot, in hrs
% 
% 
% raster_end     end time of raster plot, in hrs
% 
% time_res       string that determines if x-axis is in sec or hrs
%                time_res = 'sec'
%                time_res = 'hrs'
% 
% 
% 
% 
% output: figure of the raster plot

function Fastraster(datname,ls,raster_start,raster_end,time_res)


spike_ind = find(ls.time>raster_start*3600 & ls.time<raster_end*3600);

% einfacher und schneller: Alle Spikes anschauen
raster_fig = screen_size_fig();


if time_res == 'sec'
    plot(ls.time(spike_ind),ls.channel(spike_ind),'or','markersize',2,'markerfacecolor','r');   %plot in hrs scale
    xlabel('time [sec]');
elseif time_res == 'hrs'
    plot(ls.time(spike_ind)/(3600),ls.channel(spike_ind),'or','markersize',2,'markerfacecolor','r');
    xlabel('time [hrs]');  %plot xaxis hrs scale
end

ylabel('(hw) channel number');
title({['dataset ',num2str(datname)];[];['raster plot for all channels' ]},'Interpreter','none');

ylim([-1 64]);




% hfig=figure
% selectedchannels_mea=[26 54 87 44];
% selectedchannels=cr2hw(selectedchannels_mea)
% for i=1:length(selectedchannels)
% selected_ind=find(ls.channel==selectedchannels(i));
% selected_times=ls.time(selected_ind);
% selected_ch=ls.channel(selected_ind);
% subplot(length(selectedchannels),1,i);
% p_handle(i)=plot(selected_times, ls.channel(selected_ind),'r+');
% %hold on
% end;
% ch_handle=get(hfig, 'Children');
% xlabel('time [hrs] ');
% ylabel('channel')
% %set(ch_handle, 'YTick',[1 2 3],'YTickLabel', [18 19 47]);
