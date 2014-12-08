function CFP = computeCFP(X,maxlag,binsize)
    
    CFP = zeros(size(X,1),size(X,1),maxlag);
    count = 0;
    h = waitbar(0,'Computing CFP matrix ... ');
    for ii = 1:size(X,1)
        for jj = ii:size(X,1)
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