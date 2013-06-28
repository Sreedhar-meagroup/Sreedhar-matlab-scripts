function [channelmap8x8_RC]=channelmap8x8_RC()
% creates a 8x8 matrix with electrode numbers as row column index
% MEA:
%    NaN    21    31    41    51    61    71   NaN
%     12    22    32    42    52    62    72    82
%     13    23    33    43    53    63    73    83
%     14    24    34    44    54    64    74    84
%     15    25    35    45    55    65    75    85
%     16    26    36    46    56    66    76    86
%     17    27    37    47    57    67    77    87
%    NaN    28    38    48    58    68    78   NaN
%
% see also, colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap6x10_60
%           colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

channelmap8x8_RC=zeros(8); 
for ii=1:8, 
    for jj=1:8, 
        channelmap8x8_RC(ii,jj)=ii+10*jj;
    end; 
end;
channelmap8x8_RC([1,8,57,64])=nan;

