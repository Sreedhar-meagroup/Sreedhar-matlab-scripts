myfun = @(x) size(x.time,2);
nSpPerSponNB = cellfun(@(x) myfun(x),spon_data.NetworkBursts.NB_slices);
data_in.spcounts = nSpPerSponNB;
data_in.stimdetails.stimTimes{1} = spon_data.NetworkBursts.NB_extrema(:,1);
data_in.stimdetails.stimInd = 1;
temp = perimeananalysis(data_in,'all');
sponSB_global_IF = temp.Indicatorfun;
binSize = 0.1;
[counts,timeVec] = hist(spon_data.Spikes.time,0:binSize:ceil(max(spon_data.Spikes.time)));
smooth_gfr = smooth(counts/binSize,'lowess',35);


figure;
plot(overmean,ones(size(overmean)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on; 
plot(undermean,zeros(size(undermean)),'rv','MarkerSize',7,'MarkerFaceColor','r');

box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('Stim index, n')
ylabel('I(n)');
title('Indicator function around mean');
legend('supra','infra');