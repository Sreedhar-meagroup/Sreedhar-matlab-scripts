function [channelmap6x10_ch8x8_60]=channelmap6x10_ch8x8_60()
% creates a 6x10 matrix with electrode numbers from 1:60
% the electrode numbers reflect the SOURCECHANNELNUMBERs
% MEA:
%     7    15    23    31    39    47
%    17    26    25    33    34    41
%     1    16    24    32    40    55
%     2     9     8    48    49    56
%     3    10    18    42    50    57
%     4    11    19    43    51    58
%     5    12    13    53    52    59
%     6    21    29    37    45    60
%    20    27    28    36    35    44
%    14    22    30    38    46    54
%
% you can use colormap6x10_ch8x8_60 to create a colormap this MEA matrix 
%
% see also,
% colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap8x8_60,
% channelmap6x10_60colormap6x10_60,colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60


% [6x10,8x8] % electrode assignement of 8x8 grid to 10x6 layout (10 rows, 6 columns)
MEA60=[[21,11];[33,12];[12,13];[13,14];[14,15];[15,16];[16,17];[17,18];[36,19];[28,10];[31,21];[44,22];[32,23];[23,24];[24,25];[25,26];[26,27];[37,28];[45,29];[38,20];[41,31];[43,32];[42,33];[22,34];[34,35];[35,36];[27,37];[47,38];[46,39];[48,30];[51,41];[53,42];[52,43];[72,44];[64,45];[65,46];[77,47];[57,48];[56,49];[58,40];[61,51];[54,52];[62,53];[73,54];[74,55];[75,56];[76,57];[67,58];[55,59];[68,50];[71,61];[63,62];[82,63];[83,64];[84,65];[85,66];[86,67];[87,68];[66,69];[78,60]];
en=num2str(MEA60(1:end,1)); %8x8
x=str2num(en(1:end,1));     %8x8
y=str2num(en(1:end,2));     %8x8
channelnumbers8x8_64=sub2ind([8,8],y,x);      %8x8

en2=num2str(MEA60(1:end,2));  %6x10
x2=str2num(en2(1:end,1));     %6x10
y2=str2num(en2(1:end,2));     %6x10
y2(find(y2==0))=10;
channelnumbers6x10_60=sub2ind([10,6],y2,x2);      %6x10

[temp,id]=sort(channelnumbers6x10_60); % they are sorted
channelmap6x10_ch8x8_64=channelnumbers8x8_64(id);


temp=1:64;
temp([1,8,57,64])=nan;
temp(find(~isnan(temp)))=1:60;
channelmap6x10_ch8x8_60=temp(channelmap6x10_ch8x8_64);

channelmap6x10_ch8x8_60(6)=4;
channelmap6x10_ch8x8_60=reshape(channelmap6x10_ch8x8_60,10,6);
