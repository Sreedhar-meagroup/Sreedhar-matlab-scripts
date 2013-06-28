%19/02/07
%This file loads big datafiles, without context and threshold values, 
% into one structure that has to be given as an output argument.
% This file is intended especially to read large datasets.
% This was necessary, becuase recent datafiles reached a size 
%(often upto 1.1GB) that I did not have before .




function spike_info=loadspike_samples(fn,range,freq);
% y=LOADSPIKE(fn) loads spikes from given filename into structure y
% with members
%   time    (1xN) (in samples)
%   channel (1xN)
%   height  (1xN)
%   width   (1xN)
%   context (75xN)
%   thresh  (1xN)
% y=LOADSPIKE(fn,range,freq_khz) converts times to seconds and width to
% milliseconds using the specified frequency, and the height and
% context data to microvolts by multiplying by RANGE/2048.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems 
% gain setting:
% 
% range value   electrode range (uV)    auxillary range (mV)
%      0               3410                 4092
%      1               1205                 1446
%      2                683                  819.6
%      3                341                  409.2
% 
% "electrode range" is applied to channels 0..59, auxillary range is
% applied to channels 60..63.
% In this case, the frequency is set to 25 kHz unless specified.

% matlab/loadspike.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



spike_info=struct('time',[],'channel',[], 'height',[], 'width',[]);

if nargin<2
  range=nan;
end
if nargin<3
  freq=nan;
end


reach=1500000;   %load reach no. of spikes

fid = fopen(fn,'rb');
if (fid<0)
  error('Cannot open the specified file');
end

fseek(fid,0,1);  %go to the end of file
len = ftell(fid);   %get the length of the file (in bytes)
fseek(fid,0,-1);   %go to the beginning again
no_spikes=len/264   %since every spike is stored as a 164byte vector

 

spikes_read=0;
read_cycle=0;
while spikes_read < no_spikes

    [raw count] = fread(fid,[7 reach],'7*int16',250);     
%A = fread(fid, count, precision, skip) includes an optional skip argument that specifies the number of bytes 
%to skip after each precision value is read. If precision specifies a bit format like 'bitN' or 'ubitN', the skip 
%argument is interpreted as the number of bits to skip. 
%fills an 132xinf matrix, where inf actually means until the end of file, i.e. the whole file
                                       % correct for that to read a file
                                       % only partially
                                       %'int16' is a data type specifier,
                                       %i.e. int with a size of 16 bits
                                       %(2byte)
spikes_read=spikes_read + count/7
%fprintf(2,'Spikeinfos read: %i\n' ,spikes_read);
read_cycle = read_cycle+1
filepos=ftell(fid);
fseek(fid,filepos,-1);


ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
y.channel = raw(5,:);
y.height = raw(6,:);
y.width = raw(7,:);
%y.context = raw(8:131,:);
%y.thresh = raw(132,:);

%the following part is for the case when a gain argument is given
if ~isnan(range)
  if ~isempty(find([0 1 2 3]==range))
    ranges= [ 3410,1205,683,341 ];
    range_elc = ranges(range+1);
    auxrange = range_elc*1.2;
    if isnan(freq)
      freq = 25.0;
    end
    isaux = find(y.channel>=60);
    iselc = find(y.channel<60);
    y.height(iselc) = y.height(iselc) .* range_elc/2048;
    %y.thresh(iselc) = y.thresh(iselc) .* range_elc/2048;
    %additional step since meabench stores the context in digital values
    %not realtive to zero but from 0 to max_range (no neg. values)
    y.height(isaux) = y.height(isaux) .* auxrange/2048;
    %y.thresh(isaux) = y.thresh(isaux) .* auxrange/2048;
  
  else
    y.height = y.height  .* range/2048;
    %y.thresh = y.thresh  .* range/2048;
  end
end    

if ~isnan(freq)
  y.time = y.time ./ (freq*1000);
  y.width = y.width ./ freq;
end


%create a new structure called spikeinfo and store the sequentially read
%data

    spike_info.time    = [spike_info.time,y.time];
    spike_info.channel = [spike_info.channel,y.channel];
    spike_info.height  = [spike_info.height,y.height];
    spike_info.width   = [spike_info.width,y.width];

    clear y ti0 ti1 ti2 ti3 iselc

end  %end of the while loop

fclose(fid);


fprintf(2,'The data was successfully read and stored in the workspace.\nNo threshold values were read from the raw data\n');

% for i=1:read_cycle
%     load(file_names{i})
%     spike_info(~mod(i,2)+1)=y
%     clear y
%     delete(file_names{i});
%     if ~mod(i,2)
%         save_struct=strcat(fn,'data_struct', num2str(i/2), '.mat');
%         save(save_struct, 'spike_info');
%         clear spike_info
%     elseif i==read_cycle
%         save_struct=strcat(fn,'data_struct', num2str((i-1)/2+1), '.mat');
%         save(save_struct, 'spike_info');
%         clear spike_info;
%     end
%     
% end
    
    
  
    

