data = spontaneousData;

%%
winWidth = 250;
fanofact = zeros(60,12);
for ii = 1:60
    for jj = 1:12%data.Spikes.time(end) 
        InAChInAWin{ii}{jj} = data.InAChannel{ii}(and(data.InAChannel{ii} > (jj-1)*winWidth, data.InAChannel{ii} <= jj*winWidth));
        if size(InAChInAWin{ii}{jj},2)>2
            fanofact(ii,jj) = var(diff(InAChInAWin{ii}{jj}))/mean(diff(InAChInAWin{ii}{jj}));
        end

    end
end

%%
ch_virility = zeros(60,1);
for ii = 1:60
    ch_virility(ii) = length(find(data.Spikes.channel == ii-1));
end
[~,most_active_ch] = sort(ch_virility,'descend');

%%
figure; imagesc(fanofact_poi(1:10,:));
colorbar
set(gca,'TickDir','Out')
set(gca,'FontSize',14)
xlabel('Window #')
ylabel('Channel #')
title('Window width = 250 s')

%%
a = poissrnd(25,60,10000);
fanofact_poi = zeros(60,75);
for ii = 1:75
    b = a(:,ii*winWidth+1:(ii+1)*winWidth);
    fanofact_poi(:,ii) = var(b,0,2)./mean(b,2); 
end

AllChSpTimes = [zeros(60,1), cumsum(a,2)]; 
combinedSpTrain = [reshape(AllChSpTimes,[],1),repmat((1:60)',10001,1)];

[srt_val, srt_ind] = sort(combinedSpTrain(:,1));

spks_poi.time = srt_val';
spks_poi.channel = combinedSpTrain(srt_ind,2)';

%%
gfr_rstr_h    = figure();

make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end


binSize = 0.1;
[counts,timeVec] = hist(spks.time,0:binSize:ceil(max(spks.time)));
smooth_gfr = smooth(counts/binSize,'lowess',35);
fig1ha(1) = subplot(3,1,1); plot(timeVec,smooth_gfr,'k','LineWidth',1); box off;
set(gca,'XTick',[]);
set(gca,'TickDir','Out');
axis tight; ylabel('Global firing rate [Hz]'); 
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
rasterplot_so(spks.time,spks.channel,'k-');
hold off;
set(gca,'TickDir','Out');
% set(gca,'YMinorGrid','On');
xlabel('Time [s]');
ylabel('Channel');
pan xon;
zoom xon;