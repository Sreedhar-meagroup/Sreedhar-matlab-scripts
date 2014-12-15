% load spontaneous data
spon_data = spontaneousData(9);

% Dividing data into blocks of 2^15 events
% active electrode if 250 spikes out of 2^15

binsize = 5e-3; %using 10 ms bin now; earlier, 0.5 ms bin
winofint = 0.5; % time window of interest
maxlag = winofint/binsize;
spks = spon_data.Spikes;
spks_blk1.time = spks.time(1:2^15); 
spks_blk1.channel = spks.channel(1:2^15);

%% computation of the CFP block (n x n x maxlag matrix)
% n : the no: of active electrodes
% maxlag: 500ms/0.5ms = 1000
for blk = 1:1
    inAChannel = cell(60,1);
    activeEl = [];
    for ii=0:59
        inAChannel{ii+1,1} = spks_blk1.time(spks_blk1.channel==ii);
        if length(find(spks_blk1.channel==ii))>10
            activeEl = [activeEl, ii+1];
        end
    end
    
    
%     limiting active electrodes to 10
    activeEl = activeEl(1:10);
    mintime = min(spks_blk1.time);
    maxtime = max(spks_blk1.time);
    binvec = mintime:binsize:(maxtime-binsize);

    X = zeros(length(activeEl),length(binvec));
    for ii = 1:length(activeEl)
        X(ii,:) = histc(inAChannel{activeEl(ii)},binvec);
    end
    
    
%% CFP matrix    
CFP = computeCFP(X,maxlag);
param_cfp = zeros(size(X,1),size(X,1),4);
t = (1:maxlag)*binsize*1e3;
for ii = 1:size(X,1)
    for jj = 1:size(X,1)
        param_cfp(ii,jj,:) = cfpfit(t,squeeze(CFP(ii,jj,:))); % M, T, w, offset: the parames in order
    end
end

%% Computing SRP

param_srp = zeros(size(X,1),size(X,1),4);

for ii = 1:size(X,1)
    for jj = 1:size(X,1)
        if jj~=ii
        param_srp(ii,jj,:) = srpfit(t,squeeze(CFP(ii,ii,:))',squeeze(CFP(ii,jj,:))'); % M, T, w, offset: the parames in order
        end
    end
end
%% Xcovariance matrix
covmat = computexcovmat(X,maxlag);



end




%% plotting utilities

sumCFP_tau = sum(CFP,3);
[maxvals,lininds] = sort(sumCFP_tau(:),'descend');
hwmnybns = 5;
meanNbins = 1:hwmnybns:maxlag;
hwmnyplts = 6;
figure;
for plt = 1:hwmnyplts 
%     for ii = 1:length(meanNbins)-1
%         [fromch, toch] = ind2sub(size(sumCFP_tau),lininds(plt));
%         meanN(ii) = mean(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
%         stdN(ii) = std(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
%     end
    subplot(3,2,plt)
%     errorbar((1:length(meanN))*binsize*1e3,meanN,stdN,'o');
plot((1:maxlag)*binsize*1e3,squeeze(CFP(1,plt,:)),'k^');
    title([num2str(activeEl(1)),'-->',num2str(activeEl(plt))]);
    set(gca,'FontSize',14,'TickDir','Out'); box off;
end

[~,h1] = suplabel('\tau [ms]');
[~,h2] = suplabel('CFP_{i,j}(\tau)','y');
[~,h3] = suplabel(['CFP:: ','File: ', spon_data.fileName],'t');
set(h3,'Interpreter','None');
set([h1 h2],'FontSize',14);




