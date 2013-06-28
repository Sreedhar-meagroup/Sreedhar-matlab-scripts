%function; Plot_Superburst_raster(ls,Superburst)
%This function plits the rasters for the detected Superburst periods, as
% %stored in the array Superburst
% 
% 
% %Input: 
% datname,ls;             The fiel name and the structure with spike information
% 
% Superburst:             The cell-matrix with the information for each Superburst in rows, and the subburst in columns
% 
%
%OUTPUT:                   A ratser figure, a subplot for each superburst
% 
% 
% 
% 
function Plot_superburst_raster(datname,ls,Superburst);

NR_superburst = size(Superburst,1);

Super_sub_raster               = screen_size_fig();
[plot_pos subplot_r subplot_c] = get_subplot_position(NR_superburst);

for ii = 1:NR_superburst
    nr_subburst(ii) = sum(cellfun(@(x) ~isempty(x), Superburst(ii,:)));
    super_start     = Superburst{ii,1}(1);
    super_end       = Superburst{ii,nr_subburst(ii)}(2);
    sequence_ind    = find(ls.time>super_start & ls.time<super_end);
    subplot(subplot_r, subplot_c,plot_pos(ii));
    plot(ls.time(sequence_ind),ls.channel(sequence_ind),'ok','markersize',2, 'markerfacecolor','k');
    hold on
    %with cellfun, it is easy to extract the stored values
    onset_times  = cellfun(@(x) x(1),Superburst(ii,1:nr_subburst(ii)));
    offset_times = cellfun(@(x) x(2),Superburst(ii,1:nr_subburst(ii)));
    %plot also the marker lines
    Onset_line  = line([onset_times; onset_times],[0*ones(1,length(onset_times)); 60*(ones(1,length(onset_times)))]);
    Offset_line = line([offset_times; offset_times],[0*ones(1,length(offset_times)); 60*(ones(1,length(offset_times)))]);
    set(Onset_line,'color','r','Linewidth',2);
    set(Offset_line,'color','b','Linewidth',2);
    xlim([super_start-3 super_end+2])
    xlabel('time [sec]');
    ylabel('channel');
    title(['Superburst nr. ',num2str(ii)]);
    
end
     subplot(subplot_r, subplot_c,1);
     title({[' datname: ',num2str(datname),' Extracted Superburst periods'];...
         ['red and blue line mark subburst on- and offset'];['Superburst nr. 1']},'Interpreter',' none')