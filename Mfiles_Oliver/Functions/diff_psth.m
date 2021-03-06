% plot PSTHs for a couple of given channels and also plot the difference
% PSTH, e.g. for two different conditions



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

function diff_psth(psth_control, psth_stim, channel_vec,datname);


BIN_WIDTH       = 0.01;

TRIALS_CONT     = 271;
TRIALS_STIM     = 253;

PRE_TIME        = 2.5;
POST_TIME       = 2.5;

TIMEVEC         = ([-PRE_TIME:BIN_WIDTH:POST_TIME-BIN_WIDTH])+BIN_WIDTH/2;


hw_ch           = cr2hw(channel_vec)+1;
nr_ch           = length(channel_vec);

psth_diff_fig   = figure;


%delete the middle bin in the stim case, because this is usually blanhed,
%set it NAN
middle_bin                = size(psth_stim,2)/2+1;
%psth_stim(:,middle_bin)   = NaN;


for jj=1:nr_ch
    
    norm_fact_cont  = (TRIALS_CONT*BIN_WIDTH);
    norm_fact_stim  = (TRIALS_STIM*BIN_WIDTH);
    
    subplot(2,nr_ch,jj);
    
    %if normalization on peak height is desired:
    %norm_fact_cont   = (TRIALS_CONT*BIN_WIDTH)*max(psth_control(hw_ch(jj),:)/(TRIALS_CONT*BIN_WIDTH));
    %norm_fact_stim   = (TRIALS_STIM*BIN_WIDTH)*max(psth_stim(hw_ch(jj),:)/(TRIALS_STIM*BIN_WIDTH));
    
    
    psth_diff(jj,:)  = psth_control(hw_ch(jj),:)/norm_fact_cont - psth_stim(hw_ch(jj),:)/norm_fact_stim;
    
    
    
    plot(TIMEVEC,psth_control(hw_ch(jj),:)/norm_fact_cont,'b');
    hold on;
    plot(TIMEVEC,psth_stim(hw_ch(jj),:)/norm_fact_stim,'g');
    xlim([-PRE_TIME POST_TIME]);
    %xlim([-1 1.5]);
    ylabel('rate (in trial) [Hz] ');
    xlabel('time r.t. trigger/stimulus [sec]');
    title(['channel: ', num2str(channel_vec(jj))]);
    legend('control', 'stimulation');
    
    subplot(2,nr_ch,jj+nr_ch);
    plot(TIMEVEC,psth_diff(jj,:),'r')
    ylabel('rate (in trial) [Hz] ');
    xlabel('time r.t. trigger/stimulus [sec]');
    title({['difference between control and stimulation '];['channel: ', num2str(channel_vec(jj))]});
    xlim([-PRE_TIME POST_TIME]);
    %xlim([-1 1.5]);
    
end
    
    
   

subplot(2,nr_ch,1);
title({[ 'datname: ', num2str(datname)];['PSTH for different periods of recording'];[' 0 is the time when the (online detected) trigger resp. stimulus comes'];...
      ['channel: ', num2str(channel_vec(1))]}, 'Interpreter','none');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    