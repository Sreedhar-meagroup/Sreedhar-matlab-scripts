ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
for ii= 1:1%length(rankList)
    HM= NaN(10,6);
    rList = rankList{ii};
for jj = 1 : length(rList)
    HM(ch6x10_ch8x8_60==rList(jj))=jj;
end
% all_HM(:,:,ii) = HM;


%subplot(4,7,ii)
h = figure;
HM = HM/size(rList,2);
imagescwithnan(HM,jet,[1 1 1]);
set(gca,'TickDir', 'out');
set(gca,'XTick',[],'YTick',[]);
%saveas(h,['figure-' num2str(ii),'.eps'],'psc2');
%close(h);
end

