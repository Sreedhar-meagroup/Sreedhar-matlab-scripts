function EvRO = Evoked_rankorder(stim_data)
resp_slices       = stim_data.Responses.resp_slices;
resp_meamat       = cell(1,5);
resp_meamat_norm  = cell(1,5);
firsts            = cell(1,5);
lasts             = cell(1,5);
RanksperResp      = cell(1,5);
meamap            = channelmap6x10_ch8x8_60;
chanList_detailed = cell(1,5);
chanList_brief    = cell(1,5);
matWithRanks      = cell(1,5);
dist_metric = cell(1,5);
dist_metric_norm = cell(1,5);


for site=1:length(stim_data.Electrode_details.stim_electrodes)
    noresp{site} = find(sum(stim_data.Responses.resp_lengths{site})==0);
    matWithRanks{site} = zeros(60,length(resp_slices{site}));
for ii = 1:length(resp_slices{site})
%     if ~any(ii == noresp{site})
    chanList_detailed{site}{ii} = resp_slices{site}{ii}.channel+1;
    chanList_brief{site}{ii} = unique_us(chanList_detailed{site}{ii});
    chanList_brief{site}{ii} = [cr2hw(stim_data.Electrode_details.stim_electrodes(site))+1, chanList_brief{site}{ii}];
    matWithRanks{site}(chanList_brief{site}{ii},ii) = 1:length(chanList_brief{site}{ii});
    [fr, fc] = find(meamap == (cr2hw(stim_data.Electrode_details.stim_electrodes(site))+1));
    resp_meamat{site}(fr,fc,ii) = 1;
    for jj = 1:length(chanList_brief{site}{ii})
        [r, c] = find(meamap == chanList_brief{site}{ii}(jj));
        resp_meamat{site}(r,c,ii) = jj+1;
        
        if jj == length(chanList_brief{site}{ii})
            lasts{site}(ii,:) = [r,c];
        end
    end
    if isempty(jj)
        jj = 1;
    end
    resp_meamat_norm{site}(:,:,ii) = resp_meamat{site}(:,:,ii)./jj;
    RanksperResp{site}(chanList_brief{site}{ii},ii) = 1:length(chanList_brief{site}{ii});
%     end
end

resp_meamat_norm{site}(resp_meamat_norm{site}==0) = NaN;




%% figure 1
% figure; count = 1;
% make_it_tight = true;
% subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.1 0.01], [0.01 0.01]);
% if ~make_it_tight,  clear subplot;  end
% for ii = 1:5
%     for jj = 1:10
%        x = subplot(5,10,count);
%        if length(find(~isnan(resp_meamat_norm{site}(:,:,count))))>1
%        imagescwithnan(resp_meamat_norm{site}(:,:,count),jet,[1,1,1]); axis image;
%        set(gca,'TickDir','Out','xTickLabel',[],'yTickLabel',[]);
%        text(fc,fr,'F','color','y','HorizontalAlignment','center','VerticalAlignment','middle');
%        text(lasts{site}(count,2),lasts{site}(count,1),'L','color','y','HorizontalAlignment','center','VerticalAlignment','middle');
%        else
%            delete(x);
% %            axis image;
% %            set(gca,'xTick',[],'yTick',[]);
%        end
%        count = count+1;
%        if count == length(resp_slices{site}) - length(noresp{site})
%            break
%        end
%     end
% end


%% Distance metric responses in order
max_dist = sqrt((diff([1 10]).^2+diff([1 6]).^2));
tic
for resp1 = 1:length(resp_slices{site})
    for resp2 = resp1:length(resp_slices{site})
        for ii = 1:min(length(chanList_brief{site}{resp1}),length(chanList_brief{site}{resp2}))
            if ii>1
            [r, c] = find(resp_meamat{site}(:,:,[resp1,resp2])==ii);
            dist_metric{site}{resp1,resp2}(ii) = sqrt((diff(r).^2+(diff(c)-6).^2));
            end
        end
        if ii>1
        dist_metric_norm{site}{resp1,resp2} = dist_metric{site}{resp1,resp2}./max_dist;
        dist_metric_norm{site}{resp2,resp1} = dist_metric_norm{site}{resp1,resp2};
        end
        
    end
end  
toc
if size(dist_metric_norm{site},2)<50
    dist_metric_norm{site}{1,50} = [];
    dist_metric_norm{site}{50,1} = [];
end

sum_dist = cellfun(@(x) sum(x)/length(x),dist_metric_norm{site});
trimmed_sd = sum_dist;
trimmed_sd(:,noresp{site}) = [] ;
trimmed_sd(noresp{site},:) = [] ;
% figure; imagesc(sum_dist); axis image; colormap(bone);colorbar;
% xlabel('SB #'); ylabel('SB #'); title('Sum of distances in Resp ranks');
% set(gca,'tickDir','Out'); box off;
% figure; histogram(sum_dist(:),'Normalization','probability');
% set(gca,'tickDir','Out'); box off; xlabel('Distances'); ylabel('p'); title('Distribution of distances');

end

EvRO.noresp = noresp;
EvRO.chanList_brief = chanList_brief;
EvRO.dist_metric_norm = dist_metric_norm;
EvRO.Ranklist = matWithRanks;