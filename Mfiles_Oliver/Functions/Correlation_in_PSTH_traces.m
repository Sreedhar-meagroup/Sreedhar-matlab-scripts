%%%%Function Correlation_in_PSTH_traces
% 
% From already recorded and partly analyzed data, I have seen that the
% responses from different stimulus locations differ in their temporal
% characteristic. With the PSTHs, I have seen that those traces have
% similar shape from same stimulus location than when the stimulus was
% applied at a different location. This means, that (some) features in the
% response could actually tell sth. about the stimulus location. Here, I
% simply want to caculate correlations between PSTH (traces) and see if
% they just not only 'look' similar, but if this can be quantified.
% I can compare PSTHs from same stimulus locations with PSTHs from
% different stimulus locations, where the first should give higher
% correlation values. 
% The correlation should be calculated from the short term response (for
% now), because only there is a similarity visible. But an interesting
% challenge would of course be to see if there is also a correlation in the
% later part of the response. This would be a more 'valuable' detection of
% correlation, because it could encode for the stimulus location with the
% long-term response, what would include the network-wide activation. Evtl.
% such correlations have to be calculated by means of higher-order
% correlations, or even in frequency space, i.e. coherence (?).
% 
% 
%INUT: 
% datname:             The name of the dataset
% 
% PSTH_CELL_ARRAY:     (for now) A 2*64 cell array, which should be constructed from 1*64 cell arrays with PSTHs as return values from the function MAKE_PSTH_8X8. 
%                      In each row are the PSTHs for a different condition,
%                      i.e. those conditions for which the cross correlation should be
%                      calculated.
% 
%CHANNELS:             Channels in MEA notation for which the cross correlation should be calculated, mainly those channels that are responding. 
% 
% 
% PRE_STIM_START:      Starting time (before the stimulus) of the PSTH
%                      trace from which the cross correlation should be
%                      calculated. IN MSEC!
% 
% POST_STIM_END:       End time (after the stimulus) of the PSTH trace
%                      (i.e. up to whhen) for which the cross correlation
%                      should be measured. IN MSEC!
% 
% MAX_CORR_LAG:        Maximum tim-lag tau of the correlation measurement,
%                      IN MSEC!
% 
%PSTH_BIN_WIDTH:       The bin width of the calculated PSTH, IN MSEC! 
% 
% TRIAL_TIME_VEC:      The time array of the PSTH, i.e. with the time
%                      before the stimulus, until the time after the stimulus, in steps of the
%                      PSTH bin width
% 
% OUTPUT:
% 
% PSTH_Cross_Corr         A 1XN, where N is the nr. of givenchannels, cell array. Each cell is a correlation vector, with lags from -MAX_CORR_LAG
%                         to +MAX_CORR_LAG.
% 
% PSTH_Cross_Corr_coeff  The value of the correlation at lag 0, which is defined as to be the actual correlation between the two PSTH traces.  
% 
% plot_handle            handles to the individual subplots, in order to
%                        define an appropriate title etc
% 
function [PSTH_Cross_Corr PSTH_Cross_Corr_coeff Subplot_handle] = Correlation_in_PSTH_traces(datname, PSTH_CELL_ARRAY, CHANNELS, PRE_STIM_START, POST_STIM_END, MAX_CORR_LAG, PSTH_BIN_WIDTH,TRIAL_TIME_VEC)

%define the nr of channels
Nr_channels = length(CHANNELS);
HW_CHANNELS = cr2hw(CHANNELS);

%find the 0-time bin in the PSTh vector
zero_time_bin = find(TRIAL_TIME_VEC == 0);

%Find those bins from which I actually want to calculate the cross
%correlation
bin_start              = zero_time_bin - PRE_STIM_START/PSTH_BIN_WIDTH;
bin_end                = zero_time_bin + POST_STIM_END/PSTH_BIN_WIDTH-1;
Correlation_bins       = bin_start:bin_end;

PSTH_Cross_Corr = cell(1,Nr_channels);

