function result = detectEvents(SPIKETIME,SPIKECHANNEL,varargin)
% Function to detect events (single channel definition) and network events.
%  --------------------------- COMMAND -------------------------------------
% result = detectEvents(SPIKETIME,SPIKECHANNEL)
%
%  --------------------------- INPUT -------------------------------------
% the following two data vectors are required:
% SPIKETIME            vector with spike times (microseconds)
% SPIKECHANNEL         vector with spike channels
%
%  ----------------------------OUTPUT-------------------------------------
% the output structure has the following fields:
% SPIKETIME            vector with spike times (could be resorted)
% SPIKECHANNEL         vector with spike channels (could be resorted)
% EVENTID              vector assigning an event id to spikes
% EVENTTIME            vector with event times
% EVENTCHANNEL         vector with event channels
% EVENTDURATION        vector with the duration of events
% EVENTSIZE            vector with the size (number of spikes) of events
% NETWORKEVENTID       vector assigning a network event id to spikes 
%                      (set to 0 for spikes outside network events)
% NETWORKEVENTONSETS   vector with network event onset times
% NETWORKEVENTOFFSETS  vector with network event offset times
%
%  -------------------- ALGORITHM & PARAMETERS ----------------------------------
% Events are determined as consecutive spike series with interspike
% intervalls smaller than a specified value.
% Parameter: max_ISI, default: 100e3 (100ms)
% 
% Network events are defined as periods in which a defined number of
% simultaneous events is superseeded.
% Parameter: min_EPNE, default: 10% of active channels (automatically calculated).
%
% Network event onset detection further includes spikes within defined
% windows prior and after on and offset times determined by the above criterion.
% Parameter: onset_window, default: 25e3 (25ms)
% Parameter: offset_window, default: 25e3 (25ms)
%
% Network events closer than a defined interval are merged.
% Parameter: onset_deadtime
% 
% Optional Paramters
% min_SPNE - set the minimal number of spikes required for network events
%
% -------------------------------------------------------------------------
% Okujeni 8/5/13
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% parameters
% -------------------------------------------------------------------------
% single channel event detection
max_ISI   = 100e3;        % time [mus], maximal Interspike intervall to group spikes to events
min_IEI   = 100e3;        % time [mus], minimal interevent interval, events will otherwise be gouped 

%network event detection
onset_window    = 25e3; % time [mus], better use 50 or 75ms in some cases
offset_window   = 25e3; % time [mus]
onset_deadtime  = 25e3; % time [mus]
min_EPNE = nan; % is calculated on the basis of number of channels with bursts (eventsize >=3), but can be set here..
min_SPNE = nan;% is calculated on the basis of number of channels with bursts (eventsize >=3), but can be set here..

PVPMOD(varargin)
 
%--------------------------------------------------------------------------
% SINGLE CHANNEL EVENTDETECTION
%--------------------------------------------------------------------------
% vertical vectors
SPIKETIME = SPIKETIME(:);
SPIKECHANNEL = SPIKECHANNEL(:);
%sort according to spike channel (since EVENTID will have the same sorting)
[SPIKECHANNEL,id]=sort(SPIKECHANNEL);
SPIKETIME = SPIKETIME(id);
EVENTID=eventdetection_events(SPIKETIME,'max_ISI',max_ISI,'min_IEI',min_IEI);
onsets_id = find(diff([0;EVENTID])>0);
temp = find(flipud(diff([flipud(EVENTID)])<0));
offsets_id = sort([find(diff([EVENTID;0])<0);temp(EVENTID(temp)>0)]);
EVENTTIME = SPIKETIME(onsets_id);
EVENTCHANNEL = SPIKECHANNEL(onsets_id);
EVENTSIZE = offsets_id-onsets_id+1;
EVENTDURATION = SPIKETIME(offsets_id)-SPIKETIME(onsets_id);
% add single spikes
singlespikes_id = find(EVENTID==0);
[temp,resortID]=sort([SPIKETIME(EVENTID~=0);SPIKETIME(EVENTID==0)]); %needed later
EVENTTIME = [EVENTTIME;SPIKETIME(singlespikes_id)];
EVENTCHANNEL = [EVENTCHANNEL;SPIKECHANNEL(singlespikes_id)];
EVENTSIZE = [EVENTSIZE;ones(size(singlespikes_id))];
EVENTDURATION = [EVENTDURATION(:);zeros(size(singlespikes_id))];
EVENTID= [EVENTID(EVENTID~=0);cumsum(ones(sum(EVENTID==0),1))+max(EVENTID)];

% readdress eventid according to time of appearance (sortid)!!
[temp, sortid] = sort(EVENTTIME);
[temp,EVENTID]=ismember(EVENTID,sortid);

% sort EVENTDATA according to eventtimes
[EVENTTIME, sortid] = sort(EVENTTIME); 
EVENTDURATION = EVENTDURATION(sortid);
EVENTSIZE = EVENTSIZE(sortid);
EVENTCHANNEL = EVENTCHANNEL(sortid);   

%sort again according to spike time
EVENTID = EVENTID(resortID);
[SPIKETIME,sortid] = sort(SPIKETIME);
SPIKECHANNEL = SPIKECHANNEL(sortid);

%--------------------------------------------------------------------------
% NETWORKEVENTDETECTION
%--------------------------------------------------------------------------
if isnan(min_EPNE)
    % only consider channel with bursts
    AC_N = length(unique(EVENTCHANNEL(EVENTSIZE>2)));
    min_EPNE  = min(max(3,ceil(AC_N/10)),20);  %number of events
end
if isnan(min_SPNE)
    min_SPNE = min_EPNE;
end

% network event detection on the basis of EVENTTIME
[NETWORKEVENTID,NETWORKEVENTONSETS,NETWORKEVENTOFFSETS] =  eventdetection_networkevents2(SPIKETIME,EVENTID,max_ISI,'onset_window',onset_window,'offset_window',offset_window,'min_EPNE',min_EPNE,'onset_deadtime',onset_deadtime,'min_SPNE',min_SPNE);

% -------------------------------------------------------------------------
% output structure
% -------------------------------------------------------------------------
result.SPIKETIME = SPIKETIME;
result.SPIKECHANNEL = SPIKECHANNEL;
result.EVENTID = EVENTID;
result.EVENTTIME = EVENTTIME;
result.EVENTCHANNEL = EVENTCHANNEL;
result.EVENTDURATION = EVENTDURATION;
result.EVENTSIZE = EVENTSIZE;
result.NETWORKEVENTID = NETWORKEVENTID;
result.NETWORKEVENTONSETS = NETWORKEVENTONSETS;
result.NETWORKEVENTOFFSETS = NETWORKEVENTOFFSETS;