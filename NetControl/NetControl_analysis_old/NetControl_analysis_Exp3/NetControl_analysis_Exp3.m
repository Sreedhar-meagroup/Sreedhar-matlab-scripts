function NetControlData = NetControl_analysis_Exp3(varargin)
% NOTE: This file can be used to analyze NetControl data in Experiments3,
% where the protocol of 1000 training episodes followed by 500 testing ones
% was followed. Training and testing sessions need to be in separate files.
if nargin
    pvpmod(varargin);
end

%% File selection
disp('This is Experiment 3');
[datName,pathName] = chooseDatFile('3','net','Choose training file');
try
    datRoot_train = datName(1:strfind(datName,'.')-1);
    spikes_train= loadspike_sk([pathName,datName],2,25);
catch
    spikes_train.time = [];
    spikes_train.channel = [];

    [datName,pathName] = chooseDatFile('3','net','Choose testing file');
    datRoot_test = datName(1:strfind(datName,'.')-1);
    spikes_test = loadspike_sk([pathName,datName],2,25);
end

try
    thresh  = extract_thresh([pathName, datName, '.desc']);
catch
    str = inputdlg('Enter the MEABench threshold');
    thresh = str2num(str{1}); 
end
dt = 0.25;

%% fusing training and testing data

data = fuse_sessions(spikes_train, spikes_test);

[PID, CID] = getCultureDetails(pathName);
electrode_details = extract_elec_details([pathName,'config_files\train.cls']);
session_no = getsession(pathName);
recSite = electrode_details.rec_electrode;
stimSite = electrode_details.stim_electrode;
recSite_in_hwpo = cr2hw(recSite)+1;
stimSite_in_hwpo = cr2hw(stimSite)+1;

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells

off_corr_contexts = offset_correction(data.Spikes.context); 
% comment these two lines out if you do not want offset correction 
spikes_oc = data.Spikes;
spikes_oc.context = off_corr_contexts; 
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
spks = blankArtifacts(spks,data.StimTimes,1);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end

%% Structure definition

NetControlData.Experiment = 3;
NetControlData.Session_number = session_no;
NetControlData.Culture_details.PID = PID;
NetControlData.Culture_details.CID = CID;
NetControlData.Culture_details.MEA = '';
NetControlData.Culture_details.MEAtype = '';
NetControlData.Culture_details.Age = '';

NetControlData.Spikes = spks;
NetControlData.Electrode_details = electrode_details;
NetControlData.StimTimes = data.StimTimes;
NetControlData.InAChannel = inAChannel;
NetControlData.dicretization = dt;

NetControlData.SessionInfo.nSessions = length(data.nStimuliInEachSession); 
NetControlData.SessionInfo.nStimuliInEachSession = data.nStimuliInEachSession;
NetControlData.SessionInfo.session_vector = data.session_vector;

NetControlData.burst_criterion = 200;


%% Shoring up the structure
% adds NetControlData.Silence_s and NetControlData.RespLengths_n
NetControlData = Exp3datahandling(NetControlData);

%% Spontaneous data
try
    [datName,pathName] = chooseDatFile('3','net',['Choose', CID,'_',session_no,' pre-spontaneous']);
    NetControlData.Pre_spontaneous = spontaneousData('datName',datName,'pathName',pathName);
catch
    NetControlData.Pre_spontaneous = [];
end


try
    [datName,pathName] = chooseDatFile('3','net',['Choose', CID,'_',session_no,' post-spontaneous']);
    NetControlData.Post_spontaneous = spontaneousData('datName',datName,'pathName',pathName);
catch
    NetControlData.Post_spontaneous = [];
end


%% Trimming the data to save
NetControlData = trimNetControlData(NetControlData);

