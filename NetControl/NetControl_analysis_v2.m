% Aim: To analyze NetControl data in Experiments6 onwards, where the
% training and testing sessions were contiguous and recorded without interruption.

%% File selection and loading data
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(6,'net');
end
datRoot = datName(1:strfind(datName,'.')-1);
spikes  = loadspike([pathName,datName],2,25);
thresh  = extract_thresh([pathName, datName, '.desc']);


%% Stimulus times and location

stimTimes   = getStimTimes(spikes);
electrode_details = extract_elec_details([pathName,'config_files\train.cls']);

%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into inAChannel cells

spks = cleaning_routines(spikes, stimTimes, electrode_details, thresh);
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
[PID, CID] = getCultureDetails(pathName);

%% NetControlData structure
NetControlData.Culture_details.PID = PID;
NetControlData.Culture_details.CID = CID;
NetControlData.Culture_details.MEA = '';
NetControlData.Culture_details.MEAtype = '';
NetControlData.Culture_details.Age = '';

NetControlData.Spikes = spks;
NetControlData.Electrode_details = electrode_details;
NetControlData.StimTimes = stimTimes;

NetControlData.InAChannel = inAChannel;

%% Fig 1: global firing rate and raster

handles(1) = plt_gfrWithRaster(NetControlData);


% Continue from here



%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell structure.
% Layer 1 is a 60x1 cell, each corresponding to a channel
% Layer 2 is a nx1 cell, holding the periStim (-50 ms to +500 ms)spike stamps corresponding to each of the n stimuli.

% for the time being:
recSite = electrode_details.rec_electrode;
stimSite = electrode_details.stim_electrode;

periStim = cell(60,1);
for jj = 1: size(stimTimes,2)
    for kk = 1:60
        periStim{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes(jj)-0.05, inAChannel{kk}<stimTimes(jj)+0.5));
    end
end


%% Measuring pre-stimulus inactivity/periods of silence at the recording site
% silence_s has a matrix in a cell structure.
% Layer 1 (outer) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x50 matrix, each row corresponding to a channel and column
% corresponding to the 50 individual stimuli.

silence_s = zeros(size(stimTimes));
for jj = 1: size(stimTimes,2)
    previousTimeStamp = inAChannel{cr2hw(recSite)+1}(find(inAChannel{cr2hw(recSite)+1}<stimTimes(jj),1,'last'));
    if isempty(previousTimeStamp), previousTimeStamp = 0; end
    silence_s(jj) = (stimTimes(jj) - previousTimeStamp);
end

%% Response lengths (in no: of spikes)

periStimAtRecSite = periStim{cr2hw(recSite)+1};
respLengths_n = zeros(size(stimTimes));
for ii = 1: size(stimTimes,2)
    respLengths_n(ii) =  length(find(periStimAtRecSite{ii}>stimTimes(ii)));
end

%% Response lengths (in time)
respBurst = cell(size(stimTimes));
respLengths_ms = zeros(size(stimTimes));
for ii = 1:size(stimTimes,2)
    temp = periStimAtRecSite{ii};
    if isempty(temp), continue; end
    
    ISI = diff(temp);
    breach = find(ISI>=0.1,1,'first');
    if isempty(breach)
        respBurst{ii} = temp;
    else
        respBurst{ii} = temp(1:breach);
        if ISI(breach)<= 0.2
            respBurst{ii}(end+1) = temp(breach+1);
        end
    end
    respLengths_ms(ii) =  (respBurst{ii}(end) - stimTimes(ii))*1e3;
end
%% peristim long at recording site
periStimAtRecSite_long = periStim{cr2hw(recSite)+1};


%% Burst detection part

burst_detection = burstDetAllCh_sk(spks);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spks,burst_detection,10);
% harking back 50ms from the current NB onset definition and redefining onset boundaries.
mod_NB_onsets = zeros(length(NB_onsets),1);
for ii = 1:length(NB_onsets)
    if ~isempty(find(spks.time>NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2), 1))
        mod_NB_onsets(ii) = spks.time(find(spks.time >...
            NB_onsets(ii,2)-50e-3 & spks.time<NB_onsets(ii,2),1,'first'));
    else
        mod_NB_onsets(ii) = NB_onsets(ii,2);
    end
end
NB_slices = cell(length(mod_NB_onsets),1);
inNB_time =[];
inNB_channel =[];
for ii = 1: length(mod_NB_onsets)
    NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    inNB_time = [inNB_time, NB_slices{ii}.time];
    inNB_channel = [inNB_channel, NB_slices{ii}.channel];
