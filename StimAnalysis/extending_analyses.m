%% seeking the burst before


% spike train with the response window sliced out
inRespWindow_time = [];
inRespWindow_channels = [];
inRespWindow_idx = [];
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

%% No: of spikes in each channel in each Spontaneous network burst

ExtremaPerChPerNB = zeros(60,length(stimTimes{1}),2);
peakFRperChPerNB = zeros(60,length(stimTimes{1}));
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
            end
        end
        
     end
end
SBperCh_s = ExtremaPerChPerNB(:,:,2) - ExtremaPerChPerNB(:,:,1);

%% response length by time

resp_extrema = zeros(length(stimTimes{1}),2);
for ii = 1: length(stimTimes{1})
    response_idx = find(resp_slices{1}{ii}.channel == cr2hw(87));
    if ~isempty(response_idx)
        resp_extrema(ii,1) = resp_slices{1}{ii}.time(response_idx(1));
        resp_extrema(ii,2) = resp_slices{1}{ii}.time(response_idx(end));
    end
end
resp_length_s = resp_extrema(:,2) - resp_extrema(:,1);


%% As suspected no: of spikes per time 

SB_exhaustion_rate = nSpPerChPerNB./SBperCh_s;
response_exhaustion_rate = resp_length'./resp_length_s;
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
plot(SB_exhaustion_rate(45,:), response_exhaustion_rate,'.');
box off;

%% 5 most active channels
ch_virility = zeros(60,1);
for ii = 1:60
    ch_virility(ii) = length(find(spks_wo_resp.channel == ii-1));
end
[~,most_active_ch] = sort(ch_virility,'descend');

figure;
for ii = 1:6
    subplot(2,3,ii)
    plot(SB_exhaustion_rate(most_active_ch(ii+1),:), resp_length,'k.');
    box off;
end