for ii = 1:Nr_channels
    
    %this is the index in the cell array ch_psth for the resp channel
    active_ch = HW_CHANNELS(ii)+1;
    %NORMALIZE the CrossCorrelation in that way that the Autocorrelations are normalized to 1.0 at 0-lag 
    [PSTH_Cross_Corr{1,ii} LAG_IND] = xcorr(PSTH_CELL_ARRAY{1,active_ch}(Correlation_bins),PSTH_CELL_ARRAY{2,active_ch}(Correlation_bins),'coeff');
    PSTH_Cross_Corr_coeff(1,ii)       = CHANNELS(ii);
    PSTH_Cross_Corr_coeff(2,ii)       = PSTH_Cross_Corr{1,ii}(find(LAG_IND==0)); 
    
end




%The resulting cell array is a 2*MAX_CORR_LAG/PSTH_BIN_WIDTH -1 long
%vector, where the correlations for 0-lag are at position
%MAX_CORR_LAG/PSTH_BIN_WIDTH

%I can simply go over and plot the correlations
%Find the vector of lag values first
LAG_VEC = LAG_IND*PSTH_BIN_WIDTH;

for ii = 1:Nr_channels
    legend_string{ii} = ['channel ', num2str(CHANNELS(ii))];
end


PSTH_Cross_Corr_fig = screen_size_fig();
color_spec          = get(gca,'Colororder');

%PLOT maxiamlly three channels per figure, then make a new figure
Nr_ch_per_plot = 3;
Nr_plots       = ceil(Nr_channels/Nr_ch_per_plot);

subplot_col = ceil(sqrt(Nr_channels));
subplot_row = ceil(Nr_channels/subplot_col);




for ii = 1:Nr_channels
    
    Subplot_handle(ii) = subplot(subplot_col,subplot_row,ii);    
   
    plot_handle(ii) = plot(LAG_VEC,PSTH_Cross_Corr{1,ii});
    hold on;
    %%plot also the correlation at lag 0 with a special marker and color
    Corr_coeff_handle(ii) = plot(0,PSTH_Cross_Corr_coeff(2,ii),'*r');
    set(Corr_coeff_handle(ii),'MarkerSize', 12);
    %plot the raw number in a text box
    text(10,PSTH_Cross_Corr_coeff(2,ii),[num2str(ceil(PSTH_Cross_Corr_coeff(2,ii)*100)/100)])
    xlabel('lag \tau [msec] ')
    ylabel ('normalized correlation');
    title(['channel: ',num2str(CHANNELS(ii))])
   
end
%legend(legend_string);
    






% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%***********************************************
% %%%A remark on the following lines
% %This works on the combined collection of cross correlated PSTH, it was
% %first tried on the datasets 04_09_07 and 05_09_07.
% % With the upper function, I calculated the cross correlation in PSTH under
% % various conditions and then stored all of them in a cell array
% % "PSTH_ALL_CC", where
% % PSTH_ALL_CC{ii,1}  = A string describing the kind of cross correlated PSTHs(i.e. same stim channel or same day)
% % 
% % PSTH_ALL_CC{ii,2}   = The return value "PSTH_Cross_Corr_coeff" from this
% % function, it stores the calculated coefficients and the according channel
% % 
% % PSTH_ALL_CC{ii,3}  = The return value "PSTH_Cross_Corr" from this
% % function. It stores, in a cell array, the calculated cross correlation
% % functions for each channel. From this, I calculated further below the
% % average across channels
% % 
% % The parameter ii is the nr. of type-different Cross correlations, in the
% % example 04_09_07_760 & 05_09_07_760 there wer four of them.
% % 
% 
% CHANNELS    = [86 66 64 46 53 37 38 74 32 57 75]
% Nr_channels = length(CHANNELS);
% 
% ALL_CC_fig = screen_size_fig();
% %nobody understands this:
% Condition_combination = [3 1; 4 1; 4 2; 3 2];
% Nr_combinations = size(Condition_combination,1);
% 
% 
% for ii = 1:Nr_combinations
%       
%     x_axis_condition_ind = Condition_combination(ii,1);
%     y_axis_condition_ind = Condition_combination(ii,2);
%     
%     COM_xaxis = [];
%     COM_yaxis = [];
%     
%    for jj = 1:Nr_channels
%         
%         channel_ind_xaxis = find(PSTH_ALL_CC{x_axis_condition_ind,2}(1,:)==CHANNELS(jj));
%         channel_ind_yaxis = find(PSTH_ALL_CC{y_axis_condition_ind,2}(1,:)==CHANNELS(jj));
%         
%         if channel_ind_xaxis & channel_ind_yaxis
%             
%             correlation_xaxis = PSTH_ALL_CC{x_axis_condition_ind,2}(2,channel_ind_xaxis);
%             correlation_yaxis = PSTH_ALL_CC{y_axis_condition_ind,2}(2,channel_ind_yaxis);
%             if ii == 1
%                 plot(correlation_xaxis,correlation_yaxis,'*');
%                 hold on;
%             elseif ii == 2
%                 plot(-correlation_xaxis,correlation_yaxis,'o');
%                 hold on;
%             elseif ii == 3
%              plot(-correlation_xaxis,-correlation_yaxis,'+'); 
%              hold on
%             elseif ii == 4
%                 plot(correlation_xaxis,-correlation_yaxis,'d');
%                 hold on
%             end                   
%                
%             COM_xaxis = [COM_xaxis correlation_xaxis];
%             COM_yaxis = [COM_yaxis correlation_yaxis];
%         end%end of the channel_ind_xaxis and channel_ind_yaxis case
%    end
%        
%    
%         COM_x(ii) = mean(COM_xaxis)
%         COM_y(ii) = mean(COM_yaxis)
%         %plot the center of mass
%         if ii == 1
%             plot(COM_x(ii), COM_y(ii),'rs','MarkerSize',10,'MarkerFaceColor','r');
%             text(COM_x(ii)+0.1, COM_y(ii)+0.1,{['"Center of mass" correlation'];[ 'x-axis : ',num2str(ceil(COM_x(ii)*1000)/1000)];['y-axis: ',num2str(ceil(COM_y(ii)*1000)/1000)]});
%         elseif ii == 2 
%             plot(-COM_x(ii), COM_y(ii),'rs','MarkerSize',10,'MarkerFaceColor', 'r');
%              text(-COM_x(ii)+0.1, COM_y(ii)+0.1,{['"Center of mass" correlation'];[ 'x-axis : ',num2str(ceil(COM_x(ii)*1000)/1000)];['y-axis: ',num2str(ceil(COM_y(ii)*1000)/1000)]});
%         elseif ii == 3
%            plot(-COM_x(ii), -COM_y(ii),'rs','MarkerSize',10,'MarkerFaceColor', 'r');
%              text(-COM_x(ii)+0.1, -COM_y(ii)+0.1,{['"Center of mass" correlation'];[ 'x-axis : ',num2str(ceil(COM_x(ii)*1000)/1000)];['y-axis: ',num2str(ceil(COM_y(ii)*1000)/1000)]});
%         elseif ii == 4
%             plot(COM_x(ii), -COM_y(ii),'rs','MarkerSize',10,'MArkerFaceColor', 'r')
%              text(COM_x(ii)+0.1, -COM_y(ii)+0.1,{['"Center of mass" correlation'];[ 'x-axis : ',num2str(ceil(COM_x(ii)*1000)/1000)];['y-axis: ',num2str(ceil(COM_y(ii)*1000)/1000)]});
%         end
%                 
% end
% axis_line(1) = line([-1 1],[0 0]);
% axis_line(2) = line([0 0],[-1 1]);
% set(axis_line(:),'LineWidth', 5,'Color','k')
% xlim([-1 1]);
% ylim([-1 1]);
% 
% %%%another thing that could be done to compare the PSTHs with different
% %%%prerequisites, is calculating an "average" correlation function
% %%%(averaging over all electrodes). The average correlation for PSTHs with
% %%%same stim electrode should have a higher peak around 0 -lag than the
% %%%average correlation for PSTHs with different stim electrodes
% 
% 
% for ii = 1:Nr_combinations
%     %first catenating all the PSTHs from the different channels, then
%     %calculating the average
%     avg_correl_function(ii,:) = mean(vertcat(PSTH_ALL_CC{ii,3}{:,:}));
% end
% 
% Avg_correl_fct_fig = screen_size_fig();
% 
% plot(LAG_VEC,avg_correl_function);
% ylim([ 0 1]);
% xlabel('Time lag \tau [msec]');
% ylabel('Normalized cross correlation of PSTH traces');
% legend({'PSTHs from stim ch 46 & 77, day 1','PSTHs from stim ch 46 & 77, day 2', 'PSTHs from stim ch 46, day 1 & 2', 'PSTHs from stim ch 77, day 1 & 2'});
% 
% 
% 
% 
% 
% 
% 



