function h = plt_respLength(sortedSil, respOfSortedSil, dt)

dt = 0.25;
[binC,binI] = hist(sortedSil,0:dt:ceil(sortedSil(end)));
respOfSortedSil = respLengths_n(silInd);
groups = zeros(size(respOfSortedSil));
y = cumsum(binC);

for ii = 1:size(binC,2)-1
    x(y(ii)+1 : y(ii+1)) = ii;
end

figure;
h = boxplot(respOfSortedSil,groups,'plotstyle','compact');
set(gca,'XTickMode','manual','XTickLabelMode','auto','XTick',0:1/dt:groups(end),'XtickLabel',0:1:ceil(sortedSil(end)));
xlabel('Pre-stimulus inactivity [s]','FontSize',14);
ylabel('Response length (#spikes)','FontSize',14);
set(gca,'FontSize',14);



    