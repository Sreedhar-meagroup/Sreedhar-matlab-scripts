function cleanid = cleandata_removeartifacts(SPIKETIME,SPIKECHANNEL,varargin)
% Remove artifacts that show up as
% synchronous spike times in spike train data
%
%============INPUT==============
%
% SPIKETIME:         vector with spike times
% SPIKECHANNEL:      vector with start_time times of periods to delete
%
%=========OPTIONAL INPUT========
%
% synch_level:             fraction of electrodes showing synchrony threshold
%   default = 0.5;          
% synch_precision:   time precision of synchrony
%   default = 20;    (20mus sampling interval);      
%
%============OUTPUT=============
%
% cleanid = boolean vector marking  entries that match the
%           requirements
%
% ==============================
% 09/03/13 Okujeni
% 
%
synch_level = 0.5;
NAC = length(unique(SPIKECHANNEL));
synch_precision = 40; %mus
%
pvpmod(varargin);
%synch_precision (2ms) precision spike train
ST=round(SPIKETIME/synch_precision); 
STunique=unique(ST);
[a,pos]=ismember(ST,STunique);
 % filter: take care of jitter by rounding procedure
synch = STunique(filter(ones(3,1),1,histc(pos,1:length(STunique)))>synch_level*NAC);
synch = [synch-synch_precision,synch,synch+synch_precision];
% index shifted by 1?
cleanid = ~ismember(ST,synch);