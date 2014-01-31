%% basic transition probabilities
tpmat = zeros(1024);
for ii = 0:1023
    temp1 = find(red_states_dec == ii);
    if any(ismember(temp1,size(red_states_dec,1)))
        itsInd = find(temp1 == size(red_states_dec,1) );
        temp1(itsInd) = [];
    end
    temp2 = red_states_dec(temp1+1);
    temp3 = histc(temp2,0:1023);
    if max(temp3)
       temp3 = temp3/max(temp3);
    end
    tpmat(ii+1,:) = temp3;
end
figure; imagesc(tpmat); colorbar;
figure;
for ii = 1:9
        subplot(3,3,ii)
        plot(tpmat(ii,:),'linewidth',2);
        set(gca,'XTick',0:400:1024);
        set(gca,'FontSize',16)
        axis tight;
end