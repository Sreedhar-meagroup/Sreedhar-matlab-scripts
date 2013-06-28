function [colormap6x10_60]=colormap6x10_60(varargin)
% creates  a colormap with 60 entries (colors) that are assigned to
% electrodesnumbers from 1 to 60 for the 6x10 MEAs.
% Electrode enumeration is columnwise
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
% you can use channelmap6x10_60 to create this MEA matrix 
%
% The color intensity can be set with the argument 'intensity' in the
% variable arguments list (negative values: increase light intensity,
% positive values: decrease light intensity)
%
% see also colormap8x8_64,colormap8x8_60,channelmap8x8_64,channelmap8x8_60,channelmap6x10_60
%          colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

intensity=1;
invert = 0;
pvpmod(varargin);


colormap6x10_60  = zeros(60,3);
% channelmap6x10_60= zeros(10,6);
for ii=1:10, 
     for jj=1:6, 
%         channelmap6x10_60(ii,jj)=ii+(jj-1)*10; 
          colormap6x10_60(ii+(jj-1)*10,:)=colorcircle(ii,jj,10,6,'intensity',intensity,'invert',invert); 
     end; 
 end;
%cm=[[0,0,0];cm];
colormap6x10_60=[colormap6x10_60;~invert*ones(1,3)];