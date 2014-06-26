allStates_dec = [];
for ii = 1:length(NB_ends)
    allStates_dec(end+1) = 0;
    allStates_dec = [allStates_dec; states_NB_dec{ii}];
end
[unique_states, ind_i, ind_j] = unique(allStates_dec,'first'); 
transProbMat = zeros(1024);

for ii = 1:length(unique_states)
    temp_ind = find(allStates_dec == unique_states(ii));
    temp_col = zeros(1024,1);
    for jj = 1:length(temp_ind)
        if temp_ind(jj)~=length(allStates_dec)
            temp_col(allStates_dec(temp_ind(jj)+1)+1) = ...
                temp_col(allStates_dec(temp_ind(jj)+1)+1)+1;
        end
    end
    transProbMat(:,unique_states(ii)+1) = temp_col; 
end
% normalization
for ii = 1:length(transProbMat)
    if sum(transProbMat(:,ii))
        transProbMat(:,ii) = transProbMat(:,ii)/sum(transProbMat(:,ii));
    end
end

figure;
spy(transProbMat);
set(gca,'TickDir','Out')
% set(gca,'FontSize',14)
axis square
% xlabel('Pre')
% ylabel('Post')
title('Sparsity pattern (pre)');

transProbMat2 = transProbMat;
transProbMat2(transProbMat2==0)=NaN;
figure; 
imagescwithnan(transProbMat2,jet,[1 1 1])
% imagesc(transProbMat)
% colormap(gray)
set(gca,'TickDir','Out')
set(gca,'FontSize',14)
axis square
xlabel('Pre')
ylabel('Post')
title('Pre-session transition probabilities');

%smoothed version
transProbMat_sm = zeros(size(transProbMat));
for ii = 1:length(transProbMat)
    transProbMat_sm(:,ii) = smooth(transProbMat(:,ii),25,'lowess');
    if sum(transProbMat_sm(:,ii))
    transProbMat_sm(:,ii) = transProbMat_sm(:,ii)/sum(transProbMat_sm(:,ii));
    end
end
