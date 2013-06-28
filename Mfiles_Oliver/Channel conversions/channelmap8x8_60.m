function [channelmap8x8_60]=channelmap8x8_60()
% creates a 8x8 matrix with electrode numbers from 1:60
% (including the missing cornerelectrodes that are set to 61)
% MEA:
%     61     7    15    23    31    39    47    61
%      1     8    16    24    32    40    48    55
%      2     9    17    25    33    41    49    56
%      3    10    18    26    34    42    50    57
%      4    11    19    27    35    43    51    58
%      5    12    20    28    36    44    52    59
%      6    13    21    29    37    45    53    60
%     61    14    22    30    38    46    54    61
%
% you can use colormap8x8_60 to create a colormap for this MEA matrix 
%
% see also, colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap6x10_60
%           colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

channelmap8x8_64=zeros(8); 
for ii=1:8, 
    for jj=1:8, 
        channelmap8x8_64(ii,jj)=ii+(jj-1)*8;
    end; 
end;
channelmap8x8_60=channelmap8x8_64;
channelmap8x8_60([1,8,57,64])=nan;
channelmap8x8_RC([1,8,57,64])=nan;
channelmap8x8_60(find(~isnan(reshape(channelmap8x8_60,1,64))))=1:60;
channelmap8x8_60=reshape(channelmap8x8_60,8,8);
channelmap8x8_60([1,8,57,64])=61;

