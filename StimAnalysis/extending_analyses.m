%% seeking the burst before

recCh_cr     = 51;
close_stimCh = 52; %hw+1;
stimInd      = 1;
spks         = stim_data.Spikes;
stimTimes    = stim_data.StimTimes;
silence_s    = stim_data.Silence_s;
resp_slices  = stim_data.Responses.resp_slices;
resp_lengths = stim_data.Responses.resp_lengths;


% spike train with the response window sliced out
inRespWindow_time     = [];
inRespWindow_channels = [];
inRespWindow_idx      = [];

for ii = 1:length(stimTimes{1})
    inRespWindow_time = [inRespWindow_time, spks.time(spks.time>=stimTimes{1}(ii) & spks.time<=stimTimes{1}(ii)+0.5)];
    inRespWindow_channels = [inRespWindow_channels, spks.channel(spks.time>=stimTimes{1}(ii) & spks.time<=stimTimes{1}(ii)+0.5)];
    inRespWindow_idx = [inRespWindow_idx, find(spks.time>=stimTimes{1}(ii) & spks.time<=stimTimes{1}(ii)+0.5)];
end

all_idx = 1:length(spks.time);
reduced_idx = setdiff(all_idx, inRespWindow_idx);

spks_wo_resp.time = spks.time(reduced_idx);
spks_wo_resp.channel = spks.channel(reduced_idx);

NBursts_wo_resp = sreedhar_ISI_threshold(spks_wo_resp);
mod_NB_onsets = NBursts_wo_resp.NB_extrema(:,1);
NB_ends = NBursts_wo_resp.NB_extrema(:,2);
hold on;
for ii = 1:length(NB_ends)
    Xcoords = [mod_NB_onsets(ii);mod_NB_onsets(ii);NB_ends(ii);NB_ends(ii)];
    Ycoords = 61*[0;1;1;0];
    patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.2);
end


%% 5 most active channels
ch_virility = zeros(60,1);
for ii = 1:60
    ch_virility(ii) = length(find(spks_wo_resp.channel == ii-1));
end
[~,most_active_ch] = sort(ch_virility,'descend');


%% Response distribution
figure; subplot(3,3,[1 2 4 5 7 8]),plot(stim_data.Silence_s{1}(32,:),stim_data.Responses.resp_lengths{1}(32,:),'k.','MarkerSize',7), 
box off, set(gca,'FontSize',14,'TickDir','Out'); xlabel('Pre-stimulus inactivity [s]'), ylabel('Reponse strength'); 
[a,b] = hist(stim_data.Responses.resp_lengths{1}(32,:),0:16);
subplot(3,3,[3,6,9]), plot(a/sum(a),b,'k','LineWidth',2); 
box off, set(gca,'FontSize',14,'TickDir','Out','YTickLabel',[]); xlabel('p');
%% No: of spikes in each channel in each Spontaneous network burst

ExtremaPerChPerNB = zeros(60,length(stimTimes{stimInd}),2);
peakFRperChPerNB = zeros(60,length(stimTimes{stimInd}));
lastISI          = zeros(60,length(stimTimes{stimInd}));
prevSB_top6     = cell(6,1);
for ii = 1:length(stimTimes{1})
    closest_SB_idx = find(mod_NB_onsets < stimTimes{1}(ii),1,'last');
     for jj = 1:60
        nSpPerChPerNB(jj,ii) = length(find(NBursts_wo_resp.NB_slices{closest_SB_idx}.channel == jj-1));
        NBperCh_idx = find(NBursts_wo_resp.NB_slices{closest_SB_idx}.channel == jj-1);
        if ~isempty(NBperCh_idx)
            ExtremaPerChPerNB(jj,ii,1) = NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx(1));
            ExtremaPerChPerNB(jj,ii,2) = NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx(end));
            if length(NBperCh_idx)>1
                peakFRperChPerNB(jj,ii) = max(diff(NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx)).^-1);
                lastISI(jj,ii) = NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx(end)) - NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx(end-1));
                if any(most_active_ch(1:6)==jj)
                        prevSB_top6{find(most_active_ch(1:6)==jj)}{ii} =  NBursts_wo_resp.NB_slices{closest_SB_idx}.time(NBperCh_idx);
                end

            end
        end
     end
end
SBperCh_s = ExtremaPerChPerNB(:,:,2) - ExtremaPerChPerNB(:,:,1);

