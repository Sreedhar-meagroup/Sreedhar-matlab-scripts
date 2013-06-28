function [bursts_beg,bursts_end,BURSTID]=burstsdetection_oliver_vonsamora(st,varargin)
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

max_ISI = 75e3;
min_SPX = 25;
min_BST = 3;
min_IBI = 200e3;



%pvpmod(varargin);

MAX_INTERVAL_LENGTH = max_ISI;
MAX_BURST_INT       = min_IBI;                                                              %MAX interval allowed that still can belong to  a burst 
MIN_NO_SPIKES       = min_BST;                                                                               %min no of spikes in a burst that must be there

burst_detection=cell(1,61);

    channel_spike_times=st';
    no_spikes=length(st);
    %calculate the ISIs first
    %the ith entry in channel_spike_isi belongs to the interval between the
    %spikes i+1 and i
    channel_spike_isi=zeros(1,no_spikes-1);
    channel_spike_isi= diff(channel_spike_times);
    
    %HERE COMES the burst detection
    short_intervals_logical         = (channel_spike_isi<MAX_INTERVAL_LENGTH);  %TAKE CARE, this is a logical array;
    short_intervals_logicaldiff     = diff([0 short_intervals_logical 0]);      %pad this vector with a 0 at the end and at the beginning
    bursts_beg                      = find(short_intervals_logicaldiff==1);     % this is the index in ch_spike_times, but NOT in short_intervals_logical, 
                                                                                %becuase from the calculation made in the upper row, I pad 0 at the bg and end
                                                                                %this gives the spike nr. 1 in a burst
    bursts_end                      = find(short_intervals_logicaldiff==-1);    %this gives the last spike nr. in ch_spike_times that is stil in a burst 
                                                                                %when refering to the intervals, of course, one has to substract 1 from bursts_end, but remain with the bursts_beg, to get the intervals of a burst
    
    %NOTE: %A = +A is the easiest way to convert a logical array, A, to a numeric double array.
    short_intervals=+short_intervals_logical;                                   %this is now a double array;
    short_intervals(bursts_end-1) = -1;                                          % in short_intervals,a -1 means that this is the last interval IN an burst, i.e the following spike does still belong to the burst
    short_intervals(bursts_beg)   =  1;
    
    %delete those burstbegins and ends that are actually less than
    %MAX_BURST_INT secs apaprt
    close_burst_intervals=find(channel_spike_times(bursts_beg(2:end)) - channel_spike_times(bursts_end(1:end-1)) < MAX_BURST_INT );   %this gives the positions in bursts_beg and bursts_end whose bursts are closer than MAX_BURTS_INT
    bursts_beg=setdiff(bursts_beg,bursts_beg(close_burst_intervals+1));    %add one here, because I look from 2:end
    bursts_end=setdiff(bursts_end,bursts_end(close_burst_intervals));
 
    %throw away those 'burstst' that actually have not enough nr. of spikes, i,e less than MIN_NO_SPIKES
    toosmall1     = find(bursts_end-bursts_beg+1<MIN_NO_SPIKES);    % since bursts_beg and bursts_end give the spike nr. of begin and end of a burst
    bursts_beg   = setdiff(bursts_beg,bursts_beg(toosmall1));
    bursts_end   = setdiff(bursts_end,bursts_end(toosmall1));
    
    %construct a vector as long as the nr. of spikes, where 0 stands for
    %the case that the spike does not belong to a burst, any other number x
    %indicates that the spike belongs to burst nr. x
    BURSTID=zeros(1,no_spikes);
    BURSTID(bursts_beg)   =1:length(bursts_beg);
    BURSTID(bursts_end+1) =1:length(bursts_end);  %I ad 1 in the index, because in the following cumulative sum, I need the index to be shifted one to the right
    BURSTID=cumsum(BURSTID);                      %this cumsum results in an array that has teh features as described above    

    
    
    
    disp(num2str(length(bursts_beg)));
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
%     while j < no_spikes-(MIN_NO_SPIKES-2)
%         if(channel_spike_isi(j) < MAX_INTERVAL_LENGTH_1ST & channel_spike_isi(j+(1:(MIN_NO_SPIKES-2))) < MAX_INTERVAL_LENGTH);   %the condition for a burst
%        
%            bursts_detected=bursts_detected+1;
%            
%            burst_end = find(channel_spike_isi(j:end) > MAX_INTERVAL_LENGTH);                                                  %find all the intervals which are larger than the max_interval allowed and choose the first one that was found as the end of the burst
%                                                                                                         
%            if ~isempty(burst_end) 
%                burst_end=burst_end+(j-1);                                                                                       %because we start our index search at j, we have to add at the end to get absolute values for the index 
%                burst_end_isi=channel_spike_isi(burst_end(1)-1);                                                                  %i.e. burst_end_isi is the last isi that still belongs to the burst, burst_end(1) is the index in current_trial_isi that is the first interval after the burst
%            else                                                                                                                 %if we are at the end of all spikes, there is no isi anymore that is longer than the max_intervalallowed, so we  take the last isi as the end automatically
%                burst_end=length(channel_spike_isi)+1;                                                                            %here I add one because this burst end is the end that still belongs to the burst, in the upper case this is not the case. To make the following code consistent, this is necessary
%                burst_end_isi=channel_spike_isi(end);
%            end
%            
%          
%           isi_in_burst_indices = find(channel_spike_isi(j:burst_end(1)-1));
%           isi_in_burst_indices = isi_in_burst_indices+(j-1);                                                                  %because we start our index search at j but want to have absolute values of the index, we have to add j at the end again
%           burst_length=length(isi_in_burst_indices)+1;                                                                         %plus 1 because we deal with isis but want to have the actual no. of spikes in the burst
%           
%           spike_in_burst_indices = [isi_in_burst_indices isi_in_burst_indices(end)+1];                                          %all the indices for the isis and the next one
%           spike_in_burst_times(1:burst_length) = channel_spike_times(spike_in_burst_indices);
%           burst_detection{1,channel+1}{bursts_detected,1} = bursts_detected;                                                             %create a nested cell array burst_detection{1,trial_no}{burst_no-in_trial,information}
%           burst_detection{1,channel+1}{bursts_detected,2} = burst_length;
%           burst_detection{1,channel+1}{bursts_detected,3} = spike_in_burst_times;
%           burst_detection{1,channel+1}{bursts_detected,4} = channel_spikes_ind(spike_in_burst_indices);                                                      %save also the indices in the ls structure for each spike in the burst
%           j = j + length(isi_in_burst_indices);
%           
%         else
%             j = j+1;
%             continue                                                                                     %continue with the next isi check
%         end
%         clear isi_in_burst_indices
%         clear spike_in_burst_indices
%         clear spike_in_burst_times
%        
%      end                                                                                                %end the current trial, go on to the next one
%       clear channel_spike_isi
%       clear channel_spikes_ind
%       clear channel_spike_times
%       
%       %be sure that even if no burst was detected, there is a cell for
%       %that channel (that is empty, however)
%       if ~bursts_detected
%           burst_detection{1,channel+1}=[];
%       end
% end;%end for all the channels
% 
% 
