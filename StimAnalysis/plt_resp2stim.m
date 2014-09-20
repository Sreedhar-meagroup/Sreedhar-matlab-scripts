function h = plt_resp2stim(stimNo, stim_data)
%This function plots the responses to stimuli at a given site arranged
%sequentially. The function is to go along with stimAnalysis_v3.m.
% INPUT ARGUMENTS: 
%     stimNo: (1-5), is the index of the stimulation site
%     stimEfficacy_data: a structure generated in the file
%     stimAnalysis_v3.m
% OUTPUT ARGUMENTS: 
%     h: figure handle of the resulting plot

spks = stim_data.Spikes;
stimTimes = stim_data.StimTimes;
stimSites = stim_data.Electrode_details.stim_electrodes;

stimResp.time = [];
stimResp.channel = [];
offset = 1; % 1s offsets
for ii = 1:size(stimTimes{stimNo},2)
    respSliceInd = find(and(spks.time>stimTimes{stimNo}(ii), spks.time<stimTimes{stimNo}(ii)+0.5));
    stimResp.time = [stimResp.time, spks.time(respSliceInd) - stimTimes{stimNo}(ii)+(ii-1)*offset];
    stimResp.channel = [stimResp.channel, spks.channel(respSliceInd)];
end

pseudoStimTimes = 0:offset:(size(stimTimes{stimNo},2)-1)*offset;

[counts,timeVec] = hist(stimResp.time,0:0.1:ceil(max(stimResp.time)));
h = figure();
fig2ha(1) = subplot(3,1,1); bar(timeVec,counts); box off;set(gca,'TickDir','Out');
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 0.1s)');

fig2ha(2) = subplot(3,1,2:3);
linkaxes(fig2ha, 'x');
set(gca,'TickDir','Out');
set(gca,'YMinorGrid','On');
hold on;

for ii = 1:length(pseudoStimTimes)
    Xcoords = [pseudoStimTimes(ii);pseudoStimTimes(ii);pseudoStimTimes(ii)+0.5;pseudoStimTimes(ii)+0.5];
    Ycoords = 61*[0;1;1;0];
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.2);
end

plot(pseudoStimTimes,cr2hw(stimSites(stimNo))+1,'r.');
rasterplot_so(stimResp.time,stimResp.channel,'b-');
title(['Responses due to stimulation at channel ', num2str(cr2hw(stimSites(stimNo))+1),'(hw+1)/',num2str(stimSites(stimNo)),'(cr) alone.']);
zoom xon;
pan xon;