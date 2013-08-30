[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\Spontaneous';
end

[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);

datRoot = datName(1:strfind(datName,'.')-1);
spikes = loadspike([pathName,datName],2,25);
spks = cleanspikes(spikes);
spikes_samples = loadspike([pathName,datName],2); %timestamps loaded as samples
spks_samples = cleanspikes(spikes_samples);

%% Generate `states'
inAChannel = cell(60,1);
binWidth = 10; %in ms
nBits = 10;
states = zeros(nBits,ceil(max(spks_samples.time)/(25*binWidth))); % each states is now a column; 250 samples correspond to 10ms
for ii=0:59
    inAChannel{ii+1,1} = spks_samples.time(spks_samples.channel==ii);
end
nSpikesInEachChannel = cellfun(@length,inAChannel);
[sortedNSpikes, sortedIndx] = sort(nSpikesInEachChannel,'descend');

for ii = 1:nBits
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
red_states_dec(nullstateidx) = []; % contiguous all zero states are clumped together as single states

[b, m, n] = unique(red_states_dec);
count = zeros(size(b));
for ii = 1 : length(b)
    count(ii) = numel(n(n == ii));
end
count_n = count/length(red_states_dec); % the occ. probabilities of each state
%% plots
fh1 = figure; %occurrence probabilites
%[counts,timeVec] = hist(spks_samples.time,[0:ceil(max(spks_samples.time))]);
bar(b,count_n,4), axis tight
xlabel('States','FontSize',12)
ylabel('Probability','FontSize',12)

% fh2 = figure; %tepmoral progression
% plot(red_states_dec,'.','markersize',4); axis tight
% xlabel('temporal progression','FontSize',12)
% ylabel('state values in dec','FontSize',12)
% title(datRoot,'FontSize',12,'Interpreter','none')
% 
% fh3 = figure; %tepmoral progression
% semilogy(red_states_dec,'.','markersize',4); axis tight
% xlabel('temporal progression','FontSize',12)
% ylabel('state values in dec (logscale)','FontSize',12)
% title(datRoot,'FontSize',12, 'Interpreter','none')

%%
% vec = [1 2 4 8 16 32 64 128 256 512];
% fh4 = figure;
% for ii = 1:length(vec)
%     plot(ii,count_n(b==vec(ii)),'*-')
%     hold on
% end
% plot([1:10], 0.1*ones(1,10)); hold off

%% the probablities given a uniform dist.
% fh5 = figure;
for ii = 0:10
    prob(ii+1) = 1/nchoosek(10,ii);
end
% plot([0:10],prob,'*-');
fh6 = figure;
semilogy([0:10],prob,'*-');
%% 

values_by_nOnes = cell(nBits+1,1); % zero bits to nBits bits
for ii = 0:2^nBits-1
binary_rep = dec2bin(ii);
nOnesRequired = length(find(binary_rep == '1'));
values_by_nOnes{nOnesRequired+1}(end+1) = ii; 
end

for ii = 1:nBits+1
    values_by_nOnes{ii}(2,:) = zeros(size(values_by_nOnes{ii}(1,:)));
    for jj = 1:size(values_by_nOnes{ii},2)
        if count_n(b==values_by_nOnes{ii}(1,jj))
%             values_by_nOnes{ii}(2,jj) = count_n(b==values_by_nOnes{ii}(1,jj));
            values_by_nOnes{ii}(2,jj) = count(b==values_by_nOnes{ii}(1,jj));
        end
    end
end

fh7 = figure;
for ii = 1:nBits+1
    subplot(3,4,ii)
    plot(values_by_nOnes{ii}(2,:)/sum(values_by_nOnes{ii}(2,:)),'--.','markersize',5);
    hold on;
    xlim([0 size(values_by_nOnes{ii},2)]);
    xax = get(gca,'XLim');
    %(1:size(values_by_nOnes{ii},2))
    %plot(linspace(xax(1),xax(2),size(values_by_nOnes{ii},2)),prob(ii)*ones(1,size(values_by_nOnes{ii},2)),'r');
    title(['Class:',num2str(ii-1)],'FontSize',12);
    %axis tight
end

%%
% fr profile of a single channel.
% [nSpksPerBin,timeVec] = hist(spks_samples_51,0:25e3:max(spks_samples_51));
% fh8 = figure;
% ah8 = gca(fh8);
% %bar(timeVec/25e3,nSpksPerBin,.1);
% plot(timeVec/25e3,nSpksPerBin/length(spks_samples_51));
% zoom xon;
% set(ah8,'XLim',[0,2500]);

%skewing the uniform probabilities

nSpikesInChosen = sum(nSpikesInEachChannel(sortedIndx(1:nBits)));
weights2skew = nSpikesInEachChannel(sortedIndx(1:nBits))/nSpikesInChosen; %from MSB to LSB

set(0,'CurrentFigure',fh7);
for ii = 1:nBits+1
    bin_words = dec2bin(values_by_nOnes{ii}(1,:)); %list of binary words in each class
    pseudoExpectation = zeros(size(bin_words,1),1);
    for jj = 1:size(bin_words,1)
        ones_pos = find(bin_words(jj,:) == '1');
        pseudoExpectation(jj,1) = prod(weights2skew(ones_pos));
    end
    subplot(3,4,ii)
    plot(pseudoExpectation,'--.k');
end

[ax1,h1] = suplabel('Various possible words in each case arranged in ascending order');
[ax2,h2] = suplabel('Probability','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);
tightfig;