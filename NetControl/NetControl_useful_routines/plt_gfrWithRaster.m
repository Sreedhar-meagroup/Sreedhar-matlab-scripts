function gfr_rstr_h = plt_gfrWithRaster(data)

%% HELP:
% gfr_rstr_h = plt_gfrWithRaster(data) plots the raster plot of the
% recording along with its global firing rate(gfr).
% Input args:
%     data: standard structure  (details to be entered later)  
% Output args: 
%     gfr_rstr_h: resulting figure handle

%% README:
% The plots are made in two flavours. Either stimulus responses or
% spontaneous data can be plotted. Each of them require slightly different
% input structures. They have two kinds of fields: critical and optional.
% The exception handling tree will check for critical fields and abort in
% case they are missing. The code should proceed without optional
% arguments though this wouldn't be the best practise. A benign warning
% shall be thrown in these cases.
% -------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b) MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service
% Pack 1) Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java
% HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------

% *** Under construction***


    stimulation   = 0;
    spontaneous   = 0;
    warnflag      = 0;
%% Getting data into appropriate variables and exception handling
try
    if isfield(data,'StimTimes')
        stimTimes     = data.StimTimes;
        stimSites      = data.Electrode_details.stim_electrodes;
        recSites      = data.Electrode_details.rec_electrodes;
        response_window = data.Responses.response_window; 
        stimulation   = 1;
    else
        mod_NB_onsets = data.NetworkBursts.NB_extrema(:,1);
        NB_ends       = data.NetworkBursts.NB_extrema(:,2);
        spontaneous   = 1;
    end
    
    spks      = data.Spikes;
    if isfield(data,'fileName')
       datRoot   = data.fileName;
    else
        datRoot  = 'Unknown';
        warnflag = 1;        
    end
    
    if isfield(data.NetworkBursts,'BurstDetector')
        BurstDetector = data.NetworkBursts.BurstDetector;
    else
        BurstDetector = 'Unspecified!';
        warnflag = 1;
    end
    
catch err
    try
        if ~exist('recSite','var')
            recSite = [];
        end
    catch
        rethrow(err);
    end
    if warnflag, disp('Warning :: Some optional fields are missing!!!'); end
end

gfr_rstr_h    = figure();
%% Global firing rate

make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end


binSize = 0.1;
[counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
smooth_gfr = smooth(counts/binSize,'lowess',35);
% fig1ha(1) = subplot(3,1,1); bar(timeVec,counts/binSize); box off;
% fig1ha(1) = subplot(3,1,1); plot(timeVec,counts/binSize,'k'); box off;
fig1ha(1) = subplot(3,1,1); plot(timeVec,smooth_gfr,'k','LineWidth',1); box off;
set(gca,'XTick',[]);
set(gca,'TickDir','Out');
axis tight; ylabel('Global firing rate [Hz]'); 
% title(['Global firing rate (bin= 0.5s), data: ', datRoot],'Interpreter','none');
%% Stimulation
if stimulation % Stim response raster
    fig1ha(2)  = subplot(3,1,2:3);
    linkaxes(fig1ha, 'x');
    hold on;
    joined_ch = [];
%     if ~isempty(stimTimes)
%         plot(stimTimes,cr2hw(stimSite)+1,'r.');
%     end

    for ii = 1:size(stimSites,2)
        switch ii
            case 1
                clr = 'r';
                joined_ch = strcat(joined_ch,'{\color{red}',num2str(cr2hw(stimSites(ii))+1),' }');
            case 2
                clr = 'g';
                joined_ch = strcat(joined_ch,'{\color{green}',num2str(cr2hw(stimSites(ii))+1),' }');
            case 3
                clr = 'c';
                joined_ch = strcat(joined_ch,'{\color{cyan}',num2str(cr2hw(stimSites(ii))+1),' }');
            case 4
                clr = 'k';
                joined_ch = strcat(joined_ch,'{\color{black}',num2str(cr2hw(stimSites(ii))+1),' }');
            case 5
                clr = 'm';
                joined_ch = strcat(joined_ch,'{\color{magenta}',num2str(cr2hw(stimSites(ii))+1),' }');
        end
    plot(stimTimes{ii},cr2hw(stimSites(ii))+1,[clr,'.']);

        for jj = 1:length(stimTimes{ii})
            Xcoords = [stimTimes{ii}(jj);stimTimes{ii}(jj);stimTimes{ii}(jj)+response_window;stimTimes{ii}(jj)+response_window];
            Ycoords = 61*[0;1;1;0];
            patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.2);
        end

    end

