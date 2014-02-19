%% setting datName, pathName to run stimAnalysisv3 / spontaneousData
datName = '131011_4350_spontaneous1.spike';
pathName = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\Spontaneous\';
respTriplet = [6 36 45] - 1; % hw+1 to hw

%% spont trajectory
 spontaneousData

summed_effect = cell(size(NB_ends,1),1);

% Choosing 50 longest NBs
[~, longNBind] = sort(NB_ends-mod_NB_onsets,'descend');

for kk =  20%[10 15 20 25]; %
    h2 = figure();
    binSize = 10;
    c = varycolor(50);
    colormap(c);
    for jj = 1:50%size(NB_ends,1)
        binned = (mod_NB_onsets(longNBind(jj))*1e3:binSize:NB_ends(longNBind(jj))*1e3) - mod_NB_onsets(longNBind(jj))*1e3;
        coords = zeros(3,length(binned));
        
        for ii = 1:3
            resp = (NB_slices{longNBind(jj)}.time(NB_slices{longNBind(jj)}.channel == respTriplet(ii)) - NB_slices{longNBind(jj)}.time(1))*1e3;
            [counts,timeVec] = hist(resp,binned);
            coords(ii,:) = counts;
        end
        
        trialsmooth_mod;
        summed_effect{jj} = sy;
    end
 
    colorbar;
    set(gca,'FontSize',14);
    title(['Trajectories with bin-size = ', num2str(kk),'ms'], 'FontSize',14);
%      saveas(h2,['C:\Users\duarte\Desktop\fig_traj\131011_4350\trajFWHM8_',num2str(kk),'ms.eps'], 'psc2');
%      close(h2);
end


 %% PCA

for ii = 1:50
    X = summed_effect{ii}';
    [coeff{ii}, score{ii}, latent{ii}, ~,explained{ii},mu{ii}] = pca(X);
end

h1d = figure;
hold on;
h2d = figure;
hold on;
colormap(c)
for ii = 1:50
    figure(h1d);
    plot(score{ii}(:,1),'LineWidth',2,'Color',c(ii,:));
    figure(h2d);
    plot(score{ii}(:,1),score{ii}(:,2),'LineWidth',2,'Color',c(ii,:));
end
figure(h1d);
colorbar;
figure(h2d);
colorbar;

score_mat(isnan(score_mat)) = 0;
[max_val,max_ind] = max(score_mat,[],2);


figure;
plot(find(max_ind>1),max_ind(max_ind>1),'.','MarkerSize',7);
xlabel('Trial #');
ylabel('Peak of PCA1');

silence_b4 = silence_s{5}([6,36,45],:)'; %old 50x3 matrix
mean_sil_b4 = mean(silence_b4,2);
max_sil_b4 = max(silence_b4,[],2);
min_sil_b4 = min(silence_b4,[],2);

figure;
plot(mean_sil_b4(max_ind>1),max_ind(max_ind>1),'.','MarkerSize',15);
xlabel('Mean pre-stimulus inactivity [s]');
ylabel('Peak of PCA1');
% 
