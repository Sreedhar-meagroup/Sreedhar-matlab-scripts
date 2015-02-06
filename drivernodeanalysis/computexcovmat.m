function covmat = computexcovmat(X, maxlag,nactiveel)

X = X'; %each column corresponds to each active electrode

crosscov = xcov(X,maxlag);
covmat = zeros(size(X,2),size(X,2),maxlag);
for ii = 1:size(X,2)
    for jj = 1:size(X,2)
        covmat(ii,jj,:) = crosscov(maxlag+2:end,(ii-1)*nactiveel+jj)';
    end
end
