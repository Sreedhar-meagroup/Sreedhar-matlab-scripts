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

pvpmod(varargin)
 
%--------------------------------------------------------------------------
% SINGLE CHANNEL EVENTDETECTION
%--------------------------------------------------------------------------
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

function EVENTID=eventdetection(eventtime,varargin)
%
% detect events based on spike train data. 
%
% 8/5/13 Okujeni

%% default settings ===============================
%--------------------------------------------------
% Interspikeintervall
max_ISI  = 100e3;
%--------------------------------------------------
% Minimum Spikes per Burst
min_SPE =   1;
%--------------------------------------------------
% Minimum Interburstinterval of two seperate events
min_IEI = 100e3;
%--------------------------------------------------

%% arguments list =================================
%--------------------------------------------------
% read in variable input to change default values
pvpmod(varargin);
%--------------------------------------------------

% length of Spiketrain
N = length(eventtime);

% Interspikeintervalls
%IEI  = [diff(eventtime);Inf];
IEI  = diff(eventtime);
IEI(IEI<0)=2*max_ISI; %channel break
% find interspike intervalls smaller than threshold and define as burst seeds
events = zeros(N,1);
seeds=find(IEI<=max_ISI);
events(seeds)=1;
events_onsets=find(diff([0;events;0])>0);
events_offsets=find((diff([0;events;0])<0));   %[0;events;0] envelope for events that range over the limits 
% merge burst seeds that are to close to each other (! tanke care for channel breaks)
tooclose=find((eventtime(events_onsets(2:end))-eventtime(events_offsets(1:end-1))<min_IEI)& (eventtime(events_onsets(2:end))-eventtime(events_offsets(1:end-1))>0));
events_onsets=setdiff(events_onsets,events_onsets(tooclose+1));
events_offsets=setdiff(events_offsets,events_offsets(tooclose));
% delete events that have less then the minimally required spikes (min_SPE)
toosmall=find(events_offsets-events_onsets+1<min_SPE); 
events_onsets=setdiff(events_onsets,events_onsets(toosmall));
events_offsets=setdiff(events_offsets,events_offsets(toosmall));
% disp(num2str(length(events_onsets)));
% formating: events
events = zeros(N,1);
events(events_onsets)=1:length(events_onsets);
events(events_offsets)=-1*(1:length(events_offsets));
% formatting: EVENTID (ascending index with every Spike assigned to a burst ID or to none (0= no burst)
EVENTID = zeros(N,1);
EVENTID(events_onsets)=1:length(events_onsets);
EVENTID(events_offsets)=-1*(1:length(events_offsets)); 
EVENTID=cumsum(EVENTID); 
EVENTID(find(diff(EVENTID)<0)+1)=EVENTID(find(diff(EVENTID)<0));
% check last spikes
lspkid = find(diff(EVENTID)<0); 
lspkid = lspkid(lspkid<length(IEI));
% EVENTID(lspkid(find((eventtime(lspkid+1)-eventtime(lspkid))<=min_IEI))+1)=EVENTID(lspkid(find((eventtime(lspkid+1)-eventtime(lspkid))<=min_IEI)));
EVENTID(lspkid(find(IEI(lspkid)<=min_IEI))+1)=EVENTID(lspkid(find(IEI(lspkid)<=min_IEI)));
EVENTID=EVENTID(1:N); %if events range over the limit the cumsum procedure (offsets are shifted by one to the right) will increase the size of EVENTID by one therefore take entries from 1:N function [NETWORKEVENTID,NETWORKEVENTONSETS,NETWORKEVENTOFFSETS]=eventdetection_networkevents2(spiketime,eventid,max_ISI,varargin)
%
% detect network events based on spike train data. 
% (pre-processing using event detection is required).
%
% 8/5/13 Okujeni
%
% default settings ===============================
%--------------------------------------------------
% Onset window
onset_window  =  100e3; % network event recruitment period (must be smaller than max_ISI in event detection)
%--------------------------------------------------
% Onset window
offset_window  = 100e3; % network event recruitment period (must be smaller than max_ISI in event detection)
%--------------------------------------------------
% Minimum number of events that characterize a network event
min_EPNE  = 3;
% min_EPNE = ceil(length(unique(EAfile.CLEANDATA.SPIKECHANNEL))/10);
%--------------------------------------------------
% Minimum interval between two seperate network events
onset_deadtime = 100e3;
%--------------------------------------------------
% Minimal number of spikes per network event
min_SPNE = 3*min_EPNE;

% minimal eventduration (single spikes)
spike_duration = 100e3;

% arguments list =================================
%--------------------------------------------------
% read in variable input to change default values
pvpmod(varargin);
%--------------------------------------------------
%eventid up to fist spike in events
[temp, onsetid] = unique(eventid,'first');

%eventid up to last spike in events
[temp, offsetid] = unique(eventid,'last');

onset_time = spiketime(onsetid);
offset_time = spiketime(offsetid)+max_ISI;
[temp, id]=sort([onset_time;offset_time]);
temp = [onsetid;offsetid];
on_off_id  = temp(id);
temp = [ones(size(onset_time));ones(size(offset_time))*-1];
eventcounter = cumsum(temp(id));
% thresholding with minimal electrode number for NE
onsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])>0));
offsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])<0));

onsets = spiketime(onsetsid);
offsets = spiketime(offsetsid);

% take first spike within onset_window before network event start
temp = zeros(size(spiketime));
temp(onsetsid+1)=1;
temp = cumsum(temp)+1;
inrange = find(temp<=length(onsets));
temp = temp(inrange);
temp2 = find(diff([1;((onsets(temp)-spiketime(inrange))<=onset_window) & ((onsets(temp)-spiketime(inrange))>0)])>0);
onsetsid(unique(temp(temp2))) = inrange(temp2);

% take last spike within offset_window after network event closure
temp = zeros(size(spiketime));
temp(offsetsid)=1;
temp = cumsum(temp);
inrange = find((temp<=length(offsets)) & (temp>0));
temp = temp(inrange);
temp2 = find(diff([((spiketime(inrange)-offsets(temp))<=offset_window) & ((spiketime(inrange)-offsets(temp))>0)])<0);
offsetsid(unique(temp(temp2))) = inrange(temp2);

% % last operation could result in offsets preceding onset - these are deleted
temp = find((onsetsid(2:end)-offsetsid(1:end-1))<=0);
onsetsid  = onsetsid(setdiff(1:length(onsetsid),temp+1));
offsetsid = offsetsid(setdiff(1:length(offsetsid),temp));

% % merge network events that are to close
tooclose=find((spiketime(onsetsid(2:end))-spiketime(offsetsid(1:end-1)))<=onset_deadtime);
onsetsid=setdiff(onsetsid,onsetsid(tooclose+1));
offsetsid=setdiff(offsetsid,offsetsid(tooclose));

% delete network events that are to small
temp = find((offsetsid-onsetsid)>=min_SPNE);
onsetsid = onsetsid(temp);
offsetsid = offsetsid(temp);

% create NETWORKEVENTID
NETWORKEVENTID = zeros(size(spiketime));
NETWORKEVENTID(onsetsid)=[1:length(onsetsid)]';
NETWORKEVENTID(offsetsid)=-[1:length(onsetsid)];
NETWORKEVENTID = cumsum(NETWORKEVENTID);
NETWORKEVENTID(offsetsid)=1:length(onsetsid);

% onset and offset times
NETWORKEVENTONSETS  = spiketime(onsetsid);
NETWORKEVENTOFFSETS = spiketime(offsetsid);