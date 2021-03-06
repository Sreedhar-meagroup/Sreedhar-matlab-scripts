%% fitting an expoinential to the NetControl data: generic
figure;
plot(x, y,'k.','LineWidth',3);
set(gca, 'FontSize',16);
xlabel('Pre-stimulus inactivity [s]');
ylabel('Response length (#spikes)');
x_m = satexp_regression(x, y);
y_m = exp_model(0:0.01:max(x),x_m);
hold on;
plot(0:0.01:max(x), y_m,'r','LineWidth',3);
% ylim([0,7.1]);
box off;


%% adding a distribution to the training session response length plot
figure();
subplot(3,3,[1,2,4,5,7,8]);
plot(sortedSil(1:end-1), respOfSortedSil_n(1:end-1),'kx','LineWidth',2,'MarkerSize',8);
box off;
time = 0:0.01:sortedSil(end-1);
emodel_para = satexp_regression(sortedSil(1:end-1), respOfSortedSil_n(1:end-1));
emodel = exp_model(time,emodel_para);
hold on;
plot(time,emodel,'r','LineWidth',2);
% legend('Exp',['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
legend('boxoff');
set(gca, 'FontSize', 14);
set(gca,'TickDir','Out');
xlabel('Pre-stimulus inactivity [s]');
ylabel('Response length (# spikes)');
title('Response during testing');
set(gca,'YGrid','On');

subplot(3,3,[3,6,9])
learnedRespLengths = respLengths_n(find(and(silence_s>4.75,silence_s<5.25)));
num = hist(learnedRespLengths,0:max(learnedRespLengths));
plot(0:7,num/length(learnedRespLengths),'k.--','MarkerSize',10,'LineWidth',2);
axis tight;
box off;
set(gca,'Xdir','reverse');
set(gca,'XtickLabel',[]);
set(gca, 'FontSize', 14);
set(gca,'TickDir','Out');
set(gca,'XGrid','On');
ylabel('p');
view(90,90);
h = findobj(gca,'Type','Patch');
set(h,'FaceColor','k','EdgeColor','w');

%%
