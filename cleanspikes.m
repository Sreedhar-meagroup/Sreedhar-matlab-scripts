function [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh, testidx, relthresh)
% This is a modified version of the earlier clean context fn, cleanctxt(). --
% SSK@22.07.2013
% [spks,idx] = CLEANSPIKES(spikes) returns cleaned up spikes and DC offset corrected spike contexts:
% SPIKES is the structure returned by loadspike('filename',2,25). Other
% arguments are optional.
% THRESH is specified in terms of no: of times of the estimated rms
% noise. This should match the thresh set for the recording.
% IDX is the ids of the selected spikes
% i) relthresh test (-1:-0.5ms and 0.5:1ms)
% - If any sample in the above mentioned interval is more than half the peak
%   the spike is rejected.
% - Use optional arguments testidx and relthresh to modify this test:
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
if nargin<4
  relthresh = 0.5;
end
if nargin<3
  testidx = [25:37, 63:75];
end
absthresh = 0.9;
abstestidx = 1:124;
abstestidx(1:min(testidx)-1)=0;
abstestidx(max(testidx)+1:124)=0;
abstestidx(45:55)=0;
abstestidx=abstestidx(abstestidx~=0);

N=size(contexts,2);
idx=zeros(1,N);
ctxts=zeros(124,N);

out = 0;

h = waitbar(0,'Cleaning artifacts...');
for in = 1:N
  
% switch between these two lines to enable/disable offset correction
%     now = offset_correction(contexts(:,in));
  now = contexts(:,in);
  
    peak = mean(now(50:51));
  
 % this test discards the analog channels and the signtest() determines if the signs of the peak and the threshold match.
 bad = or(discard_analog_channels(spikes.channel(in)), signtest(peak, spikes.thresh(in)));
 
 
  if ~bad
      if peak<0
          bad = length(find(now(testidx) <= relthresh*peak));
          if bad
             breach = testidx(now(testidx) <= relthresh*peak);
            % The outer breach test
             breach_pre  = breach(breach<50);
             breach_post = breach(breach>=50);
             
             if breach_pre
                 if abs(peak-max(now(breach_pre(end):50)))> (thresh-1)*spikes.thresh(in)/thresh;
                    bad = 0;
                 end
             end
             
            if breach_post
                if abs(peak-max(now(50:breach_post(1))))> (thresh-1)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
            
          end
% 
%              if breach(1)> 50
% %                 if abs(peak-max(now(50:63+breach(1)-13)))> 6*spikes.thresh(in)/thresh;
%                  if abs(peak-max(now(50:breach(1))))> 6*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end
%             else
%                 if abs(peak-max(now(25+breach(end):50)))> 6*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end                
%             end
%             
            
            
          
      else % for the positive peak
          bad = length(find(now(testidx) >= relthresh*peak));
          if bad
             breach = testidx(now(testidx) >= relthresh*peak);
            % The outer breach test
             breach_pre  = breach(breach<50);
             breach_post = breach(breach>=50);
             
             if breach_pre
                 if abs(peak-min(now(breach_pre(end):50)))> (thresh-1)*spikes.thresh(in)/thresh;
                    bad = 0;
                 end
             end
             
            if breach_post
                if abs(peak-min(now(50:breach_post(1))))> (thresh-1)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
            
          end
          
          
          
%           bad = length(find(now(testidx) >= relthresh*peak));
%           if bad
%             breach = find(now(testidx) >= relthresh*peak);
%             if breach(1) > 50
%                 if abs(peak-min(now(50:63+breach(1)-13)))> 6*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end
%             else
%                 if abs(peak-min(now(25+breach(end):50)))> 6*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end                
%             end                
%           end      
      end
  end
  
  if ~bad
      if peak<0
          bad = length(find(now(abstestidx) <= absthresh*peak));
          if bad
            breach = abstestidx(now(abstestidx) <= absthresh*peak);
             % The inner breach test
             breach_pre  = breach(breach < 50);
             breach_post = breach(breach >= 50);
            if breach_pre
                if abs(peak-max(now(breach_pre(end):50))) > (thresh-4)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
            
            if breach_post
                if abs(peak-max(now(50:breach_post(1))))> (thresh-4)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
          end
             
                 
             
             
%             if breach(1) > 50
%                 if abs(peak-max(now(50:55+breach(1)-20)))> 3*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end
%             else
%                 if abs(peak-max(now(25+breach(end):50)))> 3*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end                
%             end      
%           end     
      else
          bad = length(find(now(abstestidx) >= absthresh*peak));
          if bad
            breach = abstestidx(now(abstestidx) >= absthresh*peak);  
%             breach = find(now(abstestidx) >= absthresh*peak);

             % The inner breach test
             breach_pre  = breach(breach < 50);
             breach_post = breach(breach >= 50);
            if breach_pre
                if abs(peak-min(now(breach_pre(end):50))) > (thresh-4)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
            
            if breach_post
                if abs(peak-min(now(50:breach_post(1))))> (thresh-4)*spikes.thresh(in)/thresh;
                    bad = 0;
                end
            end
%             if breach(1) > 50
%                 if abs(peak-min(now(50:55+breach(1)-20)))> 3*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end
%             else
%                 if abs(peak-min(now(25+breach(end):50)))> 3*spikes.thresh(in)/thresh;
%                     bad = 0;
%                 end                
%             end      
          end  
      end  
  end
  
  if ~bad
    out = out+1;
    ctxts(:,out) = now;
    idx(:,out) = in;
  end
  
  if ~mod(in,1e2)
    waitbar(in/N);
  end
end
close(h);
ctxts=ctxts(:,1:out);
selIdx=idx(1:out);

spks.time = spikes.time(selIdx);
spks.channel = spikes.channel(selIdx);
spks.height = spikes.height(selIdx);
spks.width = spikes.width(selIdx);
spks.context = ctxts;
spks.thresh = spikes.thresh(selIdx);

disp(['Percentage of spikes removed: ',num2str(100*(length(spikes.time)-length(spks.time))/length(spikes.time)), '%']);

allIdx = 1:length(spikes.time);
stimIdx = find(spikes.channel>=60);
rejIdx = allIdx(and(~ismember(allIdx,stimIdx),~ismember(allIdx,idx)));
end

function bad = signtest(peak, thresh)
bad = 0;
   if peak<0
        if peak > -thresh
            bad = 1;
        end
    else
        if peak < thresh
            bad = 1;
        end
   end
end

function bad = discard_analog_channels(channel)
bad = 0;
    if channel > 59
        bad = 1;
    end
end

function now = offset_correction(contexts)
  first = contexts(1:15);
  last  = contexts(109:end);
  dc1   = mean(first);
  dc2   = mean(last);
  v1    = var(first);
  v2    = var(last);
  dc    = (dc1*v2+dc2*v1)/(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
  now   = contexts - dc;
end
    
    
    
