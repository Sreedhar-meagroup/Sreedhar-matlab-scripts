function gfr_rstr_h = plt_gfrWithRaster(data)

%% HELP:
% gfr_rstr_h = plt_gfrWithRaster(data) plots the raster plot of the
% recording along with its global firing rate(gfr).
% Input args:
%     data: struct (details to be entered later)  
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

%% Getting data into appropriate variables and exception handling
try
    if isfield(data,'StimTimes')
        stimTimes     = data.StimTimes;
        stimSite      = data.Electrode_details.stim_electrode;
        recSite       = data.Electrode_details.rec_electrode;
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
    if isfield(data,'BurstDetector')
        BurstDetector = data.BurstDetector;
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


binSize = 0.5;
[counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts/binSize); box off; 
set(gca,'XTick',[]);
set(gca,'TickDir','Out');
axis tight; ylabel('Global firing rate [Hz]'); 
% title(['Global firing rate (bin= 0.5s), data: ', datRoot],'Interpreter','none');

if stimulation % Stim response raster
    fig1ha(2)  = subplot(3,1,2:3);
    linkaxes(fig1ha, 'x');
    hold on;
    plot(stimTimes,cr2hw(stimSite)+1,'r.');

    % code for the tiny rectangle
    Xcoords = [stimTimes;stimTimes;stimTimes+0.5;stimTimes+0.5];
    Ycoords = 61*repmat([0;1;1;0],size(stimTimes));
    patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.35);

    rasterplot_so(spks.time,spks.channel,'b-');
    response.time = spks.time(spks.channel == cr2hw(recSite));
    response.channel = spks.channel(spks.channel == cr2hw(recSite));
    rasterplot_so(response.time,response.channel,'g-');
    hold off;
    set(gca,'TickDir','Out');
    set(gca,'YMinorGrid','On');
    xlabel('Time (s)');
    ylabel('Channel # (hw^{+1})');

    set( get(fig1ha(1),'Title'), 'String', ...
    sprintf('data: %s;  Stim. ch : Rec. ch = %d:%d (cr) OR %d:%d (hw+1)',...
    datRoot,stimSite,recSite,cr2hw(stimSite)+1,cr2hw(recSite)+1),'FontWeight','Bold');

% to be tested    
%     title(['Raster plot indicating stimulation:recording at channel [',num2str(stimSite),' : ',num2str(recSite), ...
%         ' (cr) / ',num2str(cr2hw(stimSite)+1),' : ',num2str(cr2hw(recSite)+1),' (hw^{+1}) ']);

    pan xon;
    zoom xon;



elseif spontaneous % Spontaneous raster with NBs
    fig1ha(2) = subplot(3,1,2:3);
    hold on;
    Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
    Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);

    linkaxes(fig1ha, 'x');
    hold on;
    rasterplot_so(spks.time,spks.channel,'b-');
    hold off;
    set(gca,'TickDir','Out');
    set(gca,'YMinorGrid','On');
    xlabel('Time [s]');
    ylabel('Channel #');
    pan xon;
    zoom xon;

    
set( get(fig1ha(1),'Title'), 'String', ...
sprintf('data: %s ||  Burst detector: %s ||  %d NBs detected',...
datRoot,BurstDetector,length(NB_ends)),'FontWeight','Bold');
    
else % otherwise
    disp('Error: Check the input data structure');
end