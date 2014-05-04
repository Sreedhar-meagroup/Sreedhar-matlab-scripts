%% Figures
%% plot1: response lengths(#spikes) vs stimNo / rlvsstimno
rlvsstimno_h = figure();
plot(respLengths_n,'.');
box off
hold on;
plot(session_vector(2:end-1), max(respLengths_n)*ones(size(session_vector(2:end-1))),'r^');
set(gca, 'FontSize', 14)
set(gca,'TickDir','Out');
xlabel('Stimulus number')
ylabel('No: of spikes in response')


%% plot2: Pre-stimulus inactivity vs stim number / silvsstimno
[rl_n_sorted, rl_n_ind] = sort(respLengths_n);
cmap = varycolor(max(respLengths_n)+1);
silvsstimno_h = figure();
scatter(rl_n_ind,silence_s(rl_n_ind),10,cmap(rl_n_sorted+1,:),'fill');
box off;
colormap(cmap);
hcb = colorbar;
set(gca, 'FontSize', 14);
set(gca,'TickDir','Out');
set(gca,'YGrid','On');
xlabel('Stimulus number');
ylabel('Pre-stimulus inactivity [s]');
ylabel(hcb,'Response length (normalized)');
axis tight;


%% plot3: Response lengths(#spikes) vs. pre-stimulus inactivities
% Boxplot version of RL (#spikes) vs psi
[sortedSil, silInd] = sort(silence_s);
respOfSortedSil_n = respLengths_n(silInd);
bplot_h = plt_respLength(sortedSil,respOfSortedSil_n,dt,'nspikes');

% Comment out if you don't want the exponential model to be superimposed on
% the box plot

median_values = cell2mat(get(bplot_h(3,:),'YData'));
time = (1:length(median_values))*dt;
emodel_para = satexp_regression(time', median_values);
emodel = exp_model(time',emodel_para);

hold on;
plot(emodel,'r','LineWidth',2);
legend(['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
legend('boxoff');
rlvssil_h = gcf;


%% Collecting pre and post experiment spontaneous data
IBI_pre_h = plt_IBIdist(NetControlData.Pre_spontaneous.NetworkBursts.IBIs , dt, 'Network, pre');
IBI_post_h = plt_IBIdist(NetControlData.Post_spontaneous.NetworkBursts.IBIs , dt, 'Network, post');

%% slice of a raster around a given stim number (automatic -- less accurate)
figure(silvsstimno_h);
hold on;
for ii = 1:nSessions
    line([sum(nStimuliInEachSession(1:ii)),sum(nStimuliInEachSession(1:ii))],[0, max(silence_s)],'Color','k');
end
set(silvsstimno_h, 'WindowButtonDownFcn',{@Marker2Raster,spks,stimTimes,silence_s,mod_NB_onsets,NB_ends});
