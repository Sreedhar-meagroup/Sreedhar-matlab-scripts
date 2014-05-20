% pre stim spont
% removing spikes in resp window
indtoTrim = [];
for ii = 1:length(stimTimes)
    indtoTrim = [indtoTrim, find(spks.time>=stimTimes(ii) & spks.time<stimTimes(ii)+0.5)];
end

% without stim response window

slim_spks.time = spks.time(setdiff((1:length(spks.time)),indtoTrim));
slim_spks.channel = spks.channel(setdiff((1:length(spks.time)),indtoTrim));

burst_det_cl = burstDetAllCh_sk(slim_spks,0.2,0.2,3);

% bursts in recording channel (biRC)
biRC_closedLoop .onsets.time = zeros(length(burst_det_cl {recSite_in_hwpo}),1);
biRC_closedLoop .onsets.idx  = zeros(length(burst_det_cl {recSite_in_hwpo}),1);

biRC_closedLoop .ends.time  = zeros(length(burst_det_cl {recSite_in_hwpo}),1);
biRC_closedLoop .ends.idx   = zeros(length(burst_det_cl {recSite_in_hwpo}),1);

biRC_closedLoop .indices = [];
for ii = 1:length(burst_det_cl {recSite_in_hwpo})
    biRC_closedLoop .onsets.time(ii) = burst_det_cl{recSite_in_hwpo}{ii,3}(1);
    biRC_closedLoop .ends.time(ii) = burst_det_cl{recSite_in_hwpo}{ii,3}(end);

    biRC_closedLoop .onsets.idx(ii) = burst_det_cl{recSite_in_hwpo}{ii,4}(1);
    biRC_closedLoop .ends.idx(ii) = burst_det_cl{recSite_in_hwpo}{ii,4}(end);
    
    biRC_closedLoop .indices = [biRC_closedLoop .indices; burst_det_cl{recSite_in_hwpo}{ii,4}(:)];
end


%% looking back from a stim (Burst preceding the stim)
recChanSpikes = inAChannel{recSite_in_hwpo};
preStim_burst = cell(size(stimTimes));

for ii = 1:length(stimTimes)
    burst_flag = 1;
    first_sp_ind = find(recChanSpikes<stimTimes(ii),1,'last');
    temp = recChanSpikes(first_sp_ind);
        while burst_flag & first_sp_ind>1
            if recChanSpikes(first_sp_ind) - recChanSpikes(first_sp_ind-1) <= 0.2
                temp = [recChanSpikes(first_sp_ind-1), temp];
                first_sp_ind = first_sp_ind - 1;
            else
                burst_flag = 0;
            end
        end
    preStim_burst{ii} = temp;    
end


%% Silence preceding the burst preceding the stim

prevburst_silence = zeros(length(stimTimes),1);
for ii = 1:length(stimTimes)
    first_sp_b4 = find(recChanSpikes<preStim_burst{ii}(1),1,'last');
    if isempty(first_sp_b4)
        prevburst_silence(ii) = NaN;
    else
        prevburst_silence(ii) = preStim_burst{ii}(1) - recChanSpikes(first_sp_b4);    
    end
end

%% raster actual order
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

trials_all_h = figure();
min_xval = -1;
for jj = 1:nSessions
    trials_h(jj) = subplot(nSessions/2,2,jj); hold on;
    for ii = session_vector(jj)+1:session_vector(jj+1)
        plot(preStim_burst{ii}-stimTimes(ii),(ii-session_vector(jj))*ones(size(preStim_burst{ii})),'.','MarkerSize',4);
        plot(postStimAtRecSite{ii}-stimTimes(ii),(ii-session_vector(jj))*ones(size(postStimAtRecSite{ii})),'r.','MarkerSize',4);
        temp = min(preStim_burst{ii}-stimTimes(ii));
        if jj <= nSessions-2, set(gca,'XTickLabel',[]);end
        if temp<min_xval, min_xval = temp; end 
    end
    hold off;
    box off;
