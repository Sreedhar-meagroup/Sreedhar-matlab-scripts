%calculate if activity pairs A->B with a given delay tau
% occur significantly often. This goes mainly back to Shahaf & Marom, J.
% Neurosci 2001
% 

% 
% 
% 
% 

%%%%%%%%%%%%%%%%%%%
% work in progress:
% The extraction of a significance level does not work as imagined. either
% the nr. of spikes on electrode A (in activity pair A->B) is too high and
%the binomial coefficient (n,k) explodes (-> infinity), or the firing probabilities are too different, 
% e.g. the coefficients (probab_b)^sum_index*(1-probab_b)^counts-sum_index
% gives 0. In fact, so far, I have always only observed either significance
% levels of 1, or NaN. Both doesn't really help
% One solution could be to stop the caclculation of the sum once a ritical
% upper or lower bound was reached (or before the factors become inf or 0)
% 
% 
% 
% 
% 


function Significant_act_pairs(datname,ls,burst_detection,CHANNEL_VEC,time_start,time_end,BIN_WIDTH)

hw_ch  = cr2hw(CHANNEL_VEC);
nr_ch  = length(hw_ch);


binning_vec   = (time_start*3600):BIN_WIDTH/1000:(time_end*3600);
spike_trains  = zeros(length(binning_vec),nr_ch);

%find all the spikes on the resp channels first
for ii=1:nr_ch
    %ch_spikes           = ls.time(find(ls.channel==hw_ch(ii) & ls.time > time_start*3600 & ls.time < time_end*3600));
    %work only on spikes in bursts
    %these are all the spikes in bursts for the resp channel
    burst_spikes           = [burst_detection{1,hw_ch(ii)+1}{:,3}];
    ch_spikes              = burst_spikes(find(burst_spikes>time_start*3600 & burst_spikes<time_end*3600));
    nr_spikes(ii)          = length(ch_spikes);
    spike_trains(:,ii)     = hist(ch_spikes,binning_vec);  
end
;


%calculate the occurences of activity pair A->B with a given delay tau

MAX_LAG     = 200;
MAX_LAG_IND = MAX_LAG/BIN_WIDTH;

nr_pairs                  = zeros(1,2*MAX_LAG_IND+1);
[nr_pairs lag_ind]        = xcorr(spike_trains(:,1),spike_trains(:,2),MAX_LAG_IND);

%generate a vector with the lag tau and the resp index in nr_pairs in it
 
pair_duration(:,1) = 0:BIN_WIDTH:MAX_LAG;              %this gives the absolute delay
pair_duration(:,2) = sort(1:MAX_LAG_IND+1,'descend');  %this gives the index in nr_pairs



%%%%%%%%%%
%nr_pairs    = 5000*ones(1,length(pair_duration));
%nr_spikes(1)=10000;
%nr_spikes(2)=10000;

%define the parameters to estimate the significance
probab_a   = nr_spikes(1)/sum(nr_spikes);
probab_b   = nr_spikes(2)/sum(nr_spikes);
counts     = nr_spikes(1);





for jj=1:length(pair_duration)
    
    pair_occ               = nr_pairs(pair_duration(jj,2));
    pair_delay             = pair_duration(jj,1);
    total_pair_probability = 0;
    
    for kk = 1:(counts-pair_occ)
        sum_index = kk-1 + pair_occ;
        pair_probability       =   nchoosek(counts,ceil(sum_index))*probab_b^sum_index*(1-probab_b)^(counts-sum_index);
        total_pair_probability =   total_pair_probability + pair_probability;
    end
    significance_level(jj) =  total_pair_probability;
    
end  
    
;