%     for ii = 1:length(stimTimes)
%         Xcoords = [stimTimes(ii);stimTimes(ii);stimTimes(ii)+0.5;stimTimes(ii)+0.5];
%         Ycoords = 61*[0;1;1;0];
%         patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.25);
%     end


    rasterplot_so(spks.time,spks.channel,'k-');
    try
        response.time = spks.time(spks.channel == cr2hw(recSites));
        response.channel = spks.channel(spks.channel == cr2hw(recSites));
        rasterplot_so(response.time,response.channel,'g-');
    catch
    end
    hold off;
    set(gca,'TickDir','Out');
    set(gca,'YMinorGrid','On');
    xlabel('Time (s)');
    ylabel('Channel');

%     set( get(fig1ha(1),'Title'), 'String', ...
%     sprintf('data: %s;  Stim. ch : Rec. ch = %d:%d (hw+1)',...
%     datRoot,joined_ch,cr2hw(recSites)+1),'FontWeight','Bold','Interpreter','None');

    set(get(fig1ha(1),'Title'), 'String', ...
    sprintf('Data: %s',datRoot),'FontWeight','Bold','Interpreter','None');
%     text(10,94,['Data: ',datRoot],'FontWeight','Bold','Interpreter','None', 'HorizontalAlignment','left');
    text(spks.time(end),95,['Stim. ch: ',joined_ch, ' || Rec. ch: ',num2str(cr2hw(recSites)+1)],'FontWeight','Bold','HorizontalAlignment','right');

%     title(['Stimulation: ',joined_ch, 'Recording: ', cr2hw(recSites)+1],'FontWeight', 'Bold');
% to be tested    
%     title(['Raster plot indicating stimulation:recording at channel [',num2str(stimSite),' : ',num2str(recSite), ...
%         ' (cr) / ',num2str(cr2hw(stimSite)+1),' : ',num2str(cr2hw(recSite)+1),' (hw^{+1}) ']);

    pan xon;
    zoom xon;



elseif spontaneous % Spontaneous raster with NBs
    fig1ha(2) = subplot(3,1,2:3);
    hold on;
%% since patch no longer works this way -- 09.05.2014@ssk
%     Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
%     Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
%     patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);
hold on;
for ii = 1:length(NB_ends)
    Xcoords = [mod_NB_onsets(ii);mod_NB_onsets(ii);NB_ends(ii);NB_ends(ii)];
    Ycoords = 61*[0;1;1;0];
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.15);
end

%     Detected = []; 
%     for ii=1:length(NB_ends) 
%         Detected = [ Detected mod_NB_onsets(ii) NB_ends(ii) NaN ]; 
%     end
%     plot(Detected, 61*ones(size(Detected)), 'r', 'linewidth', 4 );
    
%%    
    linkaxes(fig1ha, 'x');
    rasterplot_so(spks.time,spks.channel,'k-');
    hold off;
    set(gca,'TickDir','Out');
    set(gca,'YMinorGrid','On');
    xlabel('Time [s]');
    ylabel('Channel');
    pan xon;
    zoom xon;

    
set( get(fig1ha(1),'Title'), 'String', ...
sprintf('data: %s ||  Burst detector: %s ||  %d NBs detected',...
datRoot,BurstDetector,length(NB_ends)),'FontWeight','Bold','Interpreter','None');
    
else % otherwise
    disp('Error: Check the input data structure');
end