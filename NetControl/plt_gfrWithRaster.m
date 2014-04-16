function gfr_rstr_h = plt_gfrWithRaster(data)
% Still not perfect!
    stimulation   = 0;
    spontaneous   = 0;

if isfield(data,'StimTimes')
    stimTimes = data.StimTimes;
    stimSite  = data.Electrode_details.stim_electrode;
    recSite   = data.Electrode_details.rec_electrode;
    stimulation   = 1;
else
    mod_NB_onsets = data.NetworkBursts.NB_extrema(:,1);
    NB_ends = data.NetworkBursts.NB_extrema(:,2);
    spontaneous = 1;
end
spks      = data.Spikes;
datRoot   = data.fileName;
gfr_rstr_h = figure();

%% Global firing rate
binSize = 0.1;
[counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts); box off; 
set(gca,'TickDir','Out');
axis tight; ylabel('# spikes'); 
title(['Global firing rate (bin= 100ms), data: ', datRoot],'Interpreter','none');


if stimulation
%% Stim response raster

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
    xlabel('Time (s)');
    ylabel('Channel # (hw^{+1})');

    title(['Raster plot indicating stimulation:recording at channel [',num2str(stimSite),' : ',num2str(recSite), ...
        ' (cr) / ',num2str(cr2hw(stimSite)+1),' : ',num2str(cr2hw(recSite)+1),' (hw^{+1}) ']);

    zoom xon;
    pan xon;

elseif spontaneous
%% Spontaneous raster with NBs

    % % Fig 1a: global firing rate
    % %bin width = 100ms
    % [counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
    % gfr_rstr_h = figure('name', 'Spontaneous activity','NumberTitle','off');
    % handles(1) = gfr_rstr_h;
    % fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
    % axis tight; ylabel('# spikes');
    % title(['Global firing rate (bin= 100 ms)            data:',datRoot],'Interpreter','none');
    % set(gca,'TickDir','Out');

    % `Patch'ing the network event
    % figure(handles(1)); 
    fig1ha(2) = subplot(3,1,2:3)
    hold on;
    Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
    Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);

    % Fig 1b: General raster

    %  subplot(3,1,2:3);
    linkaxes(fig1ha, 'x');
    hold on;
    rasterplot_so(spks.time,spks.channel,'b-');
    hold off;
    set(gca,'TickDir','Out');
    set(gca,'YMinorGrid','On');
    xlabel('Time (s)');
    ylabel('Channel #');
    title(['Raster plot of spontaneous activity. ', num2str(length(NB_ends)), ' NBs']);
    zoom xon;
    pan xon;

else
    disp('Error: Check the input data structure');
end