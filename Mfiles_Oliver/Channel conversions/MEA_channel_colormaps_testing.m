%by means of a sample dataset, create channel conversions, from meabench to
%MCS linear. Then to 8x8 MEA grid, then generate a colormap of the MEA
%grid. If necessary, also make conversion to 6*10 MEA grid.

Dataset.name       = '24_09_08_1256_random_postburst.spike';
Dataset.CID        = 1256;
Dataset.DIV        = 99;   %to be corrected
Dataset.MEA        = 10470;
Dataset.MEA_grid  = 500;  %can be 200 (8x8 MEA) or 200 (6x10 MEA)
%
%and many more information
%

datname = Dataset.name;
%load the data
%ls_hw is the original data, with channel nos in hardware notation
ls_hw   = loadspike_longcutouts_noc_bigfiles(datname,2,25);

%make the conversion to MCS 8x8 LINEAR Electrode ID (i..e from 1:64)
[ls_lin_ch_id] = meab2lin_8x8_id(ls_hw);

%I can generate channelmaps for the 8x8 and 6x10 electrode layout
%this returns a 8x8 matrix with the linear electrode ID at the acc.
%position on the MEA grid
chmap_8x8_60 = channelmap8x8_60;

%for the 6x10 MEA
chmap_6x10_ch8x8_60 = channelmap6x10_ch8x8_60;



%I can also create colormaps for the respective electrode layout
%A colormap is actually nothing else than a (nr_channles,3)-dimensional
%matrix, where each row determines the value of red, green and blue to
%color the electrode
colmap_8x8_60 = colormap8x8_60;

%for the 6x10 MEA
colmap_6x10_ch8x8_60 = colormap6x10_ch8x8_60;


%plot simple colormaps for 8x8 and 6x10 MEAs

colmap_fig_h(1) = figure;

%plot the channelmap matrix with the imagesc function and use the
%respective colormap
image(chmap_8x8_60);
colormap(colmap_8x8_60);
title('8x8 MEA','Fontsize',14);
set(gca,'Tickdir','out');
axis square



colmap_fig_h(2) = figure;
%plot the channelmap matrix with the imagesc function for the 6x10 MEA and
%use the colormap for the 6x10 MEA

image(chmap_6x10_ch8x8_60);
colormap(colmap_6x10_ch8x8_60);
title('6x10 MEA','Fontsize',14);
set(gca,'Tickdir','out');
axis square


%make very easy statistic on the activity on the recorded electrodes in the
%dataset
%make a simple histogram on the no. of spieks on each channel (linear
%channel ID!) Every channel (ID) has its specific colpr
No_spikes_lin_ch = hist(ls_lin_ch_id.channel,1:64);

fig_h = figure;
for ii=1:64
    if ii>61
        bar_color = colmap_6x10_ch8x8_60(61,:);
    else
        bar_color = colmap_6x10_ch8x8_60(ii,:);
    end
    if No_spikes_lin_ch(ii)~=0
       bar(ii,No_spikes_lin_ch(ii),'FaceColor', bar_color,'Edgecolor',bar_color )
       hold on
    end
    
end

title({[datname];['no. of spikes']})
xlabel('linear channel ID');
ylabel('no of spikes')

%I can also generate an insert axes showing the Colormap
inlet_ax = axes('Position',[0.6 0.6 0.25 0.25]);
image(chmap_6x10_ch8x8_60);

