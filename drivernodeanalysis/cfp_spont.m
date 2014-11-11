% adyam load spontaneous data


% Dividing data into blocks of 2^15 events
% active electrode if 250 spikes out of 2^15

binsize = 0.5e-3; %0.5 ms bin
nbins   = 10e-3/binsize;
% binvec = linspace(0,10e-3-binsize,nbins);
spks = spon_data.Spikes;
spks_blk1.time = spks.time(1:2^15); 
spks_blk1.channel = spks.channel(1:2^15);

for blk = 1:1
    inAChannel = cell(60,1);
    for ii=0:59
        inAChannel{ii+1,1} = spks_blk1.time(spks_blk1.channel==ii);
    end
    
    activeEl = [];
    for el = 1:60
        if length(find(spks_blk1.channel==el-1))>10
            activeEl = [activeEl, el];
        end
    end
    mintime = min(spks_blk1.time);
    maxtime = max(spks_blk1.time);
    binvec = mintime:binsize:(maxtime-binsize);
    X = zeros(length(activeEl),length(binvec));
    for ii = 1:length(activeEl)
        X(ii,:) = histc(inAChannel{activeEl(ii)},binvec);
    end
    
    maxlag = 0.5/binsize;
    CFP = zeros(length(activeEl),length(activeEl),maxlag);
    for ii = 1:length(activeEl)
        for jj = 1:length(activeEl)
            [cor, lag] = xcorr(X(ii,:),X(jj,:),maxlag);
            N_follow = fliplr(cor(lag<0));
            N_self = sum(X(ii,:));
            CFP(ii,jj,:) = N_follow./ N_self;
        end
    end
end

sumCFP_tau = sum(CFP,3);
[maxvals,lininds] = sort(sumCFP_tau(:),'descend');
hwmnybns = 10;
meanNbins = 1:hwmnybns:maxlag;
hwmnyplts = 6;
figure;
for plt = 1:hwmnyplts 
    for ii = 1:length(meanNbins)-1
        [fromch, toch] = ind2sub(size(sumCFP_tau),lininds(plt+250));
        meanN(ii) = mean(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
        stdN(ii) = std(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
    end
    subplot(3,2,plt)
    errorbar((1:length(meanN))*5,meanN,stdN,'o');
    title([num2str(activeEl(fromch)),'-->',num2str(activeEl(toch))]);
    set(gca,'FontSize',14,'TickDir','Out'); box off;
end

[~,h1] = suplabel('\tau [ms]');
[~,h2] = suplabel('CFP_{i,j}(\tau)','y');
[~,h3] = suplabel(['File: ', spon_data.fileName],'t');
set(h3,'Interpreter','None');
set([h1 h2],'FontSize',14);
