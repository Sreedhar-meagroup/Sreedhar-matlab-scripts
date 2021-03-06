function [bursts,BURSTID]=burstdetection(st,varargin)
%__________________________________________________________
%|                                                        |
%|  |==================================================|  |
%|  |  This functions detects burst in spiketrains     |  |
%|  |==================================================|  |
%|  | ## arguments                                     |  |
%|  |--------------------------------------------------|  |
%|  | >> array with spiketimes                         |  |
%|  |  st       : double array                         |  |
%|  |==================================================|  |
%|  | ## variable arguments list                       |  |
%|  |--------------------------------------------------|  |
%|  | >> maximal interspikeinterval within burst **    |  | 
%|  |  max_ISI  :  double; default =  75e3 (microsec)  |  |
%|  |--------------------------------------------------|  |
%|  | >> minimal number of spikes in spiketrain        |  |
%|  |  min_SPX  : integer; default =  25   (N)         |  |
%|  |--------------------------------------------------|  |
%|  | >> minimal number of spikes per burst            |  |
%|  |  min_BST  : integer; default =   3   (N)         |  |
%|  ---------------------------------------------------|  |
%|  | >> minimal interburstinterval                    |  |
%|  |  min_IBI  :  double; default = 200e3 (microsec)  |  |
%|  |--------------------------------------------------|  |
%|  |                                                  |  |
%|  | OUTPUT: [bursts,BURSTID]=detectBursts3(st,varargin)  |  |   
%|  |                                                  |  |
%|  | bursts:       Vector of size st with zeros,positive  |  |
%|  |           and negative numbers. Positive numbers |  |
%|  |           mark the apike beginning a burst and   |  |
%|  |           negative numbers are assigned to the   |  | 
%|  |           spike at the end of the burst.         |  |     
%|  |           Zeros are all other spikes.            |  | 
%|  |                                                  |  |     
%|  | BURSTID:  Vector of size st with zeros and       |  |     
%|  |           positive numbers. All spikes in bursts |  |
%|  |           are assigned to their respective       |  | 
%|  |           ascending burst index                  |  | 
%|  |                                                  |  |             
%|  | Note:     The output refers to the temporarilly  |  | 
%|  |           sorted spiketrain st with ascending    |  |     
%|  |           spike times (also required as input)   |  | 
%|  |__________________________________________________|  | 
%|________________________________________________________|
% sobok 28.02.07

%% default settings ===============================
%--------------------------------------------------
% Interspikeintervall
max_ISI  =  75e3;
%--------------------------------------------------
% Minimum Spikes per Spiketrain to be evaluated
min_SPX  = 25;
%--------------------------------------------------
% Minimum Spikes per Burst
min_BST =   3;
%--------------------------------------------------
% Minimum Interburstinterval of two seperate bursts
min_IBI = 200e3;
%--------------------------------------------------

%% arguments list =================================
%--------------------------------------------------
% read in variable input to change default values
%pvpmod(varargin);
%--------------------------------------------------

% length of Spiketrain
N = length(st);
% check spiketrain
if N < min_SPX
    bursts  = zeros(N,1);
    BURSTID = zeros(N,1);
    return 
end
% Interspikeintervalls
st_ISI  = [diff(st);Inf];
% find interspike intervalls smaller than threshold and define as burst seeds
bursts = zeros(N,1);
seeds=find(st_ISI<=max_ISI);
bursts(seeds)=1;
bursts_onsets=find(diff([0;bursts;0])>0);
bursts_offsets=find(diff([0;bursts;0])<0);   %[0;bursts;0] envelope for bursts that range over the limits 
% merge burst seeds that are to close to each other ()
tooclose=find(st(bursts_onsets(2:end))-st(bursts_offsets(1:end-1))<min_IBI);
bursts_onsets=setdiff(bursts_onsets,bursts_onsets(tooclose+1));
bursts_offsets=setdiff(bursts_offsets,bursts_offsets(tooclose));
% delete bursts that have less then the minimally required spikes (min_BST)
toosmall=find(bursts_offsets-bursts_onsets+1<min_BST);
bursts_onsets=setdiff(bursts_onsets,bursts_onsets(toosmall));
bursts_offsets=setdiff(bursts_offsets,bursts_offsets(toosmall));
% formatting: bursts
bursts = zeros(N,1);
bursts(bursts_onsets)=1:length(bursts_onsets);
bursts(bursts_offsets)=-1*(1:length(bursts_offsets));
% formatting: BURSTID (ascending index with every Spike assigned to a burst ID or to none (0= no burst)
BURSTID = zeros(N,1);
BURSTID(bursts_onsets)=1:length(bursts_onsets);
BURSTID(bursts_offsets)=-1*(1:length(bursts_offsets)); 
BURSTID=cumsum(BURSTID); 
BURSTID(find(diff(BURSTID)<0)+1)=BURSTID(find(diff(BURSTID)<0));
BURSTID=BURSTID(1:N);%if bursts range over the limit the cumsum procedure (offsets are shifted by one to the right) will increase the size of BURSTID by one therefore take entries from 1:N




