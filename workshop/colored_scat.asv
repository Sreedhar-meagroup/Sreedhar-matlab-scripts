%% option 1 in a loop
cmap = varycolor(max(respLengths_n)+1);
figure(); 
hold on; 
for ii = 1:length(silence_s)
    plot(ii, silence_s(ii),'o','MarkerEdgeColor','w','MarkerFaceColor',cmap(respLengths_n(ii)+1,:)); 
end
colormap(cmap);
colorbar;

%% option 2 using scatter
[x, x_ind] = sort(respLengths_n);
cmap = varycolor(max(respLengths_n)+1);
cmap2 = cmap(x+1,:);
figure();
scatter(x_ind,silence_s(x_ind),10,cmap(x+1,:),'fill');
colormap(cmap);
hcb = colorbar;

%% another method
sil_disc_bins = 0:dt:ceil(max(silence_s));
stimNosForASilBin = cell(size(sil_disc_bins));
final_mat = NaN(length(sil_disc_bins),length(stimTimes));
for ii = 1: length(sil_disc_bins)
    stimNosForASilBin{ii} = find(silence_s >= sil_disc_bins(ii)-dt/2 & silence_s < sil_disc_bins(ii)+ dt/2);
    final_mat(ii,stimNosForASilBin{ii}) = respLengths_n(stimNosForASilBin{ii});
end

cmap = varycolor(max(respLengths_n)+1);
figure;
imagescWithNaN( final_mat,cmap,[1 1 1]);
