function emodel_para = getEmodelPara(NetControlData)
silence_s = NetControlData.Silence_s;
dt = NetControlData.discretization;
respLengths_n = NetControlData.RespLengths_n;

[sortedSil, silInd] = sort(silence_s);
respOfSortedSil_n = respLengths_n(silInd);
bplot_h = plt_respLength(sortedSil,respOfSortedSil_n,dt,'nspikes');
% set(gcf,'visible','off');
% Comment out if you don't want the exponential model to be superimposed on
% the box plot

median_values = cell2mat(get(bplot_h(3,:),'YData'));
time = (1:length(median_values))*dt;
emodel_para = satexp_regression(time', median_values);
% emodel = exp_model(time',emodel_para);

% hold on;
% plot(emodel,'r','LineWidth',2);
% legend(['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
% legend('boxoff');
% rlvssil_h = gcf;