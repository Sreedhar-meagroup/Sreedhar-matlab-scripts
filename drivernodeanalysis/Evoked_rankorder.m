% function Evoked_rankorder(stim_data)
resp_slices       = stim_data.Responses.resp_slices;
resp_meamat       = cell(1,5);
resp_meamat_norm    = cell(1,5);
firsts            = cell(1,5);
lasts             = cell(1,5);
RanksperResp      = cell(1,5);
meamap            = channelmap6x10_ch8x8_60;
chanList_detailed = cell(1,5);
chanList_brief    = cell(1,5);

for site=2:2
for ii = 1:length(resp_slices{site})
    chanList_detailed{site}{ii} = resp_slices{site}{ii}.channel+1;
    chanList_brief{site}{ii} = unique_us(chanList_detailed{site}{ii});
    
    [fr, fc] = find(meamap == (cr2hw(stim_data.Electrode_details.stim_electrodes(site))+1));
    resp_meamat{site}(fr,fc,ii) = 1;
    for jj = 1:length(chanList_brief{site}{ii})
        [r, c] = find(meamap == chanList_brief{site}{ii}(jj));
        resp_meamat{site}(r,c,ii) = jj+1;
        if jj == 1
            firsts{site}(ii,:) = [r,c];
        elseif jj == length(chanList_brief{site}{ii})
            lasts{site}(ii,:) = [r,c];
        end
    end
    if isempty(jj)
%         resp_meamat{site}(:,:,ii) = zeros(10,6);
        jj = 1;
    end
    resp_meamat_norm{site}(:,:,ii) = resp_meamat{site}(:,:,ii)./jj;
    RanksperResp{site}(chanList_brief{site}{ii},ii) = 1:length(chanList_brief{site}{ii});
end

% SB_meamat(SB_meamat==0) = NaN;
resp_meamat_norm{site}(resp_meamat_norm{site}==0) = NaN;



% [LCperSB, ~] = find(RanksperResp{site}==1); % LC == leading channel (channel with rank 1 in each burst)
% nSBsfromEachCh = hist(LCperSB,1:60);
% [sortednSBs,LCsorted] = sort(nSBsfromEachCh,'descend');
% SB_hs2cs = []; % this part will arrange the indices of the SBs initiated from hotspots outwards.
% for ii = 1:length(LCsorted)
%     SB_hs2cs = [SB_hs2cs,find(RanksperSB(LCsorted(ii),:) == 1)]; 
% end



figure; count = 1;
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.1 0.01], [0.01 0.01]);
if ~make_it_tight,  clear subplot;  end
for ii = 1:5
    for jj = 1:10
       x = subplot(5,10,count);
       if length(find(~isnan(resp_meamat_norm{site}(:,:,count))))>1
       imagescwithnan(resp_meamat_norm{site}(:,:,count),jet,[1,1,1]); axis image;
       set(gca,'TickDir','Out','xTickLabel',[],'yTickLabel',[]);
       text(fc,fr,'F','color','y','HorizontalAlignment','center','VerticalAlignment','middle');
       text(lasts{site}(count,2),lasts{site}(count,1),'L','color','y','HorizontalAlignment','center','VerticalAlignment','middle');
       else
           delete(x);
%            axis image;
%            set(gca,'xTick',[],'yTick',[]);
       end
       count = count+1;
    end
end

end
% 
% %% Distance metric all bursts in natural order
% dist_metric = cell(length(NB_slices));
% dist_metric_norm = cell(length(NB_slices));
% max_dist = sqrt((diff([1 10]).^2+diff([1 6]).^2));
% tic
% for sb1 = 1:length(NB_slices)
%     for sb2 = sb1:length(NB_slices)
%         for ii = 1:min(length(chanList_brief{sb1}),length(chanList_brief{sb2}))
%             [r, c] = find(SB_meamat(:,:,[sb1,sb2])==ii);
%             dist_metric{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
%         end
%         dist_metric_norm{sb1,sb2} = dist_metric{sb1,sb2}./max_dist;
%         dist_metric_norm{sb2,sb1} = dist_metric_norm{sb1,sb2};
%     end
% end
% toc
% sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm);
% 
% figure; imagesc(sum_dist); axis image; colormap(bone);colorbar;
% xlabel('SB #'); ylabel('SB #'); title('Sum of distances in SB ranks');
% figure; histogram(sum_dist(:),'Normalization','probability');
% set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');
% 
% 
% %% Distance metric bursts from a single channel
% 
% tic
% SBsFromACh = SB_hs2cs(1:sortednSBs(1));
% for sb1 = 1:length(SBsFromACh)
%     for sb2 = sb1:length(SBsFromACh)
%         for ii = 1:min(length(chanList_brief{SBsFromACh(sb1)}),length(chanList_brief{SBsFromACh(sb2)}))
%             [r, c] = find(SB_meamat(:,:,[SBsFromACh(sb1),SBsFromACh(sb2)])==ii);
%             dist_metric_1ch{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
%         end
%         dist_metric_norm_1ch{sb1,sb2} = dist_metric_1ch{sb1,sb2}./max_dist;
%         dist_metric_norm_1ch{sb2,sb1} = dist_metric_norm_1ch{sb1,sb2};
%     end
% end
% toc
% 
% sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm_1ch);
% 
% figure; imagesc(sum_dist); axis image; colormap(bone);colorbar;
% set(gca,'tickDir','Out'); box off; xlabel('SB #'); ylabel('SB #'); 
% title('Sum of distances in SBs initiating from a channel ');
% figure; histogram(sum_dist(:),'Normalization','probability');
% set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');
% 
% %% Distance metric all bursts sorted by leading channel
% tic
% for sb1 = 1:length(SB_hs2cs)
%     for sb2 = sb1:length(SB_hs2cs)
%         for ii = 1:min(length(chanList_brief{SB_hs2cs(sb1)}),length(chanList_brief{SB_hs2cs(sb2)}))
%             [r, c] = find(SB_meamat(:,:,[SB_hs2cs(sb1),SB_hs2cs(sb2)])==ii);
%             dist_metric_s{sb1,sb2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
%         end
%         dist_metric_norm_s{sb1,sb2} = dist_metric_s{sb1,sb2}./max_dist;
%         dist_metric_norm_s{sb2,sb1} = dist_metric_norm_s{sb1,sb2};
%     end
% end
% toc
% 
% sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm_s);
% 
% figure; imagesc(sum_dist); axis image; colormap(bone);colorbar;
% set(gca,'tickDir','Out'); box off; xlabel('SB #'); ylabel('SB #'); 
% title('Sum of distances when arranged by leading channel');
% figure; histogram(sum_dist(:),'Normalization','probability');
% set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');
% 
% 
% 
% %% Distance metric all bursts sorted by leading channel; except first one
% 
% sum_dist = cellfun(@(x) sum(x(2:end))/(length(x)-1),dist_metric_norm_s);
% figure; imagesc(sum_dist); axis image; colormap(bone);colorbar;
% set(gca,'tickDir','Out'); box off; xlabel('SB #'); ylabel('SB #'); 
% title('\Sigma distances arranged by leading channel except rank 1');
% figure; histogram(sum_dist(:),'Normalization','probability');
% set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');
% 
% 
% 
% %%
