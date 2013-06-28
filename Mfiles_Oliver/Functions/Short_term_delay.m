% %function Short_term_delay
% 
% extract some features of response spikes as e.g. delay of first spike,
% std of first spike response, oscillations,...
% 
% 
% 
% 
% 
%INPUT 
% Response_spikes   a 2-D cell array with an entry for each trial and 60 electrodes (only some of them filled) 
%                   where all the relative spike times are stored
% 
% 
% %Window_start     Start and end time after trigger where hte first spike
%  Window_end       should be detected, in msec!
%           
% 
% CHANNELS          MEA_channel vector for which the analysis should be
%                   made
% 
% 
% 



function First_spike_delay  = Short_term_delay(Response_spikes,Window_start,Window_end,CHANNELS)



% Time_start = 4.5944;
% Time_end   =  5.5;
% stim_times = ls.time(find(ls.channel==61 & ls.time>Time_start*3600 & ls.time<Time_end*3600));
% 

HW_channels = cr2hw(CHANNELS);

NR_trials   = size(Response_spikes,1);
NR_channels = length(CHANNELS);

First_spike_delay = zeros(NR_trials,NR_channels); 

for ii= 1:NR_trials
     %ii
    for jj=1:NR_channels
        active_ch = HW_channels(jj);
        
            
        if ~isempty(Response_spikes{ii,active_ch+1})
            if find(Response_spikes{ii,active_ch+1} >Window_start/1000 & Response_spikes{ii,active_ch+1}<Window_end/1000)
                resp_spike_ind  = find(Response_spikes{ii,active_ch+1}>Window_start/1000 & Response_spikes{ii,active_ch+1}<Window_end/1000);
                First_spike_delay(ii,jj) = Response_spikes{ii,active_ch+1}(resp_spike_ind(1));
            else
                 First_spike_delay(ii,jj) = NaN;
            end
        else
            First_spike_delay(ii,jj) = NaN;
        end
    end
end



