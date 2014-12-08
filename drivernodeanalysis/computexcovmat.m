function covmat = computexcovmat(X, maxlag)

X = X'; %each column corresponds to each active electrode

crosscov = xcov(X,maxlag);
covmat = zeros(size(X,2),size(X,2),maxlag);
for ii = 1:size(X,2)
    for jj = 1:size(X,2)
        covmat(ii,jj,:) = crosscov(maxlag+2:end,(ii-1)*10+jj)';
    end
end
