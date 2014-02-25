function h = plt_respLength(sortedSil, respOfSortedSil, dt)

[binC,~] = hist(sortedSil,0:dt:ceil(sortedSil(end)));
groups = zeros(size(respOfSortedSil));
y = cumsum(binC);
for ii = 1:size(binC,2)-1
    groups(y(ii)+1 : y(ii+1)) = ii;
end
h = figure();
boxplot(respOfSortedSil,groups,'plotstyle','compact');
set(gca,'XTickMode','manual','XTickLabelMode','auto','XTick',0:1/dt:groups(end),'XtickLabel',0:1:ceil(sortedSil(end)));
xlabel('Pre-stimulus inactivity [s]','FontSize',14);
set(get(gca,'XLabel'),'Position',get(get(gca,'XLabel'),'Position') - [0, 5, 0]);
ylabel('Response length (#spikes)','FontSize',14);
set(gca,'FontSize',14);



    