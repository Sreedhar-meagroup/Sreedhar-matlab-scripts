%Network bursts: a closer look
[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\Spontaneous\';
end

[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);spikes=loadspike(datName,2,25);
datRoot = datName(1:strfind(datName,'.')-1);
spks = cleanspikes(spikes); % Work on this later
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
final_tally = zeros(20,7);
%% Burst detection part
burst_detection = burstDetAllCh_sk(spikes);
[bursting_channels_mea, network_burst, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk(datName,spikes,burst_detection,20);
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

%% 1. scores with the entire burst lengths divided into 3 sections (unique)
scores = zeros(60,1);
for ii = 1: length(mod_NB_onsets)
    classA = 1:round(length(NB_slices{ii}.time)/3);
    classB = classA(end)+1:round(2*length(NB_slices{ii}.time)/3);
    classC = classB(end)+1:length(NB_slices{ii}.time);
    %scores(NB_slices{ii}.channel(classA)+1) = scores(NB_slices{ii}.channel(classA)+1)+ 3;
    scores(unique_us(NB_slices{ii}.channel(classA))+1) = scores(unique_us(NB_slices{ii}.channel(classA))+1)+ 3;
    %scores(NB_slices{ii}.channel(classB)+1) = scores(NB_slices{ii}.channel(classB)+1)+ 2;
    scores(unique_us(NB_slices{ii}.channel(classB))+1) = scores(unique_us(NB_slices{ii}.channel(classB))+1)+ 2;
    %scores(NB_slices{ii}.channel(classC)+1) = scores(NB_slices{ii}.channel(classC)+1)+ 1;
    scores(unique(NB_slices{ii}.channel(classC))+1) = scores(unique(NB_slices{ii}.channel(classC))+1)+ 1;
end
[~,b] = sort(scores,'descend');
final_tally(:,2) = b(1:size(final_tally,1));

%% 2. scores considering the ranks of just the first 10 spikes of each NB (unique)
 
scores = zeros(60,1);
for ii = 1: length(mod_NB_onsets)
    %scores(NB_slices{ii}.channel(1:10)+1) = scores(NB_slices{ii}.channel(1:10)+1)+ [10:-1:1]';
    temp_chan = unique_us(NB_slices{ii}.channel(1:10),'first',10);
    scores(temp_chan+1) = scores(temp_chan+1)+ (length(temp_chan):-1:1)';
end
[~,b] = sort(scores,'descend');
final_tally(:,3) = b(1:size(final_tally,1));

%% 3. scores looking at three 50 ms increments after NB start
% 
scores = zeros(60,1);
for ii = 1: length(mod_NB_onsets)
    %classA = NB_slices{ii}.channel(NB_slices{ii}.time<= mod_NB_onsets(ii)+50e-3);
    classA = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time<= mod_NB_onsets(ii)+50e-3));
    %classB = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+50e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+100e-3);
    classB = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+50e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+100e-3));
    %classC = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+100e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+150e-3);
    classC = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+100e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+150e-3));
    scores(classA+1) = scores(classA+1) + 3;
    scores(classB+1) = scores(classB+1) + 2;
    scores(classC+1) = scores(classC+1) + 1;
end
[~,b] = sort(scores,'descend');
final_tally(:,4) = b(1:size(final_tally,1));

%% 4. Oliver's code
[Delay_hist_fig nr_starts, EL_return] = NB_sequences_sk(datRoot,network_burst, 0,1,bursting_channels_mea);
final_tally(:,1) = (cr2hw(EL_return)+1)';
%% 5. Occurence probability distribution
prob_chart = zeros(60,1); % probability chart shall denote the probability that a channel is the first in a burst
for ii = 1:size(NB_slices,1)
    prob_chart(NB_slices{ii}.channel(1)+1) = prob_chart(NB_slices{ii}.channel(1)+1) + 1;
end
prob_chart = prob_chart/size(NB_slices,1);
[~,b] = sort(prob_chart,'descend');
final_tally(:,5) = b(1:size(final_tally,1));

prob_chart = zeros(60,1);
for ii = 1:size(NB_slices,1)
    ch_unique = unique_us(NB_slices{ii}.channel);
    %ch_non_unique = NB_slices{ii}.channel;
    temp = ismember([1:60]', ch_unique(1:3)+1);
    %temp = ismember([1:60]', ch_non_unique(1:3)+1);
    prob_chart = prob_chart + temp;
end
prob_chart = prob_chart/size(NB_slices,1);
[~,b] = sort(prob_chart,'descend');
final_tally(:,6) = b(1:size(final_tally,1));

prob_chart = zeros(60,1);

not_incl = [];
for ii = 1:size(NB_slices,1)
    ch_unique = unique_us(NB_slices{ii}.channel);
    %ch_non_unique = NB_slices{ii}.channel;
    if length(ch_unique>=5)
    %if length(ch_non_unique>=5)
        temp = ismember([1:60]', ch_unique(1:5)+1);
        %temp = ismember([1:60]', ch_non_unique(1:5)+1);
        prob_chart = prob_chart + temp;
    else
        not_incl(end+1) = ii;
    end
end
prob_chart = prob_chart/(size(NB_slices,1)-numel(not_incl));
[~,b] = sort(prob_chart,'descend');
final_tally(:,7) = b(1:size(final_tally,1));

%% A distance matrix
dist_matrix = zeros(size(final_tally,2));
for ii = 1:size(final_tally,2)
    for jj = ii:size(final_tally,2)
        for kk = 1:size(final_tally,1)
            if length(find(final_tally(:,jj) == final_tally(kk,ii)))              
                dist_matrix(ii,jj) = dist_matrix(ii,jj) + abs((kk - find(final_tally(:,jj) == final_tally(kk,ii))));
            else
                dist_matrix(ii,jj) = dist_matrix(ii,jj) + abs((kk - size(final_tally,1)));
            end
        end
    end
end
dist_matrix = dist_matrix + triu(dist_matrix)';
figure; imagesc(dist_matrix); colorbar;


set(gca,'Yticklabel',{'Oliver''s scheme'; 'Dividing into thirds'; 'Ranks of first ten'; 'Three slabs'; 'P(1 spike)';'P(3 spikes)';'P(5 spikes)'},'FontSize',16)
set(gca,'Xticklabel',{'Oliver''s scheme'; 'Dividing into thirds'; 'Ranks of first ten'; 'Three slabs'; 'P(1 spike)';'P(3 spikes)';'P(5 spikes)'},'FontSize',16)
xticklabel_rotate;
axis square
% set(gca,'fontsize',16)