%% response length by time
% response at 32 
resp_extrema = zeros(length(stimTimes{stimInd}),2);
firstISI     = zeros(length(stimTimes{stimInd}),1);
recCh_response = cell(length(stimTimes{stimInd}),1);
for ii = 1: length(stimTimes{stimInd})
    response_idx = find(resp_slices{1}{ii}.channel == cr2hw(recCh_cr));
    if ~isempty(response_idx)
        resp_extrema(ii,1) = resp_slices{stimInd}{ii}.time(response_idx(1));
        resp_extrema(ii,2) = resp_slices{stimInd}{ii}.time(response_idx(end));
        recCh_response{ii} = resp_slices{stimInd}{ii}.time(response_idx);
        if length(response_idx)>1
            firstISI(ii) = resp_slices{1}{ii}.time(response_idx(2)); - resp_slices{1}{ii}.time(response_idx(1));
        end
    end
end
resp_length_s = resp_extrema(:,2) - resp_extrema(:,1);
resp_length_n = resp_lengths{stimInd}(cr2hw(recCh_cr)+1,:);




%% Analysis 1: resp length (n) as a function of no: of spikes in prev burst

fig1_h = figure();
for ii = 1:6
    subplot(2,3,ii)
    plot(nSpPerChPerNB(most_active_ch(ii+1),:), resp_length_n,'k.','MarkerSize',7);
    box off;
    set(gca,'tickDir','Out');
    title(['Ch: ',num2str(most_active_ch(ii))]);
end
[ax1,h1]=suplabel('# in previous SB');
[ax2,h2]=suplabel(['# response (Ch: ',num2str(cr2hw(recCh_cr)+1),')'],'y');
[ax4,h3]=suplabel(stim_data.fileName ,'t');
set(h1,'FontSize',14); set(h2,'FontSize',14);set(h3,'Interpreter','None');
pos = get(fig1_h, 'Position');
set(gcf, 'Position',[pos(1:2),650, 610]);

%% Analysis 2: resp length (n) as a function of length of prev burst

fig2_h = figure();
for ii = 1:6
    subplot(2,3,ii)
    plot(SBperCh_s(most_active_ch(ii+1),:), resp_length_n,'k.','MarkerSize',7);
    box off;
    set(gca,'tickDir','Out');
    title(['Ch: ',num2str(most_active_ch(ii))]);
end
[ax1,h1]=suplabel('Duration in previous SB [s]');
[ax2,h2]=suplabel(['# response (Ch: ',num2str(cr2hw(recCh_cr)+1),')'],'y');
[ax4,h3]=suplabel(stim_data.fileName ,'t');
set(h1,'FontSize',14); set(h2,'FontSize',14);set(h3,'Interpreter','None');
pos = get(fig2_h, 'Position');
set(fig2_h, 'Position',[pos(1:2),650, 610]);

%% Analysis 3: resp length (s) as a function of no: of spikes in prev burst

fig3_h = figure();
for ii = 1:6
    subplot(2,3,ii)
    plot(nSpPerChPerNB(most_active_ch(ii+1),:), resp_length_s,'k.','MarkerSize',7);
    box off;
    set(gca,'tickDir','Out');
    title(['Ch: ',num2str(most_active_ch(ii))]);
end
[ax1,h1]=suplabel('# in previous SB');
[ax2,h2]=suplabel(['Response length [s] (Ch: ',num2str(cr2hw(recCh_cr)+1),')'],'y');
[ax4,h3]=suplabel(stim_data.fileName ,'t');
set(h1,'FontSize',14); set(h2,'FontSize',14);set(h3,'Interpreter','None');
pos = get(fig3_h, 'Position');
set(fig3_h, 'Position',[pos(1:2),650, 610]);

%% Analysis 4: resp length (s) as a function of duration of prev burst

fig4_h = figure();
for ii = 1:6
    subplot(2,3,ii)
    plot(SBperCh_s(most_active_ch(ii+1),:), resp_length_s,'k.','MarkerSize',7);
    box off;
    set(gca,'tickDir','Out');
    title(['Ch: ',num2str(most_active_ch(ii))]);
end
[ax1,h1]=suplabel('Duration in previous SB [s]');
[ax2,h2]=suplabel(['Response length [s] (Ch: ',num2str(cr2hw(recCh_cr)+1),')'],'y');
[ax4,h3]=suplabel(stim_data.fileName ,'t');
set(h1,'FontSize',14); set(h2,'FontSize',14);set(h3,'Interpreter','None');
pos = get(fig4_h, 'Position');
set(fig4_h, 'Position',[pos(1:2),650, 610]);


%% Analysis 5: resp rate as a function of prev burst rate
prevSB_rate = nSpPerChPerNB./SBperCh_s;
response_rate = resp_length_n'./resp_length_s;
fig5_h = figure();
for ii = 1:6
    subplot(2,3,ii)
    plot(prevSB_rate(most_active_ch(ii+1),:), response_rate,'k.','MarkerSize',7);
    box off;
    set(gca,'tickDir','Out');
    title(['Ch: ',num2str(most_active_ch(ii))]);
