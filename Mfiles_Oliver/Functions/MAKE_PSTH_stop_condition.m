%%file MAKE_PSTH

%For a special purpose, generate a PSTH as usual, but with some additional
%'condition' for the spikes considered in the PSTH, namely that only those
%spikes are taken that fall before some other time (e.g. the stim time) 





%%input:
%ls                     The usual structure that holds the spiek
%                       information

%channel_vec:           vector of MEA channel Nrs, MAXIMALLY 3!

%trig_times;            vector of allignment times in the PSTH

%stop_times:            Can be any other type of time points, that define
%                       upto which point thepoints are taken. Of course there should be as much of
%                       those points as trig_times


%output:
%ch_psth:               the vector that stores the values for plotting the
%                       PSTH, in the rows are the channels, in the columns are the bin values

%generates a figure with the individual PSTHs

%NOTE:
%due to the special way the PSTH is calculated here, the
%normalization must be handled differently. Becuase the nrs. of trials is
%not the same for all the bins after the trigger (before that, it is always
%the same) (Due to this special stop condition)), I calculate an
%normaization factor for each bin.


function [ch_psth psth_norm]=MAKE_PSTH_stop_condition(ls,channel_vec,trig_times,stop_times)


PRE_TRIG_TIME       = 5;
POST_TRIG_TIME      = 5;

PSTH_BIN_WIDTH      = 0.01;

TRIAL_TIME_VEC      = -PRE_TRIG_TIME:PSTH_BIN_WIDTH:POST_TRIG_TIME-PSTH_BIN_WIDTH;

hw_ch   = cr2hw(channel_vec);
nr_ch   = length(channel_vec);


ch_psth   = zeros(nr_ch,(PRE_TRIG_TIME+POST_TRIG_TIME)/PSTH_BIN_WIDTH);
psth_norm = zeros(nr_ch,(PRE_TRIG_TIME+POST_TRIG_TIME)/PSTH_BIN_WIDTH);

%psth_fig=figure;
for ii=1:nr_ch
   % subplot(nr_ch,1,ii);
    nr_trig = length(trig_times{ii});
    
    for jj=1:nr_trig
        ch_spikes     = ls.time(find(ls.channel==hw_ch(ii) & ls.time>trig_times{ii}(jj)-PRE_TRIG_TIME & ls.time<stop_times{ii}(jj)));
        rel_ch_times  = ch_spikes-trig_times{ii}(jj);
        ch_hist       = hist(rel_ch_times,TRIAL_TIME_VEC);
        
        ch_psth(ii,:) = ch_psth(ii,:) + ch_hist;
        %Normalization
        norm_fact                        = max(find(ch_hist>0));
        psth_norm(ii,1:norm_fact)        = psth_norm(ii,1:norm_fact) + ones(1,norm_fact);     
    end
    largest_norm_ind = find(psth_norm(ii,:)>0);
    %this gives the largest index, i.e. the last bin where a spike still
    %falls in, all others are 0, so I don't need to plot them (i.e. I can't
    %even normalize them)
    largest_ind =largest_norm_ind(end);
    plot(TRIAL_TIME_VEC(1:largest_ind),ch_psth(ii,1:largest_ind)./(PSTH_BIN_WIDTH*psth_norm(ii,1:largest_ind)));
    xlabel(' time r.t. trigger [sec]');
    ylabel('rate in trial [Hz]');
    title({['PSTH, with trials alligned on a certain trigger criteria'];['and only spikes upto a certain time after the trigger are taken (e.g. upto stimulation)'];...
          ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: ', num2str(channel_vec(ii))]});
end

        
        
        
        