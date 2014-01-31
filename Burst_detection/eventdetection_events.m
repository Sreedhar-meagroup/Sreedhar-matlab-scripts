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
PVPMOD(varargin);
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
EVENTID=EVENTID(1:N); %if events range over the limit the cumsum procedure (offsets are shifted by one to the right) will increase the size of EVENTID by one therefore take entries from 1:N 

