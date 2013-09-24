channelList = NB_slices{1}.channel;
dummy = zeros(10,6);
h=imagesc(dummy);
colormap(gray); colorbar;
set(gca, 'clim', [0 length(channelList)], 'tickdir', 'out');
axis square;
for  ii = 1: length(channelList)
    dummy(find(ch6x10_ch8x8_60 == channelList(ii)+1)) = ii;
    set(h, 'cdata', dummy);
    drawnow; pause(0.5);
end