%     axis tight;
    set(gca, 'TickDir','Out');
    if jj == 1 %mod(jj,2)
        title(['Training: 1 - ',num2str(nSessions/2)]);%,num2str(jj-fix(jj/2))]);
    elseif jj == 2
        title(['Testing: 1 - ',num2str(nSessions/2)]);
%         title(['Testing:',num2str(jj-fix(jj/2))]);
    end
end
[ax1,h1]=suplabel('Time [s]');
[ax2,h2]=suplabel('Trials','y');
linkaxes(trials_h,'x');
xlim([min_xval, 0.7]);
set(h1,'FontSize',12);
set(h2,'FontSize',12);

%% Error (actual-expected) of prev_burst
preStim_Blengths = cellfun(@length, preStim_burst);

errvslpb_h = figure();
    expected_resp = cell(1,nSessions);
    error_in_resp = cell(1,nSessions);
max_yval = 0;
min_yval = 0;
for jj = 1:nSessions
%     expected_resp{jj} = [];
%     error_in_resp{jj} = [];
    trials_h(jj) = subplot(nSessions/2,2,jj); hold on;
    for ii = session_vector(jj)+1:session_vector(jj+1)
        expected_resp{jj}(ii-session_vector(jj)) = emodel_para(1)*(1-exp(-emodel_para(2)*silence_s(ii)));
        error_in_resp{jj}(ii-session_vector(jj)) = respLengths_n(ii) - expected_resp{jj}(ii-session_vector(jj));
    end
    plot(preStim_Blengths(session_vector(jj)+1:session_vector(jj+1)), error_in_resp{jj}, 'k.');
    if jj <= nSessions-2, set(gca,'XTickLabel',[]);end
    if max(error_in_resp{jj})>max_yval
        max_yval = max(error_in_resp{jj});
    end
    if min(error_in_resp{jj})<min_yval
        min_yval = min(error_in_resp{jj});
    end
      
    hold off;
    box off;
%     axis tight;
    set(gca, 'TickDir','Out');
    set(gca, 'XScale','log');
    if jj == 1%mod(jj,2)
        title(['Training: 1 - ',num2str(nSessions/2)]);
%         title(['Training:',num2str(jj-fix(jj/2))]);
    elseif jj == 2
        title(['Testing: 1 - ',num2str(nSessions/2)])
%         title(['Testing:',num2str(jj-fix(jj/2))]);
    end
end
[ax1,h1]=suplabel('Length of previous burst');
[ax2,h2]=suplabel('Error=(Actual-expected) length','y');
linkaxes(trials_h);
xlim([1,max(preStim_Blengths)]);
ylim([min_yval,max_yval]);
set(h1,'FontSize',12);
set(h2,'FontSize',12);

%% Dependence on preburst_silence

% discrete_states = [0.2:0.5:8];
% % discrete_states = 1.7;
% var_orig = [];
% var_corr = [];
% for ii = 1:size(discrete_states,2)
%     indsInThisState{ii} = find(silence_s>discrete_states(ii)-0.1 & silence_s<discrete_states(ii)+0.1);
%     respLoriginal{ii} = respLengths_n(indsInThisState{ii});
%     respLcorrected{ii} = respLengths_n(indsInThisState{ii}) - ((median(prevburst_silence(indsInThisState{ii}))+std(prevburst_silence(indsInThisState{ii})))*(1- exp(-prevburst_silence(indsInThisState{ii}))));
%     var_orig(ii) = var(respLoriginal{ii});
%     var_corr(ii) = var(respLcorrected{ii});
% end

% figure();
% plot(discrete_states,var_orig,'k.-','Markersize',15,'LineWidth',2);
% box off
% xlabel('Discrete states','FontSize',14);
% ylabel('Variance in response lengths','FontSize',14);
% % plot(discrete_states,var_corr,'r.-','Markersize',15,'LineWidth',2);


%%
% figure; 
% plot(preStim_Blengths,respLengths_n,'.')
% box off
% xlabel('Pre-stimulus burst lengths','FontSize',14);
% ylabel('Response lengths','FontSize',14);
% 
% figure;
% plot(prevburst_silence,respLengths_n,'.')
% box off
% xlabel('Previous silence','FontSize',14);
% ylabel('Response lengths','FontSize',14);

