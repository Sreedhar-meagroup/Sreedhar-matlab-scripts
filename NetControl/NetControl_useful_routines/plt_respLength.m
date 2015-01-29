function h = plt_respLength(sortedSil, respOfSortedSil, dt,varargin)
% This function plots the reponse lengths as a function of pre-stimulus
% inactivity in a box plot.
% INPUT ARGS:
%     sortedSil: vector of pre-stimulus inactivities, sorted in increasing order
%     respOfSortedSil: vector of responses, each corresponding to the stimului in sortedSil
%     dt: the state discretization of the silence
%     varargin: 'ms','nspikes' -- the box plot will be labelled accordingly

[binC,~] = hist(sortedSil,0:dt:ceil(sortedSil(end)));
groups = zeros(size(respOfSortedSil));
y = cumsum(binC);
for ii = 1:size(binC,2)-1
    groups(y(ii)+1 : y(ii+1)) = ii;
end
figure();
% toLabel = [groups(find(diff(groups'))), groups(end)];
h = boxplot(respOfSortedSil,groups,'labels',(0:dt:ceil(sortedSil(end))),...
    'plotstyle','compact','labelorientation','horizontal',...
    'colors',[.5,.5,.5]);


% h2 = findobj(gca,'Tag','Box');
% for jj=1:length(h)
% patch(get(h2(jj),'XData'),get(h2(jj),'YData'),'k','FaceAlpha',.4);
% end 
% set(gca,'XTickLabelMode','auto','XTick',0:1/dt:groups(end),'XtickLabel',(0:1:ceil(sortedSil(end)))');
xlabel('Pre-stimulus inactivity [s]','FontSize',14);
% set(get(gca,'XLabel'),'Position',get(get(gca,'XLabel'),'Position') - [0, 15, 0]);

if nargin > 3
    if strcmpi(varargin{1},'ms')
        ylabel('Response length [ms]','FontSize',14);
    elseif strcmpi(varargin{1},'nspikes')
        ylabel('Response length (#spikes)','FontSize',14);
    end
end
box off;
set(gca,'FontSize',12);
set(gca,'TickDir','Out');