function [channelmap8x8_64]=channelmap8x8_64()
% creates a 8x8 matrix with electrode numbers from 1:64 
% (including the missing cornerelectrodes)
% MEA:
%      1     9    17    25    33    41    49    57
%      2    10    18    26    34    42    50    58
%      3    11    19    27    35    43    51    59
%      4    12    20    28    36    44    52    60
%      5    13    21    29    37    45    53    61
%      6    14    22    30    38    46    54    62
%      7    15    23    31    39    47    55    63
%      8    16    24    32    40    48    56    64
%
% you can use colormap8x8_64 to create a colormap this MEA matrix 
%
% see also,
% colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap8x8_60,
% channelmap6x10_60colormap6x10_60,colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

channelmap8x8_64=zeros(8); 
for ii=1:8, 
    for jj=1:8, 
        channelmap8x8_64(ii,jj)=ii+(jj-1)*8; 
    end; 
end;
