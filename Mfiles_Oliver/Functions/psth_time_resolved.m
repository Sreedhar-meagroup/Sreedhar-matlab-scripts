%%based on a control set and its psth, compare by a time resolved analysis
%%how a possible stimulation effect 'accumulates'over time. I.e. take
% more and more stimuli trials in the analysis and see if an effect is
% thereby enhanced (or maybe even suppressed) over time


%input:
% 
% ls:                          The usual structure with the spike data of
%                              the stimulated data
% 
% 
% psth_control:               A psth for the control case, this should be
%                             used for comparison with the stimulated data
% 
% 
% channel_vec;                A vector of MEA-channels, for which the
%                              time-resolved comparison between control 
%                             and stim cases should be made. For each 
%                             channel there is a new plot 
% 
% datname:                    name of file
% 


function psth_time_resolved(ls,psth_control,channel_vec,datname)

CONTROL_BINWIDTH = 0.01;
CONTROL_TRIALS   = 1348;

hw_ch           = cr2hw(channel_vec)+1;
nr_ch           = length(channel_vec);


stim_times      = ls.time(find(ls.channel==60));
TRIALS          = length(stim_times);

%the following should always be an even number
TRIAL_steps     = 4;
TRIAL_end       = floor([1:TRIAL_steps]*TRIALS/TRIAL_steps);

%extension of psth pre and post stimulus
psth_window     = 5;

psth_binwidth   = 0.01;

TRIAL_TIMEVEC   = -psth_window:psth_binwidth:psth_window-psth_binwidth; 

psth_timeres    = cell(nr_ch,TRIAL_steps);

middle_bin      = floor(length(TRIAL_TIMEVEC)/2)+1;

for jj=1:nr_ch
    ch_psth_time_res_fig(jj) = figure;
    color_od                 = colormap(lines);
    
    for kk=1:TRIAL_steps
        ch_spikes = ls.time(find(ls.channel==hw_ch(jj)-1 & ls.time>stim_times(1) & ls.time<stim_times(TRIAL_end(kk))));
        
        psth_timeres{jj,kk}=zeros(1,length(TRIAL_TIMEVEC));
        
        for mm=1:TRIAL_end(kk)
            
            trial_spikes    = ch_spikes(find(ch_spikes > (stim_times(mm)-psth_window) & ch_spikes < stim_times(mm)+psth_window));
            trial_sp_times  = trial_spikes - stim_times(mm);
            
            trial_hist      = hist(trial_sp_times,TRIAL_TIMEVEC);
            
            psth_timeres{jj,kk} = psth_timeres{jj,kk} + trial_hist;
        end
        
        %set the middle bin to NaN for known reasons
        %psth_timeres{jj,kk}(middle_bin)=NaN;
        
        subplot(2,TRIAL_steps/2,kk);
        plot(TRIAL_TIMEVEC,psth_control(hw_ch(jj),:)/(CONTROL_BINWIDTH*CONTROL_TRIALS),'Color',color_od(1,:));
        hold on;
        plot(TRIAL_TIMEVEC,psth_timeres{jj,kk}/(psth_binwidth*TRIAL_end(kk)),'Color',color_od(kk+1,:));
        xlabel('time r.t. stimulus/control [sec]');
        ylabel('rate in trial [Hz]');
        legend('control',['after ',num2str(TRIAL_end(kk)),' stimulation trials']);
        xlim([-2.5 2.5]);
    end
    
    subplot(2,TRIAL_steps/2,1);
    title({['datname: ', num2str(datname)];['PSTH for different lengths of stimulation application'];...
           ['to be compared with control PSTH']},'Interpreter', 'none');
    subplot(2,TRIAL_steps/2,2);
    title(['all plots channel: ', num2str(channel_vec(jj))]);
    
end





            
            



