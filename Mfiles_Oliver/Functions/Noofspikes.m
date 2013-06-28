%function NOofspikes, calculates the nr. of elicited spikes for each trail
%of stimulation for each channel
% 
%It furthermore plots the nr. of induced spikes over time, for a sum of
%channels, and a fit to this time-series for individual channels
%
% function [noofspikes] = Noofspikes(datname,ls,TRIG_CH_ANALOG,Trig_start,Trig_end,Post_time, varargin)
% input: 
% datname:              The file name
% 
% ls:                   The usual list with spike information
% 
% TRIG_CH_ANALOG:       analog channel (60-63), from which  the trigger times should be extracted 
% 
% Trig_start,Trig_end   time of the first and last trigger, in hrs
% 
% Post_time             Time after stimulus that until spikes should be
%                        tracked, in seconds
%
%varargin:              If the stim_times can't be obtained from this file, I
%                       have the option to call this function with the
%                       argument varargin that can e.g. store those stim
%                       times


%OUTPUT:
%noofspikes:             The nr of elicited spikes per trial, for each
%                        electrode
% 
function [noofspikes] =  Noofspikes(datname,ls,TRIG_CH_ANALOG,Trig_start,Trig_end,Post_time,varargin)


%%%If I give the varargin input, I define the stimulus times a priori, i.e.
%%%I have extracted those times already before calling this function
if ~isempty(varargin)
    zeitpunkte = varargin{1};
    Trig_start = zeitpunkte(1)/3600;
    Trig_end   = zeitpunkte(end)/3600;
else
%timestamps of stimuli
positionen = find(ls.channel==TRIG_CH_ANALOG & ls.time>=Trig_start*3600 & ls.time<=Trig_end*3600);
zeitpunkte = ls.time(positionen);
end

TRIALS      = length(zeitpunkte)
POSTSTIMULI = Post_time;  %working is=n sec here

noofspikes  = zeros(64,TRIALS);

for channelnr=0:63
    channelnr
    chindex=find(ls.channel==channelnr);
    chtimestamps=ls.time(chindex);
    for i=1:TRIALS  %i.e for every trial
    prepostwindow = find(chtimestamps>(zeitpunkte(i)) & chtimestamps<(zeitpunkte(i)+POSTSTIMULI));
    chtimes       = chtimestamps(prepostwindow);
    noofspikes(channelnr+1,i)=length(chtimes);
    end;
  
end;

  

%%%%Commented out, usable where I stimulated with a sinus-modulated input,
%%%%to track changes in nr. of induced spikes
% % Ch_input = input('Give channels to analyze for nr. of induced spikes over time')
% % 
% % %copy from above;
% % stim_times = zeitpunkte;
% % 
% % Nr_ch    = length(Ch_input);
% % Hw_ch    = cr2hw(Ch_input);
% % 
% % Nr_trials = length(zeitpunkte);
% % 
% % if Nr_ch>1
% %     Sum_spikes = sum(noofspikes(Hw_ch+1,:));
% % else
% %     Sum_spikes = noofspikes(Hw_ch+1,:);
% % end
% % 
% % %%%%to smooth the profile of induced spike s oer time, convolve with a
% % %%%%boxcar kernel 
% % Smooth_length = 120;
% % Smooth_kernel = 1/Smooth_length*rectwin(Smooth_length);
% % Smooth_sum_spikes = conv(Smooth_kernel,Sum_spikes);
% % Smooth_sum_spikes = Smooth_sum_spikes((floor(length(Smooth_kernel)/2):end-ceil(length(Smooth_kernel)/2)));
% % 
% % figure;
% % color_order = get(gca,'Colororder');
% % subplot(2,1,1);
% % bar(stim_times(1:Nr_trials)/3600, Smooth_sum_spikes(1:Nr_trials));
% % xlabel('time of recording [hrs]')
% % ylabel('Nr. of induced spikes over time')
% % title({['datname: ', num2str(datname)];['Summed and smoothed Nr. of induced spikes (500 msec after stimulus) for channels ', num2str(Ch_input)];...
% %     ['Smoothing over ', num2str(Smooth_length), ' trials']},'Interpreter','none');
% % 
% % poly_order = 4;
% % poly_coeff_all = polyfit(stim_times(1:Nr_trials),Smooth_sum_spikes(1:Nr_trials),poly_order);
% %  poly_eval     = polyval(poly_coeff_all,stim_times(1:Nr_trials));
% %  hold on;
% %  plot(stim_times(1:Nr_trials)/3600,poly_eval,'r');
% % 
% % 
% % 
% % %%%Make a fit of the nr of induced spikes over time for each channel
% % 
% % subplot(2,1,2)
% % for ii=1:Nr_ch
% %     Smooth_sum_ch{ii} = conv(Smooth_kernel,noofspikes(Hw_ch(ii)+1,:));
% %     Smooth_sum_ch{ii} = Smooth_sum_ch{ii}((floor(length(Smooth_kernel)/2):end-ceil(length(Smooth_kernel)/2)));
% %     poly_coeff(ii,:)  = polyfit(stim_times(1:Nr_trials),Smooth_sum_ch{ii}(1:Nr_trials),poly_order);
% %     poly_eval         = polyval(poly_coeff(ii,:),stim_times(1:Nr_trials));
% % %plot this in the same figure;
% % plot(stim_times(1:Nr_trials)/3600,poly_eval,'Color',color_order(ii,:));
% % hold on;
% % end
% % legend_string = num2str(Ch_input');
% % legend(legend_string);
% % 
% % %plot(stim_times(1:Nr_trials)/3600,poly_eval,'r');
% % xlabel('time of recording [hrs]')
% % ylabel('Average Nr. of induced spikes')
% % title({['datname: ', num2str(datname)];['Fitting an envelope to the series of induced spikes over time, for individual channels'];...
% %     ['Fitting a polynomial of ',num2str(poly_order),'th order']},'Interpreter','none');
% % 
% % 
% % 
% % 
% % 

