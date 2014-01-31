function spks = cleandata_artifacts_sk(spks,varargin)
% Remove artifacts that show up as
% synchronous spike times in spike train data
%
%============INPUT==============
% SPKS :            The meabench struct with all the classic fields.
% The following original variables shall be extracted from the above struct
%
%=========OPTIONAL INPUT========
%
% synch_level:             fraction of electrodes showing synchrony threshold
%   default = 0.5;          
% synch_precision:   time precision of synchrony
%   default = 20;    (20mus sampling interval);      
%
%============OUTPUT=============
% spks    = the cleaned version of the struct
%
% ==============================
% original input arguments 
% SPIKETIME:         vector with spike times in \mu s.
% SPIKECHANNEL:      vector with start_time times of periods to delete
% original output argument
% cleanid = boolean vector marking  entries that match the
%           requirements
%

% 09/03/13 Okujeni
% 02/12/13 SSK -- modified to accept the struct spks, and return the
% cleaned version of spks.
%

SPIKETIME = spks.time*1e6;
SPIKECHANNEL = spks.channel + 1; % hw + 1

synch_level = 0.5;
NAC = length(unique(SPIKECHANNEL));
synch_precision = 40; %mus
%
pvpmod(varargin);
%synch_precision (2ms) precision spike train
ST=round(SPIKETIME/synch_precision); 
STunique=unique(ST);
[~,pos]=ismember(ST,STunique);
 % filter: take care of jitter by rounding procedure
synch = STunique(filter(ones(3,1),1,histc(pos,1:length(STunique)))>synch_level*NAC);
synch = [synch-synch_precision,synch,synch+synch_precision];
% index shifted by 1?
cleanid = ~ismember(ST,synch);
original_length = length(spks.time);

spks.time       = spks.time(cleanid);
spks.channel    = spks.channel(cleanid);
spks.height     = spks.height(cleanid);
spks.width      = spks.width(cleanid);
spks.context    = spks.context(:,cleanid);
spks.thresh     = spks.thresh(cleanid);

final_length      = length(spks.time);
disp(['Percentage of spikes blanked (switching artifacts) = ',num2str(100*(original_length - final_length)/original_length),'%']);
