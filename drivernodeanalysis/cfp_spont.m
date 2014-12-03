% first load spontaneous data


% Dividing data into blocks of 2^15 events
% active electrode if 250 spikes out of 2^15

binsize = 10e-3; %using 10 ms bin now; earlier, 0.5 ms bin
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
    
    CFP = zeros(length(activeEl),length(activeEl),maxlag);
    count = 0;
    h = waitbar(0,'Computing CFP matrix ... ');
    for ii = 1:length(activeEl)
        for jj = ii:length(activeEl)
            [cor, lag] = xcorr(X(ii,:),X(jj,:),maxlag);
            Nfollow_ij = cor(lag>0);
            Nfollow_ji = fliplr(cor(lag<0));
%             Nfollow_ij = fliplr(cor(lag<0));
%             Nfollow_ji = fliplr(cor(lag>0));

            N_self_i = sum(X(ii,:));
            N_self_j = sum(X(jj,:));
            CFP(ii,jj,:) = Nfollow_ij/ N_self_i;
            CFP(jj,ii,:) = Nfollow_ji/ N_self_j;
            count = count + 1;
            if ~mod(count,1e2)
                waitbar(count/length(activeEl)^2);
            end
        end
    end
    close(h);
end


%% Xcovariance matrix
X = X'; %each column corresponds to each active electrode

crosscov = xcov(X,maxlag);


%%
sumCFP_tau = sum(CFP,3);
[maxvals,lininds] = sort(sumCFP_tau(:),'descend');
hwmnybns = 5;
meanNbins = 1:hwmnybns:maxlag;
hwmnyplts = 6;
figure;
for plt = 1:hwmnyplts 
    for ii = 1:length(meanNbins)-1
        [fromch, toch] = ind2sub(size(sumCFP_tau),lininds(plt+50));
        meanN(ii) = mean(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
        stdN(ii) = std(CFP(fromch,toch,meanNbins(ii):meanNbins(ii+1)));
    end
    subplot(3,2,plt)
    errorbar((1:length(meanN))*binsize*1e3,meanN,stdN,'o');
    title([num2str(activeEl(fromch)),'-->',num2str(activeEl(toch))]);
    set(gca,'FontSize',14,'TickDir','Out'); box off;
end

[~,h1] = suplabel('\tau [ms]');
[~,h2] = suplabel('CFP_{i,j}(\tau)','y');
[~,h3] = suplabel(['File: ', spon_data.fileName],'t');
set(h3,'Interpreter','None');
set([h1 h2],'FontSize',14);


