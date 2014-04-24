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

% our channel 
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


%% looking back from a stim
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

%% 
% actual order

figure();
for jj = 1:nSessions
    trials_h(jj) = subplot(3,2,jj); hold on;
    for ii = session_vector(jj)+1:session_vector(jj+1)
    plot(preStim_burst{ii}-stimTimes(ii),(ii-session_vector(jj))*ones(size(preStim_burst{ii})),'.','MarkerSize',4);
    plot(postStimAtRecSite{ii}-stimTimes(ii),(ii-session_vector(jj))*ones(size(postStimAtRecSite{ii})),'r.','MarkerSize',4);
    end
    hold off;
    box off;
    axis tight;
    set(gca, 'TickDir','Out');
    if mod(jj,2)
        title(['Training:',num2str(jj-fix(jj/2))]);
    else
        title(['Testing:',num2str(jj-fix(jj/2))]);
    end
end
[ax1,h1]=suplabel('Time [s]');
[ax2,h2]=suplabel('Trials','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);



% figure(); hold on; 
% for ii = session_vector(1)+1:session_vector(2)
% plot(preStim_burst{ii}-stimTimes(ii),ii*ones(size(preStim_burst{ii})),'.','MarkerSize',3);
% plot(postStimAtRecSite{ii}-stimTimes(ii),ii*ones(size(postStimAtRecSite{ii})),'r.','MarkerSize',3);
% end
% axis tight;
% hold off;
% box off;
% xlabel('Time [s]', 'FontSize', 14);
% ylabel('Trials', 'FontSize', 14);
% set(gca,'TickDir','Out');
% set(gca,'FontSize',12);

%% effect of prev_burst
preStim_Blengths = cellfun(@length, preStim_burst);

figure();
for jj = 1:nSessions
    expected_resp = [];
    error_in_resp = [];
    subplot(3,2,jj); hold on;
    for ii = session_vector(jj)+1:session_vector(jj+1)
    expected_resp(ii-session_vector(jj)) = emodel_para(1)*(1-exp(-emodel_para(2)*silence_s(ii)));
    error_in_resp(ii-session_vector(jj)) = respLengths_n(ii) - expected_resp(ii-session_vector(jj));
    end
    plot(preStim_Blengths(session_vector(jj)+1:session_vector(jj+1)), error_in_resp, 'k.');
    hold off;
    box off;
    axis tight;
    set(gca, 'TickDir','Out');
    if mod(jj,2)
        title(['Training:',num2str(jj-fix(jj/2))]);
    else
        title(['Testing:',num2str(jj-fix(jj/2))]);
    end
end
[ax1,h1]=suplabel('Length of previous burst');
[ax2,h2]=suplabel('Error','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);
