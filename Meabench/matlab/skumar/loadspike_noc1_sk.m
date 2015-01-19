% -------------------------------------------------------------------------------------
% MATLAB Version 7.12.0.635 (R2011a)
% MATLAB License Number: 97144
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% MATLAB                                                Version 7.12       (R2011a)
% Simulink                                              Version 7.7        (R2011a)
% Data Acquisition Toolbox                              Version 2.18       (R2011a)
% Fixed-Point Toolbox                                   Version 3.3        (R2011a)
% Image Processing Toolbox                              Version 7.2        (R2011a)
% MATLAB Compiler                                       Version 4.15       (R2011a)
% Neural Network Toolbox                                Version 7.0.1      (R2011a)
% Parallel Computing Toolbox                            Version 5.1        (R2011a)
% Signal Processing Toolbox                             Version 6.15       (R2011a)
% Statistics Toolbox                                    Version 7.5        (R2011a)
% Wavelet Toolbox                                       Version 4.7        (R2011a)

function y=loadspike_noc1_sk(fn,range,freq)
% y=LOADSPIKE_NOC1_SK(fn) loads spikes WITHOUT CONTEXT from given filename
% as a single chunk into structure y with members (may not be suitable for
% huge data files (cf. loadspike_noc2_sk.m))
%   time    (1xN) (in samples)
%   channel (1xN)
%   height  (1xN)
%   width   (1xN)
%   thresh  (1xN)
% y=LOADSPIKE(fn,range,freq_khz) converts times to seconds and width to
% milliseconds using the specified frequency, and the height and
% context data to microvolts by multiplying by RANGE/2048.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems 
% gain setting:
% (@SK: we use range=2, freq_khz = 25)
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


%31/10/06
%the file loadspike was changed in order to be able to give  one, two
%or three parameters. each option imports and converts the data differently
%one parameter = only datname: no conversion of time and voltage
%two parameter = datname & gain: electrode voltage is transfered to uv
% three paramter = datname & gain & samplfreq: as with 2 para, but also % time is converted to seconds
%13/11/06 
%changed this file because from now on, Itry to record with longer cutouts,
%i.e 2 ms pre and 3 ms post. this was lready changed in the meabench
%package, now the according changes have to be made in the matlab files.
%what is recorde now are 50+74=124 values for the cutouts and the remaining
%8 values for the rest (height, width, time,...) this has to be changed
%here (124+8=132)
%worked with test spikes on dummy without problems. however, there is now
%more overload during an experiment (spikedet has to keep up with storing
%the cutouts) and it is not sure how this will affect the performance

% 03/11/14: This is the script to use to load normal sized files along with context

if nargin<2
  range=nan;
end
if nargin<3
  freq=nan;
end

fid = fopen(fn,'rb');
if (fid<0)
  error('Cannot open the specified file');
end
raw = fread(fid,[132 inf],'int16');     %fills an 82xinf matrix, where inf actually means until the end of file, i.e. the whole file
                                       % correct for that to read a file
                                       % only partially
                                       %'int16' is a data type specifier,
                                       %i.e. int with a size of 16 bits
                                       %(2byte)
fclose(fid);
ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
y.channel = raw(5,:);
y.height = raw(6,:);
y.width = raw(7,:);
% y.context = raw(8:131,:);
y.thresh = raw(132,:);

%the following part is for the case when a gain argument is given
if ~isnan(range)
  if ~isempty(find([0 1 2 3]==range))
    ranges= [ 3410,1205,683,341 ];
    range = ranges(range+1);
    auxrange = range*1.2;
    %if isnan(freq)
     % freq = 25.0;
    %end
    isaux = find(y.channel>=60);
    iselc = find(y.channel<60);
    y.height(iselc) = y.height(iselc) .* range/2048;
    y.thresh(iselc) = y.thresh(iselc) .* range/2048;
%     y.context(:,iselc) = y.context(:,iselc) .* range/2048;
%     y.context = y.context-range; %uncomment to change to 683 shift spike contexts
    y.height(isaux) = y.height(isaux) .* auxrange/2048;
    y.thresh(isaux) = y.thresh(isaux) .* auxrange/2048;
%     y.context(:,isaux) = y.context(:,isaux) .* auxrange/2048;
  else
    y.height = y.height  .* range/2048;
    y.thresh = y.thresh  .* range/2048;
%     y.context= y.context .* range/2048;
  end
end    


%this is the part where it imports data without any conversion of the time
%or voltage, i.em when no argument is given
if ~isnan(freq)
  y.time = y.time ./ (freq*1000);
  y.width = y.width ./ freq;
end

% Uncomment this section to use computed dc shifting instead of a 683 shift
% (see line 123)
%   first=y.context(1:15,:);
%   last= y.context(110:124,:);
%   dc1=mean(first);
%   dc2=mean(last);
%   v1=var(first);
%   v2=var(last);
%   dc=(dc1.*v2+dc2.*v1)/(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
%   y.context=y.context - dc; 