end
[ax1,h1]=suplabel('Rate in previous SB [Hz]');
[ax2,h2]=suplabel(['Rate of Response [Hz] (Ch: ',num2str(cr2hw(recCh_cr)+1),')'],'y');
[ax4,h3]=suplabel(stim_data.fileName ,'t');
set(h1,'FontSize',14); set(h2,'FontSize',14);set(h3,'Interpreter','None');
pos = get(fig5_h, 'Position');
set(fig5_h, 'Position',[pos(1:2),650, 610]);

%% Analysis 6: overmean vs undermean of responses

data_in.spcounts = resp_length_n;
data_in.stimdetails.stimTimes = stimTimes;
data_in.stimdetails.stimInd = stimInd; 
temp = perimeananalysis(data_in,'3t','stim');
recCh_IF = temp.Indicatorfun;


%% Analysis 7: overmean vs undermean of prev global activity
data_in.spcounts = sum(nSpPerChPerNB);
data_in.stimdetails.stimTimes = stimTimes;
data_in.stimdetails.stimInd = stimInd; 
temp = perimeananalysis(data_in,'3t','spon');
prevSB_glob_IF = temp.Indicatorfun;


%% Analysis 8: overmean vs undermean of 1 ch in prev global activity
data_in.spcounts = nSpPerChPerNB(52,:);
data_in.stimdetails.stimTimes = stimTimes;
data_in.stimdetails.stimInd = stimInd; 
temp = perimeananalysis(data_in,'all');
prevSB_sCh_IF = temp.Indicatorfun;

%% Analysis 9:
data_in.spcounts = nSpPerSponNB;
data_in.stimdetails.stimTimes{1} = spon_data.NetworkBursts.NB_extrema(:,1);
data_in.stimdetails.stimInd = stimInd;
temp = perimeananalysis(data_in,'all');
sponSB_global_IF = temp.Indicatorfun;

%% response dynamics
figure; hold on; 
for ii = 1:length(stimTimes{stimInd})
    if length(recCh_response{ii})>1
        x = 1:length(recCh_response{ii});
        y = ii*ones(size(recCh_response{ii}));
        z = [0; smooth(diff(recCh_response{ii}).^-1,7,'lowess')];
        plot3(x,y,z,'r');
    end
end
view(3)
grid on;


figure; plot(stim_data.Silence_s{2}(51,:),stim_data.Responses.resp_lengths{2}(51,:),'.','MarkerSize',7);
box off;set(gca,'FontSize',14,'TickDir','Out');
xlabel('Pre-stimulus inactivity [s]'), ylabel('Reponse strength')

figure; plot(stim_data_4672.Silence_s{3}(32,:),stim_data_4672.Responses.resp_lengths{3}(32,:),'.','MarkerSize',7);
box off;set(gca,'FontSize',14,'TickDir','Out');
xlabel('Pre-stimulus inactivity [s]'), ylabel('Reponse strength')

figure; 
for ii = 1:6
   subplot(3,2,ii); hold on;
    for jj = 1:length(stimTimes{stimInd})
        if length(prevSB_top6{ii}{jj}) > 1
            x = 1:length(prevSB_top6{ii}{jj});
            y = jj*ones(size(prevSB_top6{ii}{jj}));
            z = [0; smooth(diff(prevSB_top6{ii}{jj}).^-1,7,'lowess')];
            plot3(x,y,z,'r');
        end
    end
    view(3)
    grid on;   
end


























%% Look at entire response


%% As suspected no: of spikes per time 
SB_exhaustion_rate = nSpPerChPerNB./SBperCh_s;
response_exhaustion_rate = resp_length_n'./resp_length_s;
% response_exhaustion_rate(isnan(response_exhaustion_rate)) = 0;

% tokickout = isnan(response_exhaustion_rate);
% x_axis = SB_exhaustion_rate(45,~tokickout);
% y_axis = response_exhaustion_rate(~tokickout);
% p = polyfit(x_axis, y_axis',1);
% pred = p(1)*x_axis + p(2);
% yresid = y_axis' - pred;
% SSresid = sum(yresid.^2);
% SStotal = (length(y_axis)-1) * var(y_axis);
% rsq = 1 - SSresid/SStotal;
% figure()
% plot(x_axis,y_axis,'.','MarkerSize',15)
% hold on
% plot(x_axis,pred,'r','LineWidth',2);
% text(40,0.1,['R^2 = ',sprintf('%0.2f',rsq)],'FontSize',12,'FontWeight','Bold');
% box off;
% set(gca,'FontSize',14)
% set(gca, 'TickDir','Out')
% xlabel('SB exhaustion at 45 ');
% ylabel('Response exhaustion');


figure;
for ii = 1:6
    subplot(2,3,ii)
    plot(SB_exhaustion_rate(most_active_ch(ii+1),:), response_exhaustion_rate,'k.');
    box off;
    title(num2str(most_active_ch(ii)));
end