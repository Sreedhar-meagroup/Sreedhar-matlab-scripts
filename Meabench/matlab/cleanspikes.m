function [spks, idx] = cleanspikes(spikes, testidx, relthresh)
% This is a modified version of the earlier clean context fn, cleanctxt(). --
% SSK@22.07.2013
% [spks,idx] = CLEANSPIKES(spikes) returns cleaned up spikes and DC offset corrected spike contexts:
% SPIKES is the structure returned by loadspike('filename',2,25). Other
% arguments are optional.
% IDX is the ids of the selected spikes
% i)DC offset correction:
% - Twenty values around -1ms and 20 around +2 ms are 
%   averaged and used to compute DC offset.
% - These two estimates are weighted according to their inverse variance.
% - The DC offset is subtracted.

% ii) relthresh test (-1:-0.5ms and 0.5:1ms)
% - If any sample in the above mentioned interval is more than half the peak
%   the spike is rejected.
% - Use arguments testidx  and relthresh to modify this test:
%     TESTIDX are indices (1:124) of samples to implement the relthresh test.
%     default: testidx =  [[25:37] [63:75]];
%     RELTHRESH is a number between 0 and 1.
%     default: relthresh = 0.5;

% ii) 0.9 absolute level test (-1:-0.2ms and 0.2:1ms) 
% - If the above mentioned interval, has an absolute value more than 0.9 x the absolute peak
%   value. This test is modified on its outer edges by the edges of
%   testidx, but cannot be modified independently.

% Returns: spks: a structure similar to spikes, but with only the
% accepted spikes, with DC subtracted contexts.

% Requirements: spikes must be as read from loadspike('filename',2,25), i.e. 124xN (or
%          xN) with time in ms and voltage in the appropriate range.

% Acknowledgment: The algorithm implemented by this function is due to Partha P Mitra.

% Adapted from matlab/cleanctxt.m: part of meabench, an MEA recording and analysis tool
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


contexts = spikes.context;
if nargin<3
  relthresh = 0.5;
end
if nargin<2
  testidx = [25:37, 63:75];
end

abstestidx = 1:124;
abstestidx(1:min(testidx)-1)=0;
abstestidx(max(testidx)+1:124)=0;
abstestidx(45:55)=0;
abstestidx=abstestidx(abstestidx~=0);

N=size(contexts,2);
idx=zeros(1,N);
ctxts=zeros(124,N);

out = 0;

for in = 1:N
  first = contexts(15:35,in);
  last = contexts(40:60,in);
  dc1 = mean(first);
  dc2 = mean(last);
  v1 = var(first);
  v2 = var(last);
  dc = (dc1*v2+dc2*v1)/(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
  now = contexts(:,in) - dc;
  peak = mean(now(50:51));
  if peak<0
    bad = length(find(now(testidx) <= relthresh*peak));
  else
    bad = length(find(now(testidx) >= relthresh*peak));
  end
  if bad == 0
    bad = length(find(abs(now(abstestidx)) >= 0.9*abs(peak)));
  end
  if bad == 0
    out = out+1;
    ctxts(:,out) = now;
    idx(:,out) = in;
  end
end
ctxts=ctxts(:,1:out);
idx=idx(1:out);

spks.time = spikes.time(idx);
spks.channel = spikes.channel(idx);
spks.height = spikes.height(idx);
spks.width = spikes.width(idx);
spks.context = ctxts;
spks.thresh = spikes.thresh(idx);