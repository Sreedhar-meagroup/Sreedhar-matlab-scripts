datRoot = '130311_4108';
datName = [datRoot,'_spontaneous.spike'];
spikes = loadspike(datName,2); %timestamps loaded as samples
inAChannel = cell(60,1);
binWidth = 10; %in ms
states = zeros(10,ceil(max(spikes.time)/(25*binWidth))); % each states is now a column; 250 samples correspond to 10ms
for ii=0:59
    inAChannel{ii+1,1} = spikes.time(spikes.channel==ii);
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
