function [colormap8x8_64]=colormap8x8_64(varargin)
% creates  a colormap with 64 entries (colors) that are assigned to
% electrodesnumbers from 1 to 64 for the 8x18 MEAs.
% The missing cornerelectrodes are set to white
% Electrode enumeration is columnwise
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
% you can use colormap8x8_64 to create this MEA matrix 
%
% The color intensity can be set with the argument 'intensity' in the
% variable arguments list (negative values: increase light intensity,
% positive values: decrease light intensity)
%
% see also colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap,8x8_60,channelmap6x10_60colormap6x10_60
%          colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60

% channelmap6x10_60= zeros(10,6);
% for ii=1:10, 
%      for jj=1:6, 
%          channelmap6x10_60(ii,jj)=ii+(jj-1)*10; 
%          colormap6x10_60(ii+(jj-1)*10,:)=colorcircle(ii,jj,10,6); 
%      end; 
%  end;
% %cm=[[0,0,0];cm];
% colormap6x10_60(5,:)=ones(1,3);
%

intensity=1;
invert = 0;

pvpmod(varargin);

colormap8x8_64=zeros(64,3); 
% channelmap8x8_64=zeros(8); 
for ii=1:8, 
    for jj=1:8, 
%         channelmap8x8_64(ii,jj)=ii+(jj-1)*8; 
        colormap8x8_64(ii+(jj-1)*8,:)=colorcircle(ii,jj,8,8,'intensity',intensity,'invert',invert); 
    end; 
end;
colormap8x8_64([1,8,57,64],:)=~invert*ones(4,3);
% colormap8x8_60=colormap8x8_64(setdiff([1:64],[1,8,57,64]),:);
% channelmap8x8_60=channelmap8x8_64;
% channelmap8x8_60([1,8,57,64])=nan;
% channelmap8x8_60(find(~isnan(reshape(channelmap8x8_60,1,64))))=1:60;
% channelmap8x8_60=reshape(channelmap8x8_60,8,8);
