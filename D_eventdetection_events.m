function EVENTID=eventdetection_events(eventtime,varargin)
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
[temp, onsetid] = unique(EVENTID,'first');

%eventid up to last spike in events
[temp, offsetid] = unique(EVENTID,'last');

onset_time = SPIKETIME(onsetid);
offset_time = SPIKETIME(offsetid)+max_ISI;
[temp, id]=sort([onset_time;offset_time]);
temp = [onsetid;offsetid];
on_off_id  = temp(id);
temp = [ones(size(onset_time));ones(size(offset_time))*-1];
eventcounter = cumsum(temp(id));
% thresholding with minimal electrode number for NE
onsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])>0));
offsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])<0));

onsets = SPIKETIME(onsetsid);
offsets = SPIKETIME(offsetsid);

% take first spike within onset_window before network event start
temp = zeros(size(SPIKETIME));
temp(onsetsid+1)=1;
temp = cumsum(temp)+1;
inrange = find(temp<=length(onsets));
temp = temp(inrange);
temp2 = find(diff([1;((onsets(temp)-SPIKETIME(inrange))<=onset_window) & ((onsets(temp)-SPIKETIME(inrange))>0)])>0);
onsetsid(unique(temp(temp2))) = inrange(temp2);

% take last spike within offset_window after network event closure
temp = zeros(size(SPIKETIME));
temp(offsetsid)=1;
temp = cumsum(temp);
inrange = find((temp<=length(offsets)) & (temp>0));
temp = temp(inrange);
temp2 = find(diff([((SPIKETIME(inrange)-offsets(temp))<=offset_window) & ((SPIKETIME(inrange)-offsets(temp))>0)])<0);
offsetsid(unique(temp(temp2))) = inrange(temp2);

% % last operation could result in offsets preceding onset - these are deleted
temp = find((onsetsid(2:end)-offsetsid(1:end-1))<=0);
onsetsid  = onsetsid(setdiff(1:length(onsetsid),temp+1));
offsetsid = offsetsid(setdiff(1:length(offsetsid),temp));

% % merge network events that are to close
tooclose=find((SPIKETIME(onsetsid(2:end))-SPIKETIME(offsetsid(1:end-1)))<=onset_deadtime);
onsetsid=setdiff(onsetsid,onsetsid(tooclose+1));
offsetsid=setdiff(offsetsid,offsetsid(tooclose));

% delete network events that are to small
temp = find((offsetsid-onsetsid)>=min_SPNE);
onsetsid = onsetsid(temp);
offsetsid = offsetsid(temp);

% create NETWORKEVENTID
NETWORKEVENTID = zeros(size(SPIKETIME));
NETWORKEVENTID(onsetsid)=[1:length(onsetsid)]';
NETWORKEVENTID(offsetsid)=-[1:length(onsetsid)];
NETWORKEVENTID = cumsum(NETWORKEVENTID);
NETWORKEVENTID(offsetsid)=1:length(onsetsid);

% onset and offset times
NETWORKEVENTONSETS  = SPIKETIME(onsetsid);
NETWORKEVENTOFFSETS = SPIKETIME(offsetsid);
