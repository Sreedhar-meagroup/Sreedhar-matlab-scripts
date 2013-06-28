%%% Colorfull exploration of the "MEA distance space"
%%% 
%%% Illustration of the Discussion on Thu Feb 22 07
%%% Rmeier 





MEA=reshape([1:64],8,8);

REF=1 % for an electrode 
[XREF,YREF]=ind2sub([8 8],find(MEA==REF));

for ii=1:length(MEA(:))

     [x,y] = ind2sub([8 8],find(MEA==ii)) 
d(ii)= sqrt((XREF -x)^2 +(YREF -y)^2 );



end

figure;
imagesc(reshape(d,8,8))
figure; plot(sort(d))
%% Center as REF

XREF=4.5 ;YREF=4.5;
for ii=1:length(MEA(:))

     [x,y] = ind2sub([8 8],find(MEA==ii)) 
d(ii)= sqrt((XREF -x)^2 +(YREF -y)^2 );



end

figure;

imagesc(reshape(d,8,8))
figure; plot(sort(d))


% Paris as reference 


XREF=-100.3 ;YREF=64.2;
for ii=1:length(MEA(:))

     [x,y] = ind2sub([8 8],find(MEA==ii)) 
d(ii)= sqrt((XREF -x)^2 +(YREF -y)^2 );



end

figure;

imagesc(reshape(d,8,8))
figure; plot(sort(d))


