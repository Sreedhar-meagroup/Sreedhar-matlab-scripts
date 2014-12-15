NB_slices = spon_data.NetworkBursts.NB_slices;
SB_meamat = zeros(10,6,size(NB_slices,1));
SB_meamat_norm = SB_meamat;
firsts = zeros(length(NB_slices),2);
lasts = zeros(length(NB_slices),2);
RanksperSB = zeros(60,length(NB_slices));
meamap    = channelmap6x10_ch8x8_60;
chanList_detailed = cell(1,length(NB_slices));
chanList_brief = cell(1,length(NB_slices));

for ii = 1:length(NB_slices)
    chanList_detailed{ii} = NB_slices{ii}.channel+1;
    chanList_brief{ii} = unique_us(chanList_detailed{ii});
    
    for jj = 1:length(chanList_brief{ii})
        [r, c] = find(meamap == chanList_brief{ii}(jj));
        SB_meamat(r,c,ii) = jj;
        if jj == 1
            firsts(ii,:) = [r,c];
        elseif jj == length(chanList_brief{ii})
            lasts(ii,:) = [r,c];
        end
    end
    SB_meamat_norm(:,:,ii) = SB_meamat(:,:,ii)./jj;
    RanksperSB(chanList_brief{ii},ii) = 1:length(chanList_brief{ii});
end

% SB_meamat(SB_meamat==0) = NaN;
SB_meamat_norm(SB_meamat_norm==0) = NaN;



[LCperSB, ~] = find(RanksperSB==1); % LC == leading channel (channel with rank 1 in each burst)
nSBsfromEachCh = hist(LCperSB,1:60);
[sortednSBs,LCsorted] = sort(nSBsfromEachCh,'descend');
SB_hs2cs = []; % this part will arrange the indices of the SBs initiated from hotspots outwards.
for ii = 1:length(LCsorted)
    SB_hs2cs = [SB_hs2cs,find(RanksperSB(LCsorted(ii),:) == 1)]; 
end



figure; count = 1;
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.01 0.01]);
if ~make_it_tight,  clear subplot;  end
for ii = 1:5
    for jj = 1:11
       subplot(5,11,count)
       imagescwithnan(SB_meamat_norm(:,:,count),jet,[1,1,1]); axis image;
       set(gca,'TickDir','Out','xTickLabel',[],'yTickLabel',[]);
       text(firsts(count,2),firsts(count,1),'F','color','w','HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','Bold');
       text(lasts(count,2),lasts(count,1),'L','color','w','HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','Bold');
       count = count+1;
    end
end



%% Distance metric all bursts in natural order
dist_metric = cell(length(NB_slices));
dist_metric_norm = cell(length(NB_slices));
max_dist = sqrt((diff([1 10]).^2+diff([1 6]).^2));
tic
for sb1 = 1:length(NB_slices)
    for sb2 = sb1:length(NB_slices)
        for ii = 1:min(length(chanList_brief{sb1}),length(chanList_brief{sb2}))
            [r, c] = find(SB_meamat(:,:,[sb1,sb2])==ii);
            dist_metric{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
        end
        dist_metric_norm{sb1,sb2} = dist_metric{sb1,sb2}./max_dist;
        dist_metric_norm{sb2,sb1} = dist_metric_norm{sb1,sb2};
    end
end
toc
sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm);

figure; imagesc(sum_dist); axis image; colorbar
figure; histogram(sum_dist(:),'Normalization','probability');
set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');


%% Distance metric bursts form a single channel

tic
SBsFromACh = SB_hs2cs(1:sortednSBs(1));
for sb1 = 1:length(SBsFromACh)
    for sb2 = sb1:length(SBsFromACh)
        for ii = 1:min(length(chanList_brief{SBsFromACh(sb1)}),length(chanList_brief{SBsFromACh(sb2)}))
            [r, c] = find(SB_meamat(:,:,[SBsFromACh(sb1),SBsFromACh(sb2)])==ii);
            dist_metric_1ch{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
        end
        dist_metric_norm_1ch{sb1,sb2} = dist_metric_1ch{sb1,sb2}./max_dist;
        dist_metric_norm_1ch{sb2,sb1} = dist_metric_norm_1ch{sb1,sb2};
    end
end
toc

sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm_1ch);

figure; imagesc(sum_dist); axis image; colorbar
set(gca,'tickDir','Out'); box off; xlabel('SB#'); ylabel('SB#'); title('Distances between SB pathways ');
figure; histogram(sum_dist(:),'Normalization','probability');
set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');

%% Distance metric all bursts sorted by leading channel
tic
for sb1 = 1:length(SB_hs2cs)
    for sb2 = sb1:length(SB_hs2cs)
        for ii = 1:min(length(chanList_brief{SB_hs2cs(sb1)}),length(chanList_brief{SB_hs2cs(sb2)}))
            [r, c] = find(SB_meamat(:,:,[SB_hs2cs(sb1),SB_hs2cs(sb2)])==ii);
            dist_metric_s{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
        end
        dist_metric_norm_s{sb1,sb2} = dist_metric_s{sb1,sb2}./max_dist;
        dist_metric_norm_s{sb2,sb1} = dist_metric_norm_s{sb1,sb2};
    end
end
toc

sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm_s);

figure; imagesc(sum_dist); axis image; colorbar
set(gca,'tickDir','Out'); box off; xlabel('SB#'); ylabel('SB#'); title('Distances when arranged by leading channel');
figure; histogram(sum_dist(:),'Normalization','probability');
set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');



