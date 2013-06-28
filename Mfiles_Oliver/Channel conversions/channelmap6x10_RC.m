function [channelmap6x10_RC]=channelmap6x10_RC()
% creates  the channelmap with row column index for 6x10MEAs
% MEA:
%  1    11    21    31    41    51
%  2    12    22    32    42    52
%  3    13    23    33    43    53
%  4    14    24    34    44    54
%  5    15    25    35    45    55
%  6    16    26    36    46    56
%  7    17    27    37    47    57
%  8    18    28    38    48    58
%  9    19    29    39    49    59
% 10    20    30    40    50    60
%
% you can use colormap6x10_60 to create a colormap for this MEA matrix 
%
% see also, colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap8x8_60
%           colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

channelmap6x10_RC= zeros(10,6);
for ii=1:10, 
     for jj=1:6, 
         channelmap6x10_RC(ii,jj)=str2num([num2str(jj) num2str(ii)]);
     end; 
 end;
channelmap6x10_RC(6)=nan;