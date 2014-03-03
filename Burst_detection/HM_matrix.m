HM= NaN(10,6);
rList = [14,53,26,33,21];

cords = [fix(rList/10)',mod(rList,10)'];
for ii = 1 : length(rList)
    HM(cords(ii,1),cords(ii,2))=ii;
end
figure;
h = imagescWithNaN(HM,jet,[1 1 1]);
set(gca,'TickDir', 'out');

