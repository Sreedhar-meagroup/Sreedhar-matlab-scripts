%From Responses and the detected bursts therein, calculate the time of the
%LAST spontaneous burst that preceeded this response
%function [Burst_resp_timediff] = Time_to_last_burst(Response_burst,Prestim_burst,CHANNELS,stim_times)
%
% 
% 
% 
% 
% INPUT:
% datname:           The name of the dataset
% 
% Response_burst     A cell array, one cell for each analyzed channel in
%                    Stim_modul_spont_act. It is basically a burst detection on the response
%                    spikes.
% 
% Pre_stim_burst     Cell array, one cell for each of 60 channels. Only the cells for the resp. analyzed channels are filled. Also a return
%                    value from Stim_modul_spont_act. Stores the detected bursts in the pre
%                    stim period
% 
% CHANNELS           The channels for which this here analysis should be run.
% 
%%stim_times          The stimulation times
% 
% varargin              Can define if result should be plotted (=1) or not (=0)
% 
% 
% OUTPUT:
% Burst_resp_timediff  Cell array, one cell for each anayzed channel, the time since the last burst, i.e. the gap between the end of the last burst and the following stimulation.
% It also stores the length of the response and the stimulaion trial number.
% 
% param_est           A parameter estimation for the fit to the experimental data
%
function [Burst_resp_timediff param_est] = Time_to_last_burst(datname,Response_burst,Prestim_burst,CHANNELS,stim_times,varargin)

Nr_ch = length(CHANNELS);
Hw_ch = cr2hw(CHANNELS);


for ii=1:Nr_ch
    
    
    Prestim_burst_start{ii} = cellfun(@(x) x(1),Prestim_burst{1,Hw_ch(ii)+1}(:,3));
    Prestim_burst_end{ii}   = cellfun(@(x) x(end),Prestim_burst{1,Hw_ch(ii)+1}(:,3));
    
    Nr_burst_resp           = size(Response_burst{ii},1);
    Resp_starts             = cellfun(@(x) x(1),Response_burst{ii}(:,3));
    
   
    for jj=1:Nr_burst_resp
        
        stim_trial        = Response_burst{ii}{jj,5};
        if stim_trial>1
            
             prestim_burst_ind = find(Prestim_burst_start{ii} < Resp_starts(jj) & Prestim_burst_start{ii}>stim_times(stim_trial-1));
        else
            %for the first stim trial, look at a period before the
            %stimulation as long a sthe mean IstimI. This mean IstimI is
            %estimated from the diff of all stim_times
            prestim_burst_ind = find(Prestim_burst_start{ii} < Resp_starts(jj) & Prestim_burst_start{ii}>Resp_starts(jj)-mean(diff(stim_times)) );
        end
       
        
        if ~isempty(prestim_burst_ind)
           
            %store the time since the last burst here
            Burst_resp_timediff{ii}(jj,1) = Resp_starts(jj) - Prestim_burst_end{ii}(prestim_burst_ind(end));
            %store the length of the response here:
            Burst_resp_timediff{ii}(jj,2) = Response_burst{ii}{jj,6};
            %store the stim trial nr here
            Burst_resp_timediff{ii}(jj,3) = stim_trial;
            
            %As a further measure, calculate the average length of the
            %occurred burst in the pre stimulus period
            burst_lengths                  = Prestim_burst_end{ii}(prestim_burst_ind) - Prestim_burst_start{ii}(prestim_burst_ind);
            Burst_resp_timediff{ii}(jj,4)  = mean(burst_lengths);
            %also simply calculate the Nr of bursts occurring in this period
            Burst_resp_timediff{ii}(jj,5) = length(prestim_burst_ind);
          
        else
            Burst_resp_timediff{ii}(jj,1) = NaN;
            Burst_resp_timediff{ii}(jj,2) = Response_burst{ii}{jj,6};
            Burst_resp_timediff{ii}(jj,3) = stim_trial;
            Burst_resp_timediff{ii}(jj,4) = NaN;
            Burst_resp_timediff{ii}(jj,5) = NaN;
        end
        
    end
end



%%%Only plot if varargin ==1
if varargin{1}==1
    
else 
    param_est = cell(Nr_ch);
    return
end

%plot the Tiem to the last burst vs  the resposne length
subplot_r = Nr_ch;
subplot_c = 1;
screen_size_fig();

for ii=1:Nr_ch
    sub_h(ii) = subplot(subplot_r,subplot_c,ii);
    x_data   = Burst_resp_timediff{ii}(:,1);
    y_data   = Burst_resp_timediff{ii}(:,2);
    %only find the real, i.e. non-NaN values
    real_ind = find(~isnan(x_data) & ~isnan(y_data));
    x_data = x_data(real_ind);
    y_data = y_data(real_ind);
    plot(x_data,y_data,'*');
    hold on;
    
    %make also an exponential fit, exponentialsaturation function
    %for such a fit there exists a fct exp_saturation_fit
    [param_est{ii} model_handle] = exp_saturation_fit(x_data,y_data);
    %evaluate teh model
    [sse fit_curve]              = model_handle(param_est{ii}); %fit_curve stores the calculated values from the model
    %sort the x_data for plotting in a straight curve
    [sort_data sort_ind]         = sort(x_data,'ascend');
    plot(x_data(sort_ind),fit_curve(sort_ind),'r');
    xlabel('Time since last burst [sec]');
    ylabel('Response length [sec] ');
    title(['Channel ', num2str(CHANNELS(ii))]);
    model_string = sprintf('A         = %5.2f \nlambda = %5.2f ', param_est{ii}(1),param_est{ii}(2));
    legend('Experiment', model_string)
end
subplot(subplot_r,subplot_c,1);
model_string = sprintf('Model A * (1 - exp(-lambda*t) )\nA         = %5.2f \nlambda = %5.2f ', param_est{1}(1),param_est{1}(2))
legend('Experiment', model_string)
title({['datname: ', num2str(datname)];['Relationship between time to last burst and response length'];...
    ['Channel ', num2str(CHANNELS(1))]},'FontSize', 12)








disp('hallo');
        