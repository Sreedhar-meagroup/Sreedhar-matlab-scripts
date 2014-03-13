%% fitting an expoinential to the NetControl data
figure()
plot(sortedSil(1:end-1), respOfSortedSil_n(1:end-1),'k','LineWidth',3);
set(gca, 'FontSize',16);
xlabel('Pre-stimulus inactivity [s]', 'FontSize',20);
ylabel('Response length (#spikes)', 'FontSize',20);
x = satexp_regression(sortedSil(1:end-1), respOfSortedSil_n(1:end-1));
y = exp_model(0:0.01:sortedSil(end-1),x);
hold on;
plot(0:0.01:sortedSil(end-1),y,'r','LineWidth',3);
ylim([0,7.1]);
box off;

