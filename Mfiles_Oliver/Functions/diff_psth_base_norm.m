% plot PSTHs for a couple of given channels and also plot the difference
% PSTH, e.g. for two different conditions
% do a normalization w.r. to baseline level before stimulation



%input:
%
%psth_control:       A psth vector, for a period without stimulation (or
%                     any other kind))
%
%
%psth_stim           A psth vector, for a stimulation period (or also any
%                    other kind)
%
%
%channel_vec         Channel nrs (MEA_notation) for which the analysis
%                    should be done, MAXIMUM of 3
%
%
%datname:            Name of the file


%ADDITIONAL information:  The PSTH-binwidth, nr of trials for calculating
%th ePSTH, extend of pre and post trigger time.

function diff_psth_base_norm(psth_control, psth_stim, channel_vec,datname);


BIN_WIDTH       = 0.01;

TRIALS_CONT     = 925;
TRIALS_STIM     = 868;

PRE_TIME        = 2.5;
POST_TIME       = 2.5;




TIMEVEC         = ([-PRE_TIME:BIN_WIDTH:POST_TIME-BIN_WIDTH])+BIN_WIDTH/2;


hw_ch           = cr2hw(channel_vec)+1;
nr_ch           = length(channel_vec);


%window for calculation of baseline rate, in sec
base_window     = 1;
base_ind        = 1:base_window/BIN_WIDTH;

%calculation of a baseline rate
for jj=1:nr_ch
base_rate_cont(jj) = sum(psth_control(hw_ch(jj),base_ind))/(TRIALS_CONT*BIN_WIDTH*length(base_ind));
base_rate_stim(jj) = sum(psth_stim(hw_ch(jj),base_ind))/(TRIALS_STIM*BIN_WIDTH*length(base_ind));
end



psth_diff_fig   = figure;


%delete the middle bin in the stim case, because this is usually blanhed,
%set it NAN
middle_bin                = size(psth_stim,2)/2+1;
psth_stim(:,middle_bin)   = NaN;


for jj=1:nr_ch
    
    norm_fact_cont  = (TRIALS_CONT*BIN_WIDTH);
    norm_fact_stim  = (TRIALS_STIM*BIN_WIDTH);
    
    subplot(2,nr_ch,jj);
    
    psth_cont_baseline_dev(jj,:) = psth_control(hw_ch(jj),:)/norm_fact_cont/base_rate_cont(jj) - 1;
    psth_stim_baseline_dev(jj,:) = psth_stim(hw_ch(jj),:)/norm_fact_stim/base_rate_stim(jj) - 1;
    
    %plot the individual PSTHs
    plot(TIMEVEC,psth_cont_baseline_dev(jj,:),'b');
    hold on;
    plot(TIMEVEC,psth_stim_baseline_dev(jj,:),'g');
    xlim([-PRE_TIME POST_TIME]);
    %xlim([-3 3]);
    ylabel('multiples of baseline rate  ');
    xlabel('time r.t. trigger/stimulus [sec]');
    title(['channel: ', num2str(channel_vec(jj))]);
    legend('control', 'stimulation');
    
    
    psth_diff(jj,:)  = psth_cont_baseline_dev(jj,:) - psth_stim_baseline_dev(jj,:);
    
    
    
    subplot(2,nr_ch,jj+nr_ch);
    plot(TIMEVEC,psth_diff(jj,:),'r')
    ylabel(' relative difference in baseline deviation ');
    xlabel('time r.t. trigger/stimulus [sec]');
    title({['difference between control and stimulation '];['channel: ', num2str(channel_vec(jj))]});
    xlim([-PRE_TIME POST_TIME]);
    %xlim([-3 3]);
    
end
    
    
   

subplot(2,nr_ch,1);
title({[ 'datname: ', num2str(datname)];['deviation of baseline rate, baseline determined as an average rate some time prior to 0 '];...
       [' 0 is the time when the (online detected) trigger/stimulus comes'];...
       ['channel: ', num2str(channel_vec(1))]}, 'Interpreter','none');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    