%Calculation of cross correlaogram for spike trains
% Given a set of electrodes and a specified time period, calculate the
% pair-wise cross correlation. Thsi results should be plotted in a NxN plot, where N is the number of given electrodes 
% Pair-wise cross correlation was termed in D. Eytan, J. Neurophysiol 2004
% as "activity pairs" A->B, or the entailment of neuron A on B. 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
%input:
%  
% datnamne:                         The file name
% 
%
%ls:                             The usual list of spike data 
% 
% time_start, time_end           start and end times of recording period to
%                                be considered
% 
% 
% 
% CHANNEL_VEC                    A vector with MEA-style channel notation
%                                for which the crosscorrelations should be calculated
% 
% BIN_WIDTH:                     bin width for binning the spike trains, in
%                                MSEC!
% 



function [pw_cross_correl sub_handle] = PW_cross_correlation(datname,ls,burst_detection, time_start, time_end, CHANNEL_VEC, BIN_WIDTH)


hw_ch  = cr2hw(CHANNEL_VEC);
nr_ch  = length(hw_ch);
MAX_LAG         = 250;                                       % maximum lag to calculate CC, in MSEC!



binning_vec   = (time_start*3600):BIN_WIDTH/1000:(time_end*3600);
spike_trains  = zeros(length(binning_vec),nr_ch);

%find all the spikes on the resp channels first
for ii=1:nr_ch
    burst_spikes=[];
    %ch_spikes           = ls.time(find(ls.channel==hw_ch(ii) & ls.time > time_start*3600 & ls.time < time_end*3600));
    %work only on spikes in bursts
    
    %these are all the spikes in bursts for the resp channel, TAKING ONLY
    %THOSE BURSTS THAT ARE LONGER THAN MAX_LAG
    for jj=1:length(burst_detection{1,hw_ch(ii)+1})
        if (burst_detection{1,hw_ch(ii)+1}{jj,3}(end) - burst_detection{1,hw_ch(ii)+1}{jj,3}(1) ) > MAX_LAG/1000
            burst_spikes           = [burst_spikes burst_detection{1,hw_ch(ii)+1}{jj,3}];
        end
    end
    
    %TAKINGSPIKES FROM ALL BURSTS
    %burst_spikes           = [burst_spikes burst_detection{1,hw_ch(ii)+1}{:,3}];
    ch_spikes              = burst_spikes(find(burst_spikes>time_start*3600 & burst_spikes<time_end*3600));
    nr_spikes(ii)          = length(ch_spikes);
    spike_trains(:,ii)     = hist(ch_spikes,binning_vec);
    
end


%calculate the PW_cross_correlations
MAX_LAG_IND         = MAX_LAG/BIN_WIDTH;   %overwrite the initail value, this is an index now


pw_cross_correl = zeros(2*MAX_LAG_IND+1,nr_ch^2);

pw_cross_correl = xcorr(spike_trains,MAX_LAG_IND);
%supposively, the cross-correlations are stored in the matrix
%pw_cross_correl as follows: the column N is the result of the cross
%correlation of spike train at position (i,j), where j*nr_columns + i = N.
%In other words, if there are M spike trains in the original matrix, so the pair-wise cross correlation could be represented
% as a MxM matrix. The column N in the resulting matrix is the pairwise cross correlation when counting the MxM matrix in the matlab-manner (row-wise from left to right)

%normalize the pw_cross_correl to rate
for ii=1:nr_ch
    pw_ind                    = (ii-1)*nr_ch+1:ii*nr_ch;
%     for jj=1:length(pw_ind)
%         correlated_ind = pw_ind(jj) - (ii-1)*nr_ch;
%         pw_cross_correl(:,pw_ind(jj)) = pw_cross_correl(:,pw_ind(jj))./(nr_spikes(ii)*nr_spikes(correlated_ind));
%     end
    %pw_cross_correl(:,pw_ind) = pw_cross_correl(:,pw_ind)./nr_spikes(ii);    %normalize only to the firing rate of neuron A in the activity pair A->B 
     pw_cross_correl(:,pw_ind) = pw_cross_correl(:,pw_ind);                    %no normLIZATION
end



time_vec   = [-MAX_LAG_IND:MAX_LAG_IND]*BIN_WIDTH;
fig_handle = screen_size_fig();
for ii=1:nr_ch^2
    sub_handle(ii)   = subplot(nr_ch,nr_ch,ii);
    plot_handle(ii)  = plot(time_vec,pw_cross_correl(:,ii)/(pw_cross_correl(MAX_LAG_IND+1,ii)));
    %plot_handle(ii)  = plot(time_vec,pw_cross_correl(:,ii))
    hold on;
    xlabel(' delay \tau [msec] ');
    ylabel('normalized rate ');
    xlim([-MAX_LAG MAX_LAG]);
    ylims        = get(gca,'ylim');
    y_limits(ii) = ylims(2); 
   
    
    
    if ismember(ii,[1:nr_ch])
        title(['channel ', num2str(CHANNEL_VEC(ii))],'FontSize', 14);
    end

    if ismember(ii,1:nr_ch:nr_ch^2-nr_ch+1)
       plot_ind = fix(ii/nr_ch)+1;
       ylabel({['channel ', num2str(CHANNEL_VEC(plot_ind))];['normalized rate ']},'FontSize', 14);      
    end
    
    
    
end
subplot(nr_ch,nr_ch,1);
title({['datname: ', num2str(datname),', hr. ', num2str(time_start), ' to ', num2str(time_end), ' of recording'];...
    ['Cross-correlograms for activity pairs, orthogonals show autocorrelation.  Bin width ', num2str(BIN_WIDTH),' msec'];...
    ['Taking only spikes in bursts when bursts longer ', num2str(MAX_LAG),' msec . Channel ', num2str(CHANNEL_VEC(1))]},'Interpreter', 'none','FontSize', 10);
    
   autocorr_limit    = max(y_limits(1:nr_ch+1:nr_ch^2));
   cross_corr_limits = y_limits(setdiff(1:nr_ch^2,1:nr_ch+1:nr_ch^2));
   cross_corr_limit  = max(cross_corr_limits);
   set(sub_handle(1:nr_ch+1:nr_ch^2),'Ylim',[0 autocorr_limit])
   set(sub_handle(setdiff(1:nr_ch^2,1:nr_ch+1:nr_ch^2)), 'Ylim',[0 cross_corr_limit]);
   set(plot_handle(1:nr_ch+1:nr_ch^2),'Color', 'r');
   
   for ii=1:nr_ch^2
        subplot(nr_ch,nr_ch,ii)
        line([0 0],get(gca,'ylim'),'Linestyle','--','Color', 'k')
   end










