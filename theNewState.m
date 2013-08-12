[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\StimRecSite\StimPolicy2';
end

[datName,~]=uigetfile('*.spike','Select MEABench Data file',srcPath);

%datRoot = '130628_4242';
%datName = [datRoot,'_spontaneous.spike'];
%datName = [datRoot,'_stimEfficacy.spike'];
datRoot = datName(1:strfind(datName,'.')-1);
spikes = loadspike(datName,2,25);
spks = cleanspikes(spikes);
spikes_samples = loadspike(datName,2); %timestamps loaded as samples
spks_samples = cleanspikes(spikes_samples);

%% Generate `states'
inAChannel = cell(60,1);
binWidth = 10; %in ms
states = zeros(10,ceil(max(spks_samples.time)/(25*binWidth))); % each states is now a column; 250 samples correspond to 10ms
for ii=0:59
    inAChannel{ii+1,1} = spks_samples.time(spks_samples.channel==ii);
end
nSpikesInEachChannel = cellfun(@length,inAChannel);
[sortedNSpikes, sortedIndx] = sort(nSpikesInEachChannel,'descend');
for ii = 1:10
states(ii,ceil(inAChannel{sortedIndx(ii)}/(25*binWidth))) = 1;
end
states_str = num2str(states'); %each state is now a row
states_dec = bin2dec(states_str); % each state is now an integer
nullstateidx = find(states_dec ==0);
nulltemp = [nullstateidx(1); nullstateidx(find(diff(nullstateidx)>1)+1)];
for ii = 1: length(nulltemp)
    nullstateidx(nullstateidx==nulltemp(ii)) = [];
end
red_states_dec = states_dec;
red_states_dec(nullstateidx) = [];

[b, m, n] = unique(red_states_dec);
count = zeros(size(b));
for ii = 1 : length(b)
    count(ii) = numel(n(n == ii));
end
count_n = count/length(red_states_dec);
%% plots
figure(1)
%[counts,timeVec] = hist(spks_samples.time,[0:ceil(max(spks_samples.time))]);
bar(b,count_n,3), axis tight
xlabel('States','FontSize',12)
ylabel('Probability','FontSize',12)

figure(2)
plot(red_states_dec,'.'); axis tight
xlabel('temporal progression','FontSize',12)
ylabel('state values in dec','FontSize',12)
title(datRoot,'FontSize',12)

figure(3)
semilogy(red_states_dec,'.'); axis tight
xlabel('temporal progression','FontSize',12)
ylabel('state values in dec (logscale)','FontSize',12)
title(datRoot,'FontSize',12)

%%
vec = [1 2 4 8 16 32 64 128 256 512];
figure(4)
for ii = 1:length(vec)
    plot(ii,count_n(b==vec(ii)),'*-')
    hold on
end
plot([1:10], 0.1*ones(1,10)); hold off

%%
figure(5)
for ii = 0:10
    prob(ii+1) = 1/nchoosek(10,ii);
end
plot([0:10],prob,'*-');
figure(6)
semilogy([0:10],prob,'*-');