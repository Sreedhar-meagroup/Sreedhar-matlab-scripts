function gfr_rstr_h = plt_gfrWithRaster(data)
% Still not perfect!

if ~isempty(data.StimTimes)
    stimTimes = data.StimTimes;
    stimSite  = data.Electrode_details.stim_electrode;
    recSite   = data.Electrode_details.rec_electrode;
    spks      = data.Spikes;
end

gfr_rstr_h = figure(); 


[counts,timeVec] = hist(spks.time,0:0.1:ceil(max(spks.time)));
fig1ha(1) = subplot(3,1,1); bar(timeVec,counts); box off; set(gca,'TickDir','Out');
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 100ms)');


fig1ha(2)  = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
% patch([stimTimes ;stimTimes], repmat([0;60],size(stimTimes)), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
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