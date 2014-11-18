function Exp3_figures(NetControlData,plotID)


silence_s  = NetControlData.Silence_s ;
respLengths_n = NetControlData.RespLengths_n;

%% Figures
if strcmpi(plotID,'all') || strcmpi(plotID,'1')
%% plot1: response lengths(#spikes) vs stimNo
rlvsn_h = figure();
plot(respLengths_n,'.');
%shadedErrorBar(1:length(respLengths_n),respLengths_n,std(respLengths_n)*ones(size(respLengths_n)),{'b','linewidth',0.5},0);
% hold on;
% plot(mean(respLengths_n)*ones(size(respLengths_n)),'r.', 'MarkerSize',3);
box off
% plot(mean(respLengths_n) + std(respLengths_n)*ones(size(respLengths_n)),'r-');
% plot(mean(respLengths_n) - std(respLengths_n)*ones(size(respLengths_n)),'r-');
%axis square; 
%axis tight
set(gca, 'FontSize', 14)
set(gca,'TickDir','Out');
xlabel('Stimulus number')
ylabel('No: of spikes in response')
% saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');
end
%title('Response during testing');

%% plot2: Pre-stimulus inactivity vs stim number
if strcmpi(plotID,'all') || strcmpi(plotID,'2')
[rl_n_sorted, rl_n_ind] = sort(respLengths_n);
cmap = varycolor(max(respLengths_n)+1);
silvssn_h = figure();
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
end
% h2 = figure();
% cmp = jet(max(respLengths_n));
% scatter(silence_s,'.','markersize',5);
% box off;
%hold on;
%plot(mean(silence_s)*ones(size(silence_s)),'r.', 'MarkerSize',3);
% plot(mean(silence_s) + std(silence_s)*ones(size(silence_s)),'r-');
% plot(mean(silence_s) - std(silence_s)*ones(size(silence_s)),'r-');
%axis square; 
%axis tight
% set(gca, 'FontSize', 14);
% xlabel('Stimulus number');
% ylabel('Pre-stimulus inactivity [s]');
%title('Response during testing');
% saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');

%% plot3: Response lengths(#spikes) vs. pre-stimulus inactivities
% Boxplot version of RL (#spikes) vs psi
if strcmpi(plotID,'all') || strcmpi(plotID,'3')

[sortedSil, silInd] = sort(silence_s);
    respOfSortedSil_n = respLengths_n(silInd);
if ~isempty(strfind(datName,'trai')) 
    dt = NetControlData.dicretization;
    bplot_h = plt_respLength(sortedSil,respOfSortedSil_n,dt,'nspikes');
%     title('Response during testing');

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
    boxplotn_h = gcf;

else
    rlvssiln_h = figure();
    plot(sortedSil, respOfSortedSil_n,'kx','LineWidth',2,'MarkerSize',8);
    box off;
    time = 0:0.01:sortedSil(end);
    emodel_para = satexp_regression(sortedSil, respOfSortedSil_n);
    emodel = exp_model(time,emodel_para);
    hold on;
    plot(time,emodel,'r','LineWidth',2);
    legend('Exp',['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
    legend('boxoff');

    set(gca, 'FontSize', 14);
    set(gca,'TickDir','Out');
    xlabel('Pre-stimulus inactivity [s]');
    ylabel('Response length (# spikes)');
    title('Response during testing');
    boxplotn_h = gcf;
end

end
%% plot4: Response lengths(ms) vs. pre-stimulus inactivities
% Boxplot version of RL (ms) vs psi

if strcmpi(plotID,'all') || strcmpi(plotID,'4')
    
respOfSortedSil_ms = respLengths_ms(silInd);
    
if ~isempty(strfind(datName,'trai'))
  boxplotms_h = plt_respLength(sortedSil,respOfSortedSil_ms,dt,'ms');

else
    rlvssilms_h = figure();
    [sortedSil, silInd] = sort(silence_s);
    plot(sortedSil, respLengths_ms(silInd),'.','LineWidth',2);
    box off;
    set(gca, 'FontSize', 14);
    set(gca,'TickDir','Out');
    xlabel('Pre-stimulus inactivity [s]');
    ylabel('Response length [ms]');
    title('Response during testing');
end
end

%% slice of a raster around a given stim number (manual -- very accurate)
% dcm_obj = datacursormode(h2);
% set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on');
% figure(h2);
% keyboard;
% c_info = getCursorInfo(dcm_obj);
% plotTimeSlice(spks,stimTimes(c_info.DataIndex)-10,stimTimes(c_info.DataIndex)+5,'nb',mod_NB_onsets,NB_ends,'resp');
% hold on;
% plot(stimTimes(c_info.DataIndex),0,'r^');
% hold off;

%% slice of a raster around a given stim number (automatic -- less accurate)
figure(silvssn_h);
set(silvssn_h, 'WindowButtonDownFcn',{@Marker2Raster,spks,stimTimes,silence_s,mod_NB_onsets,NB_ends});

%% spontaneous data
% spontaneousData();

%% Collect log of number of stimuli in training and testing sessions
nSessions = size(nStimuliInEachSession,1);
totalStim = repmat([500;200],3,1);
session_vector = [0;cumsum(nStimuliInEachSession)]; % they are boundaries
figure(silvssn_h);
hold on;
for ii = 1:nSessions
    line([sum(nStimuliInEachSession(1:ii)),sum(nStimuliInEachSession(1:ii))],[0, max(silence_s)],'Color','k');
end