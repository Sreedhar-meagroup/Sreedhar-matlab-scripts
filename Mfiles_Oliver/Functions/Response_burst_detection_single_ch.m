% %function Response_burst_detetcion_single_ch,
% This fct makes a burst detection from spiketrains that were obtained as responses to stimulation.
% As an input, I have a list with the fields 'time','channel'and 'trial', where trila is the stim
% trial nr where the spikes occured, channel should always be  the same, becuase this fct works on single ch basis.
% The parameters are the same as for the burst detection, e.g. Min nr. of spikes, Max_Interval etc..
% The output consists of a cell array withe the (detcted) response-burst nr, the nr. of spikes, the spike times and the according
% stim trial later for later referencing
% 
% 
% 
% 
% % Response_burst_detection = Response_burst_detection_single_ch(ls,CH_NR_HW)
% % 
% 
% %Used as a function:
% 
% %input:
% %ls:            the usual structure with the spike information
% 
% CH_NR:          Hardware channel nr, for which the detction should be
%                 made
% % 
% 
% 
% 
% 
% %output:        burst_detection, a cell with an entry for each channel,
%                 %where the information about every detected burst is stored
%                 
%                 
% 
% 
 function Response_burst_detection = Response_burst_detection_single_ch(ls,CH_NR_HW)
% 
MAX_INTERVAL_LENGTH = 0.1;
MAX_BURST_INT       = 0.25;                                                              %MAX interval allowed that still can belong to  a burst 
MIN_NO_SPIKES       = 3;                                                                               %min no of spikes in a burst 

Response_burst_detection=cell(1,4);


    channel                = CH_NR_HW;
    channel_spikes_ind     = find(ls.channel==channel);
    channel_spike_times    = ls.time(channel_spikes_ind);
    %because this is done on single ch absis and for the detection of
    %bursta as stim responses, I also have the field 'trial'
    channel_spike_trials   = ls.trial(channel_spikes_ind);
    no_spikes              = length(channel_spikes_ind);
    
    %calculate the ISIs first
    %the ith entry in channel_spike_isi belongs to the interval between the
    %spikes i+1 and i
    channel_spike_isi=zeros(1,no_spikes-1);
    channel_spike_isi= diff(channel_spike_times);
    
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
    Response_burst_detection{i,1} = i;                                    %this is the burst nr.
    Response_burst_detection{i,2} = bursts_end(i)-bursts_beg(i)+1;        %this is the nr. of spikes
    Response_burst_detection{i,3} = channel_spike_times(bursts_beg(i):bursts_end(i));
    %store the trial nr here for whci stim trial the burst occured
    Response_burst_detection{i,4} = channel_spike_trials(bursts_beg(i):bursts_end(i));
    end
    
    
   