end
[outNB_time, outIndices] = setdiff(spks.time, inNB_time);
outNB_channel = spks.channel(outIndices);

%% `Patch'ing the network events
% % green path stands for the network burst and the red one for the stim response window
% figure(handles(1)); subplot(3,1,2:3)
% hold on;
% %line([mod_NB_onsets' ; mod_NB_onsets'], repmat([0;60],size(mod_NB_onsets')),'Color',[0,0,0]+0.7,'LineWidth',0.1);
% Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
% Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
% patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.35);
% hold off;
%% spikes per channel per time
spksPerCHPerTime = length(spks.time)/(60*(max(spks.time) - min(spks.time)));
%% Figures
%% plot1: response lengths(#spikes) vs stimNo
rlvsn_h = figure();
plot(respLengths_n,'.');
%shadedErrorBar(1:length(respLengths_n),respLengths_n,std(respLengths_n)*ones(size(respLengths_n)),{'b','linewidth',0.5},0);
hold on;
plot(mean(respLengths_n)*ones(size(respLengths_n)),'r.', 'MarkerSize',3);
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

%title('Response during testing');

%% plot2: Pre-stimulus inactivity vs stim number
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
[sortedSil, silInd] = sort(silence_s);
    respOfSortedSil_n = respLengths_n(silInd);
if ~isempty(strfind(datName,'trai')) 
    dt = 0.5
    disp('Did you remember to set the right dt?');
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

%% plot4: Response lengths(ms) vs. pre-stimulus inactivities
% Boxplot version of RL (ms) vs psi
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
pre_spont = spontaneousData();
plt_IBIdist(pre_spont, dt, 'Network pre');
post_spont = spontaneousData('spon_after_testing.spike', pathName);
plt_IBIdist(pre_spont, dt, 'Network post');
%% Saving figures
% figPath = 'C:\Users\duarte\Desktop\progress_report1\figures\E5_323_4449\';
% % figPath = 'D:\Codes\Lat_work\Closed_loop\NetControl_analysis\E3_317_4346_s1\figures\';
% if ~isempty(strfind(datName,'trai'))
%     session = '_training'
% elseif ~isempty(strfind(datName,'test'))
%     session = '_testing'
% end
% keyboard
% 
% saveas(silvssn_h,[figPath,'silvssn',session,'.eps'], 'psc2');
% saveas(silvssn_h,[figPath,'silvssn',session], 'png');
% 
% saveas(boxplotn_h,[figPath,'resp',session], 'png');
% saveas(boxplotn_h,[figPath,'resp',session,'.eps'], 'psc2');


% saveas(h1,[figPath,'nSpvsStim',session,'.eps'], 'psc2');
% saveas(h2,[figPath,'SilvsStim',session,'.eps'], 'psc2');
% saveas(h3,[figPath,'nSpvsSil',session,'.eps'], 'psc2');
% saveas(h4,[figPath,'rlvsSil2',session,'.eps'], 'psc2');
% export_fig('C:\Sreedhar\Lat_work\Brainlinks\NetControl_results...
%\figures_317_4346_s1\rl_vs_sil','-eps','-transparent')



%% Collect log of number of stimuli in training and testing sessions
nStimuliInEachSession = str2num(strtrim(fileread([pathName,'statistics\log_num_stimuli.txt'])));
nSessions = size(nStimuliInEachSession,1);
totalStim = repmat([300;200],3,1);

figure(silvssn_h);
hold on;
for ii = 1:nSessions
    line([sum(nStimuliInEachSession(1:ii)),sum(nStimuliInEachSession(1:ii))],[0, max(silence_s)],'Color','k');
end
%% 
figure();
session_vector = [1;cumsum(nStimuliInEachSession)];
dist_h = zeros(1,nSessions);
max_yval = 0;
for ii = 1:nSessions
    num = hist(respLengths_n(session_vector(ii):session_vector(ii+1)),0:max(respLengths_n));
    dist_h(ii) = subplot(3,2,ii);
    plot(0:max(respLengths_n),num/nStimuliInEachSession(ii),'k-','LineWidth',2);
    if mod(ii,2)
        title(['Training:',num2str(ii-fix(ii/2))]);
    else
        title(['Testing:',num2str(ii-fix(ii/2))]);
    end
    grid on;
    if max(num/nStimuliInEachSession(ii)) > max_yval
        max_yval = max(num/nStimuliInEachSession(ii));
    end
end
max_xval = max(respLengths_n);
linkaxes(dist_h);
xlim([0,max_xval]);
ylim([0,max_yval]);
[ax1,h1]=suplabel('Response length');
[ax2,h2]=suplabel('probability','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);

