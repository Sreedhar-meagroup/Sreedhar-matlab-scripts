function [colormap6x10_ch8x8_60]=colormap6x10_8x8_60(varargin)
% creates a colormap for the 6x10 matrix with electrode numbers from 1:60
% that reflect the SOURCECHANNELNUMBERs
%
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
% The color intensity can be set with the argument 'intensity' in the
% variable arguments list (negative values: increase light intensity,
% positive values: decrease light intensity)
%
% see also,
% colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap8x8_60,
% channelmap6x10_60colormap6x10_60,colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

intensity=1;
invert =0;
pvpmod(varargin);



colormap6x10_60  = zeros(60,3);
for ii=1:10, 
     for jj=1:6, 
%         channelmap6x10_60(ii,jj)=ii+(jj-1)*10; 
          colormap6x10_60(ii+(jj-1)*10,:)=colorcircle(ii,jj,10,6,'intensity',intensity,'invert',invert); 
     end; 
 end;

 
colormap6x10_ch8x8_60 = nan(size(colormap6x10_60)); %
colormap6x10_ch8x8_60(channelmap6x10_ch8x8_60,:) = colormap6x10_60;
colormap6x10_ch8x8_60 = [colormap6x10_ch8x8_60;~invert*ones(1,3)]; 

%the color for the reference id (no 4 here) is white [1 1 1]
colormap6x10_ch8x8_60(4,:) = [1 1 1];
%
