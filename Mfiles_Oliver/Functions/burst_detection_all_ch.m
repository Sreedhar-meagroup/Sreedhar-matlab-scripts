%file burst_detection_all_ch_modif.m
%01/03/07
%This is a totally new written burst detection, to be conform with Samoras
%way of detecting bursts and setting the different requirement and
%conditions for a burst.
% The algorithm is much faster, because it works with almost no loops,
% except for the for channels.
%The conditions are:
%Minimal nr. of spikes in a burst;
%Maximal Interspike interval in a burst
%Maximal interval between two bursts
%
%What it does (for each channel) is basically the following:
%it searches in the spike train for ISI that are smaller tahn the condition and
%seraches for beginning and end of a 'potential'burst
%After that, it throws away all those potential starts and ends, where the
%gap between start and end is smaller than the Minimal Interval between
%burst. Then it discard sall those already 'detected' bursts. that have
%less than Minimal nr. of spikes in it. In the end, i get a vector tah t
%looks  e.g.like 001111000022220003333333300044444, thsi vector has the
%same length as the spiek train and each 0 means the resp spike does not
%belong to ao burst, every other value x means that spike belongs to burst
%nr. x. the vectors bursts_beg and bursts_end are vectores that contain the
%beginning and and ending spike nr. of each burst. With all that information,
% I can construct my cell burst detection in the same way, with the same
% entries sand information


%Used as a function:

%input:
%ls:            the usual structure with the spike information

% varargin        variable arguemnts, can be 
%                 MAX_INTERVAL_LENGTH, 
%                 MAX_BURST_INT or
%                 MIN_NO_SPIKES
% 

%output:        burst_detection, a cell with an entry for each channel,
                %where the information about every detected burst is stored
                
                


function burst_detection=burst_detection_all_ch(ls,varargin)



MAX_INTERVAL_LENGTH = 0.075;
MAX_BURST_INT       = 0.15;                                                              %MAX interval allowed that still can belong to  a burst 
MIN_NO_SPIKES       = 3;                                                                               %min no of spikes in a burst 

%check if I have multiple inputs
if nargin >1
    nr_inputs = nargin
    switch nr_inputs
        case 2
            
            MAX_INTERVAL_LENGTH  = varargin{1}
        case 3
            
             MAX_INTERVAL_LENGTH = varargin{1}
             MAX_BURST_INT       = varargin{2}
        case 4
            
             MAX_INTERVAL_LENGTH = varargin{1}
             MAX_BURST_INT       = varargin{2}
             MIN_NO_SPIKES       = varargin{3}
    end
end

burst_detection=cell(1,61);
for channel=0:60;
    channel;
    channel_spikes_ind  = find(ls.channel==channel);
    channel_spike_times = ls.time(channel_spikes_ind);
    no_spikes=length(channel_spikes_ind);
    %calculate the ISIs first
    %the ith entry in channel_spike_isi belongs to the interval between the
    %spikes i+1 and i
    channel_spike_isi = zeros(1,no_spikes-1);
    channel_spike_isi = diff(channel_spike_times);
    
    %HERE COMES the burst detection
    short_intervals_logical         = (channel_spike_isi<=MAX_INTERVAL_LENGTH);  %TAKE CARE, this is a logical array;
    short_intervals_logicaldiff     = diff([0 short_intervals_logical 0]);      %pad this vector with a 0 at the end and at the beginning
    bursts_beg                      = find(short_intervals_logicaldiff==1);     % this is the index in ch_spike_times, but NOT in short_intervals_logical, 
                                                                                %becuase from the calculation made in the upper row, I pad 0 at the bg and end
                                                                                %this gives the spike nr. 1 in a burst
    bursts_end                      = find(short_intervals_logicaldiff==-1);    %this gives the last spike nr. in ch_spike_times that is stil in a burst 
                                                                                %when refering to the intervals, of course, one has to substract 1 from bursts_end, but remain with the bursts_beg, to get the intervals of a burst
    
    %delete those burstbegins and ends that are actually less than
    %MAX_BURST_INT secs apaprt
    close_burst_intervals=find(channel_spike_times(bursts_beg(2:end)) - channel_spike_times(bursts_end(1:end-1)) < MAX_BURST_INT );   %this gives the positions in bursts_beg and bursts_end whose bursts are closer than MAX_BURTS_INT
    bursts_beg=setdiff(bursts_beg,bursts_beg(close_burst_intervals+1));    %add one here, because I look from 2:end
    bursts_end=setdiff(bursts_end,bursts_end(close_burst_intervals));
 
    %throw away those 'burstst' that actually have not enough nr. of spikes, i,e less than MIN_NO_SPIKES
    toosmall     = find(bursts_end-bursts_beg+1<MIN_NO_SPIKES);    % since bursts_beg and bursts_end give the spike nr. of begin and end of a burst
    bursts_beg   = setdiff(bursts_beg,bursts_beg(toosmall));
    bursts_end   = setdiff(bursts_end,bursts_end(toosmall));
           
    for i=1:length(bursts_beg)
    burst_detection{1,channel+1}{i,1}=i;                                    %this is the burst nr.
    burst_detection{1,channel+1}{i,2}=bursts_end(i)-bursts_beg(i)+1;        %this is the nr. of spikes
    burst_detection{1,channel+1}{i,3}=channel_spike_times(bursts_beg(i):bursts_end(i));
    burst_detection{1,channel+1}{i,4}=channel_spikes_ind(bursts_beg(i):bursts_end(i));
    end
    
end
    
   