% %% Figures
% %% plot1: response lengths(#spikes) vs stimNo
% rlvsn_h = figure();
% plot(respLengths_n,'.');
% %shadedErrorBar(1:length(respLengths_n),respLengths_n,std(respLengths_n)*ones(size(respLengths_n)),{'b','linewidth',0.5},0);
% hold on;
% plot(mean(respLengths_n)*ones(size(respLengths_n)),'r.', 'MarkerSize',3);
% box off
% % plot(mean(respLengths_n) + std(respLengths_n)*ones(size(respLengths_n)),'r-');
% % plot(mean(respLengths_n) - std(respLengths_n)*ones(size(respLengths_n)),'r-');
% %axis square; 
% %axis tight
% set(gca, 'FontSize', 14)
% set(gca,'TickDir','Out');
% xlabel('Stimulus number')
% ylabel('No: of spikes in response')
% % saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');
% 
% %title('Response during testing');
% 
% %% plot2: Pre-stimulus inactivity vs stim number
% [rl_n_sorted, rl_n_ind] = sort(respLengths_n);
% cmap = varycolor(max(respLengths_n)+1);
% silvssn_h = figure();
% scatter(rl_n_ind,silence_s(rl_n_ind),10,cmap(rl_n_sorted+1,:),'fill');
% box off;
% colormap(cmap);
% hcb = colorbar;
% set(gca, 'FontSize', 14);
% set(gca,'TickDir','Out');
% set(gca,'YGrid','On');
% xlabel('Stimulus number');
% ylabel('Pre-stimulus inactivity [s]');
% ylabel(hcb,'Response length (normalized)');
% axis tight;
% 
% % h2 = figure();
% % cmp = jet(max(respLengths_n));
% % scatter(silence_s,'.','markersize',5);
% % box off;
% %hold on;
% %plot(mean(silence_s)*ones(size(silence_s)),'r.', 'MarkerSize',3);
% % plot(mean(silence_s) + std(silence_s)*ones(size(silence_s)),'r-');
% % plot(mean(silence_s) - std(silence_s)*ones(size(silence_s)),'r-');
% %axis square; 
% %axis tight
% % set(gca, 'FontSize', 14);
% % xlabel('Stimulus number');
% % ylabel('Pre-stimulus inactivity [s]');
% %title('Response during testing');
% % saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');
% 
% %% plot3: Response lengths(#spikes) vs. pre-stimulus inactivities
% % Boxplot version of RL (#spikes) vs psi
% [sortedSil, silInd] = sort(silence_s);
%     respOfSortedSil_n = respLengths_n(silInd);
% if ~isempty(strfind(datName,'trai')) 
%     dt = 0.5
%     disp('Did you remember to set the right dt?');
%     bplot_h = plt_respLength(sortedSil,respOfSortedSil_n,dt,'nspikes');
% %     title('Response during testing');
% 
% % Comment out if you don't want the exponential model to be superimposed on
% % the box plot
% 
%     median_values = cell2mat(get(bplot_h(3,:),'YData'));
%     time = (1:length(median_values))*dt;
%     emodel_para = satexp_regression(time', median_values);
%     emodel = exp_model(time',emodel_para);
%     hold on;
%     plot(emodel,'r','LineWidth',2);
%     legend(['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
%     legend('boxoff');
%     boxplotn_h = gcf;
% 
% else
%     rlvssiln_h = figure();
%     plot(sortedSil, respOfSortedSil_n,'kx','LineWidth',2,'MarkerSize',8);
%     box off;
%     time = 0:0.01:sortedSil(end);
%     emodel_para = satexp_regression(sortedSil, respOfSortedSil_n);
%     emodel = exp_model(time,emodel_para);
%     hold on;
%     plot(time,emodel,'r','LineWidth',2);
%     legend('Exp',['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}']);
%     legend('boxoff');
% 
%     set(gca, 'FontSize', 14);
%     set(gca,'TickDir','Out');
%     xlabel('Pre-stimulus inactivity [s]');
%     ylabel('Response length (# spikes)');
%     title('Response during testing');
%     boxplotn_h = gcf;
% end
% 
% %% plot4: Response lengths(ms) vs. pre-stimulus inactivities
% % Boxplot version of RL (ms) vs psi
%   respOfSortedSil_ms = respLengths_ms(silInd);
%     
% if ~isempty(strfind(datName,'trai'))
%   boxplotms_h = plt_respLength(sortedSil,respOfSortedSil_ms,dt,'ms');
% 
% else
%     rlvssilms_h = figure();
%     [sortedSil, silInd] = sort(silence_s);
%     plot(sortedSil, respLengths_ms(silInd),'.','LineWidth',2);
%     box off;
%     set(gca, 'FontSize', 14);
%     set(gca,'TickDir','Out');
%     xlabel('Pre-stimulus inactivity [s]');
%     ylabel('Response length [ms]');
%     title('Response during testing');
% end
% 
% %% slice of a raster around a given stim number (manual -- very accurate)
% % dcm_obj = datacursormode(h2);
% % set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on');
% % figure(h2);
% % keyboard;
% % c_info = getCursorInfo(dcm_obj);
% % plotTimeSlice(spks,stimTimes(c_info.DataIndex)-10,stimTimes(c_info.DataIndex)+5,'nb',mod_NB_onsets,NB_ends,'resp');
% % hold on;
% % plot(stimTimes(c_info.DataIndex),0,'r^');
% % hold off;
% 
% %% slice of a raster around a given stim number (automatic -- less accurate)
% figure(silvssn_h);
% set(silvssn_h, 'WindowButtonDownFcn',{@Marker2Raster,spks,stimTimes,silence_s,mod_NB_onsets,NB_ends});
% 
% %% spontaneous data
% % spontaneousData();
% %% Saving figures
% % figPath = 'C:\Users\duarte\Desktop\progress_report1\figures\E5_323_4449\';
% % % figPath = 'D:\Codes\Lat_work\Closed_loop\NetControl_analysis\E3_317_4346_s1\figures\';
% % if ~isempty(strfind(datName,'trai'))
% %     session = '_training'
% % elseif ~isempty(strfind(datName,'test'))
% %     session = '_testing'
% % end
% % keyboard
% % 
% % saveas(silvssn_h,[figPath,'silvssn',session,'.eps'], 'psc2');
% % saveas(silvssn_h,[figPath,'silvssn',session], 'png');
% % 
% % saveas(boxplotn_h,[figPath,'resp',session], 'png');
% % saveas(boxplotn_h,[figPath,'resp',session,'.eps'], 'psc2');
% 
% 
% % saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');
% % saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');
% % saveas(h3,[figPath,'nSpvsSil',session,'.eps'], 'psc2');
% % saveas(h4,[figPath,'rlvsSil2',session,'.eps'], 'psc2');
% % export_fig('C:\Sreedhar\Lat_work\Brainlinks\NetControl_results...
% %\figures_317_4346_s1\rl_vs_sil','-eps','-transparent')
% 
% 
% 
% %% Collect log of number of stimuli in training and testing sessions
% % nStimuliInEachSession = str2num(strtrim(fileread([pathName,'statistics\log_num_stimuli.txt'])));
% % nSessions = size(nStimuliInEachSession,1);
% % totalStim = repmat([300;200],3,1);
% % 
% % figure(silvssn_h);
% % hold on;
% % for ii = 1:nSessions
% %     line([sum(nStimuliInEachSession(1:ii)),sum(nStimuliInEachSession(1:ii))],[0, max(silence_s)],'Color','k');
% % end
% %% 
% % figure();
% % session_vector = [1;cumsum(nStimuliInEachSession)];
% % dist_h = zeros(1,nSessions);
% % max_yval = 0;
% % for ii = 1:nSessions
% %     num = hist(respLengths_n(session_vector(ii):session_vector(ii+1)),0:max(respLengths_n));
% %     dist_h(ii) = subplot(3,2,ii);
% %     plot(0:max(respLengths_n),num/nStimuliInEachSession(ii),'k-','LineWidth',2);
% %     if mod(ii,2)
% %         title(['Training:',num2str(ii-fix(ii/2))]);
% %     else
% %         title(['Testing:',num2str(ii-fix(ii/2))]);
% %     end
% %     grid on;
% %     if max(num/nStimuliInEachSession(ii)) > max_yval
% %         max_yval = max(num/nStimuliInEachSession(ii));
% %     end
% % end
% % max_xval = max(respLengths_n);
% % linkaxes(dist_h);
% % xlim([0,max_xval]);
% % ylim([0,max_yval]);
% % [ax1,h1]=suplabel('Response length');
% % [ax2,h2]=suplabel('probability','y');
% % set(h1,'FontSize',12);
% % set(h2,'FontSize',12);
% 
% %% response length distribution (MEA meeting 2014)
% [counts_tr, indx_tr] = hist(rln.s1_4346.train);
% [counts_tst, indx_tst] = hist(rln.s1_4346.test);
% counts_tr2 = smooth(counts_tr/length(rln.s1_4346.train),'lowess'); 
% counts_tst2 = smooth(counts_tst/length(rln.s1_4346.test),'lowess');
% figure(); plot(indx_tr,counts_tr2/sum(counts_tr2),'k','LineWidth',3);
% hold on; 
% plot(indx_tst,counts_tst2/sum(counts_tst2),'r','LineWidth',3);
% set(gca,'FontSize',14)
% legend('boxoff')
% box off
% lh = legend('Training','Testing')
% set(lh,'FontSize',14);
% legend boxoff
% xlabel('Response length (#spikes)','FontSize',14)
% ylabel('Probability','FontSize',14)
% 
% 
% % [counts_st, indx_st] = hist(stimTimes,0:50:max(stimTimes));
% % counts_st = [1, counts_st];
% % tot_resp = [];
% % for  ii = 1:length(counts_st)-1
% %     tot_resp(ii) = mean(respLengths_n(counts_st(ii):counts_st(ii+1)));
% % end
% % figure();
% % plot(rln.s1_4346.temp.indx_st,smooth(rln.s1_4346.temp.tot_resp,'lowess'));
% % hold on;
% % plot(rln.s1_4346.temp2.indx_st,smooth(rln.s1_4346.temp2.tot_resp,'lowess'),'r');
% % 
