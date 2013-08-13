%Network bursts: a closer look
[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\StimRecSite\StimPolicy2';
end

[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);spikes=loadspike(datName,2,25);
datRoot = datName(1:strfind(datName,'.')-1);
spks = cleanspikes(spikes); % Work on this later
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
%% Burst detection part
burst_detection = burstDetAllCh_sk(spikes);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spikes,burst_detection,10);
%% harking back 50ms from the current NB onset definition and redefining
%onset boundaries.
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
for ii = 1: length(mod_NB_onsets)
    NB_slices{ii}.time = spks.time(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
    NB_slices{ii}.channel = spks.channel(spks.time>=mod_NB_onsets(ii) & spks.time<=NB_ends(ii));
end

%% 1. scores with the entire burst lengths divided into 3 sections
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     classA = 1:round(length(NB_slices{ii}.time)/3);
%     classB = classA(end)+1:round(2*length(NB_slices{ii}.time)/3);
%     classC = classB(end)+1:length(NB_slices{ii}.time);
%     scores(NB_slices{ii}.channel(classA)+1) = scores(NB_slices{ii}.channel(classA)+1)+ 3;
%     scores(NB_slices{ii}.channel(classB)+1) = scores(NB_slices{ii}.channel(classB)+1)+ 2;
%     scores(NB_slices{ii}.channel(classC)+1) = scores(NB_slices{ii}.channel(classC)+1)+ 1;
% end


%% 2. scores considering the ranks of just the first 10 spikes of each NB
% 
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     scores(NB_slices{ii}.channel(1:10)+1) = scores(NB_slices{ii}.channel(1:10)+1)+ [10:-1:1]';
% end

%% 3. scores looking at three 50 ms increments after NB start
% 
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     classA = NB_slices{ii}.channel(NB_slices{ii}.time<= mod_NB_onsets(ii)+50e-3);
%     classB = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+50e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+100e-3);
%     classC = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+100e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+150e-3);
%     scores(classA+1) = scores(classA+1) + 3;
%     scores(classB+1) = scores(classB+1) + 2;
%     scores(classC+1) = scores(classC+1) + 1;
% end
%% 4. Oliver's code
[Delay_hist_fig nr_starts, EL_return] = NB_sequences_sk(datRoot,network_burst, 0,1,bursting_channels_mea);

%% 5. Occurence probability distribution
 prob_chart = zeros(60,1); % probability chart shall denote the probability that a channel is the first in a burst
% for ii = 1:size(NB_slices,1)
%     prob_chart(NB_slices{ii}.channel(1)+1) = prob_chart(NB_slices{ii}.channel(1)+1) + 1;
% end
% prob_chart = prob_chart/size(NB_slices,1);

% for ii = 1:size(NB_slices,1)
%     ch_unique = unique_us(NB_slices{ii}.channel);
%     temp = ismember([1:60]', ch_unique(1:3)+1);
%     prob_chart = prob_chart + temp;
% end
% prob_chart = prob_chart/size(NB_slices,1);


not_incl = [];
for ii = 1:size(NB_slices,1)
    ch_unique = unique_us(NB_slices{ii}.channel);
    if length(ch_unique>=5)
        temp = ismember([1:60]', ch_unique(1:3)+1);
        prob_chart = prob_chart + temp;
    else
        not_incl(end+1) = ii;
    end
end
prob_chart = prob_chart/(size(NB_slices,1)-numel(not_incl));
figure; bar(prob_chart)
