function rasterplot_sk(spikes)
spks = cleanspikes(spikes);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
%% Fig 1a: global firing rate
% sliding window; bin width = 1s
[counts,timeVec] = hist(spks.time,0:ceil(max(spks.time)));
figure(1); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Fig 1b: General raster
gfr_rstr_h = figure(1); 
handles(1) = gfr_rstr_h;
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
% for ii = 1:nStimSites
%     switch ii
%         case 1
%             clr = 'r';
%         case 2
%             clr = 'g';
%         case 3
%             clr = 'c';
%         case 4
%             clr = 'k';
%         case 5
%             clr = 'm';
%     end
% line([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})),'Color',clr,'LineWidth',0.1);
% patch([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})), 'r', 'EdgeAlpha', 0.2, 'FaceColor', 'none');
% plot(stimTimes{ii},cr2hw(stimSites(ii))+1,[clr,'*']);
% 
% % code for the tiny rectangle
% Xcoords = [stimTimes{ii};stimTimes{ii};stimTimes{ii}+0.5;stimTimes{ii}+0.5];
% Ycoords = 60*repmat([0;1;1;0],size(stimTimes{ii}));
% patch(Xcoords,Ycoords,'r','EdgeColor','none','FaceAlpha',0.2);
% end
for ii = 1:60 
    plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.','MarkerSize',5);
    %'ob','markersize',2,'markerfacecolor','b'
    axis tight;
end

hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot']);% indicating stimulation at channels [',num2str(cr2hw(stimSites)+1),'] (hw+1)']);
zoom xon;