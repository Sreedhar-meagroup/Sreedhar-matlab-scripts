function h = plt_respLength(sortedSil, respOfSortedSil, dt,varargin)

[binC,~] = hist(sortedSil,0:dt:ceil(sortedSil(end)));
groups = zeros(size(respOfSortedSil));
y = cumsum(binC);
for ii = 1:size(binC,2)-1
    groups(y(ii)+1 : y(ii+1)) = ii;
end
figure();
% toLabel = [groups(find(diff(groups'))), groups(end)];
h = boxplot(respOfSortedSil,groups,'plotstyle','compact');
set(gca,'XTickMode','manual','XTickLabelMode','auto','XTick',0:1/dt:groups(end),'XtickLabel',(0:1:ceil(sortedSil(end)))');
xlabel('Pre-stimulus inactivity [s]','FontSize',14);
set(get(gca,'XLabel'),'Position',get(get(gca,'XLabel'),'Position') - [0, 15, 0]);
if nargin > 3
    if strcmpi(varargin{1},'ms')
        ylabel('Response length [ms]','FontSize',14);
    end
else
    ylabel('Response length (#spikes)','FontSize',14);
end
box off;
set(gca,'FontSize',12);
set(gca,'TickDir','Out');