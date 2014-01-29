if ~exist('datName','var')
    [datName,pathName] = chooseDatFile();
end
[ch2ignore, NBextremes, NB_slices] = spontaneousData(datName,pathName);
datRoot = datName(1:strfind(datName,'.')-1);
spikes = loadspike([pathName,datName],2,25);
thresh  = extract_thresh([pathName, datName, '.desc']);
spks = cleanspikes(spikes, thresh);
spikes_samples = loadspike([pathName,datName],2); %timestamps loaded as samples
spks_samples = cleanspikes(spikes_samples,thresh);

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
sortedIndx = sortedIndx - 1; %converting to cahnnel numbers 0-59
%silencing the channels to ignore (continously active ones)
[~,indx2ignore] = ismember(ch2ignore,sortedIndx);
sortedNSpikes(indx2ignore) = [];
sortedIndx(indx2ignore) = [];

for ii = 1:nBits
states(ii,ceil(inAChannel{sortedIndx(ii)}/(25*binWidth))) = 1;
end
states_str = num2str(states'); %each state is now a row
states_dec = bin2dec(states_str); % each state is now an integer
nullstateidx = find(states_dec == 0);
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
            values_by_nOnes{ii}(2,jj) = count(b==values_by_nOnes{ii}(1,jj));
        end
    end
end

fh7 = figure;
for ii = 2:5%1:nBits+1
%     subplot(3,4,ii)
    subplot(2,2,ii-1)
    plot(values_by_nOnes{ii}(2,:)/sum(values_by_nOnes{ii}(2,:)),'linewidth',2)%,'.','markersize',5);
    hold on;
    xlim([0 size(values_by_nOnes{ii},2)]);
    xax = get(gca,'XLim');
    plot(linspace(xax(1),xax(2),size(values_by_nOnes{ii},2)),prob(ii)*ones(1,size(values_by_nOnes{ii},2)),'r','LineWidth',2);
    title(['Words with ',num2str(ii-1), 'active bits'],'FontSize',16);
    %axis tight
end

%% skewing the uniform probabilities

nSpikesInChosen = sum(nSpikesInEachChannel(sortedIndx(1:nBits)));
weights2skew = nSpikesInEachChannel(sortedIndx(1:nBits))/nSpikesInChosen; %from MSB to LSB

set(0,'CurrentFigure',fh7);
for ii = 2:5 % 1:nBits+1
    bin_words = dec2bin(values_by_nOnes{ii}(1,:)); %list of binary words in each class
    pseudoExpectation = zeros(size(bin_words,1),1);
    for jj = 1:size(bin_words,1)
        ones_pos = find(bin_words(jj,:) == '1');
        pseudoExpectation(jj,1) = prod(weights2skew(ones_pos));
    end
%     subplot(3,4,ii)
    subplot(2,2,ii-1);
    plot(pseudoExpectation,'k','LineWidth',2)%,'.k','MarkerSize',5);
end

[ax1,h1] = suplabel('All possible words arranged of each type arranged in ascending order');
[ax2,h2] = suplabel('Probability','y');
set(h1,'FontSize',16);
set(h2,'FontSize',16);
% tightfig;

%% fr profile of a single channel.
spks_samples_51 = inAChannel{sortedIndx(1)};
[nSpksPerBin,timeVec] = hist(spks_samples_51,0:25e3:max(spks_samples_51)); %10ms bins
% fh8 = figure;
% ah8 = gca(fh8);
% bar(timeVec/25e3,nSpksPerBin,.5);
% %plot(timeVec/25e3,nSpksPerBin);
% zoom xon;
% set(ah8,'XLim',[0,2500]);

%% attempt 1: in terms of ISIs
spks_time_51 = spks_samples_51/25e3;
isi_ch51 = [0, diff(spks_time_51)];
datForHist = [spks_time_51',isi_ch51']; %[y,x] format
nbins = [10,100]; %[nxbins,nybins] format
figure;
n = hist3(matrixForHist,nbins);
% n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 
xb = linspace(min(isi_ch51),max(isi_ch51),size(n,1));
yb = linspace(min(spks_time_51),max(spks_time_51),size(n,2));
h = pcolor(xb,yb,n');
% colormap gray
set(h, 'EdgeColor', 'none');
ch = colorbar;

%% Looking at words within bursts in each channel
wordsInNB = cell(size(NBextremes,1),1); % cell of the size of the number of NBs. Each cell stores the...
naiveFreqInt = zeros(10,size(NBextremes,1)); % sum of active bits holder 
% bits of each of the 10 chosen channels during that particular NB.
for ii = 1:size(NBextremes,1)
    nbStartBin = floor(NBextremes(ii,1)*25e3/250) + 1;
    nbStopBin = floor(NBextremes(ii,2)*25e3/250) + 1;
    wordsInNB{ii} = states(:,nbStartBin:nbStopBin);
    naiveFreqInt(:,ii) = sum(wordsInNB{ii},2); % naive freq interpretation as the sum of active bits
end

allPairsOfChannels = nchoosek(1:nBits,2);
allRatios = zeros(size(allPairsOfChannels,1),size(NBextremes,1));
for ii = 1: size(allPairsOfChannels,1)
    allRatios(ii,:) = naiveFreqInt(allPairsOfChannels(ii,2),:)./naiveFreqInt(allPairsOfChannels(ii,1),:);
end

%plotting all 45 ratio combinations
for ii = 1:size(allPairsOfChannels,1)
    if ~mod(ii-1,9), figure; end
    subplot(3,3,mod(ii-1,9)+1)
    plot(allRatios(ii,:),'.','markersize',4);
    title([num2str(allPairsOfChannels(ii,2)),'/',num2str(allPairsOfChannels(ii,1))]);
end

% think about doing some curve fitting into the plotted data

%% Looking at no: of spikes within bursts in each channel
nSpikesInChPerNB = zeros(10,size(NBextremes,1));
% bits of each of the 10 chosen channels during that particular NB.
for ii = 1:size(NBextremes,1)
nSpikesInChPerNB(:,ii) = arrayfun(@(x) length(find(NB_slices{ii}.channel == x)),sortedIndx(1:10)-1);
end

allPairsOfChannels = nchoosek(1:nBits,2);
allRatios = zeros(size(allPairsOfChannels,1),size(NBextremes,1));
for ii = 1: size(allPairsOfChannels,1)
    allRatios(ii,:) = nSpikesInChPerNB(allPairsOfChannels(ii,2),:)./nSpikesInChPerNB(allPairsOfChannels(ii,1),:);
end

%plotting all 45 ratio combinations
for ii = 1:1%size(allPairsOfChannels,1)
    if ~mod(ii-1,9), figure; end
    subplot(3,3,mod(ii-1,9)+1)
    temp = allRatios(ii,:);
    temp(temp == Inf) = [];
    shadedErrorBar(1:size(temp,2),mean(temp)*ones(size(temp)),std(temp)*ones(size(temp)),{'k','linewidth',0.5},0);
    hold on;
    plot(temp,'.','markersize',4); 
    axis tight;
    title([num2str(allPairsOfChannels(ii,2)),'/',num2str(allPairsOfChannels(ii,1))]);
end


%% basic transition probabilities
tpmat = zeros(1024);
for ii = 0
    temp1 = find(red_states_dec == ii);
    if any(ismember(temp1,size(red_states_dec,2)))
        itsInd = find(temp1 == size(red_states_dec,2) );
        temp1(itsInd) = [];
    end
    temp2 = red_states_dec(temp1+1);
    temp3 = histc(temp2,0:1023);

    tpmat(ii,:) = temp3;
end
    

