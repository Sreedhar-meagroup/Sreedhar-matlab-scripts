function [NETWORKEVENTID,NETWORKEVENTONSETS,NETWORKEVENTOFFSETS]=eventdetection_networkevents(spiketime,eventid,max_ISI,varargin)
%%
%% default settings ===============================
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
% temp = zeros(size(eventid));
% temp(onsetid)=1;
% temp = cumsum(temp);
% eventid_onset = temp; %+min_EPNE-1;

%eventid up to last spike in events
% temp = zeros(size(eventid));
[temp, offsetid] = unique(eventid,'last');
% temp(offsetid)=1;
% temp = cumsum(temp);
% temp(offsetid)=temp(offsetid)-1;
% eventid_offset = temp; %+offset_Nevents-1;

onset_time = spiketime(onsetid);
offset_time = spiketime(offsetid)+max_ISI;
[temp, id]=sort([onset_time;offset_time]);
temp = [onsetid;offsetid];
on_off_id  = temp(id);
temp = [ones(size(onset_time));ones(size(offset_time))*-1];
% temp2 = [cumsum(ones(size(onset_time)));cumsum(ones(size(offset_time)))];
% onset_id = find(temp>0); offset_id = find(temp<0);
eventcounter = cumsum(temp(id));
% eventid2 = temp2(id);
% thresholding with minimal electrode number for NE
onsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])>0));
% onsetsid = on_off_id(temp);
offsetsid = on_off_id(find(diff([0;eventcounter>=min_EPNE;0])<0));
% offsetsid  = on_off_id(temp);

% 
% % detect onsets
% eventid_test_onset = eventid_onset+min_EPNE-1;
% inrange = find(eventid_test_onset<=max(eventid));
% temp = (events_lasting(inrange)>=min_EPNE);
% onsetsid = find(diff(temp)>0)+1+inrange(1)-1; %-min_EPNE+1;

% % detect offsets
% eventid_test_offset = eventid_offset-min_EPNE+1;
% inrange = find((eventid_test_offset<=max(eventid)) & (eventid_test_offset>0));
% temp = (events_lasting(inrange)>=min_EPNE);
% offsetsid = find(diff(temp)<0)+inrange(1)-1;

% range of onsets and offsets (every offset must be preceded by an onset and vice versa)
% [temp,tempid] = sort([onsetsid;offsetsid]);
% temp2 = [ones(size(onsetsid));zeros(size(offsetsid))];
% temp2 = temp2(tempid);
% offsets_start = min(find(diff([0;temp2])<0));
% offsets_end   = max(find(diff([0;temp2])<0));
% onsets_start = offsets_start-1;
% onsets_end   = offsets_end-1;
% onsetsid  = temp(onsets_start:2:onsets_end);
% offsetsid = temp(offsets_start:2:offsets_end);

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

