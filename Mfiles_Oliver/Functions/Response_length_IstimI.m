%%%%For given channels, plot the nr. of induced spikes, depending
%%%%on the Interstim interval, in a raster plot. I.e. IstimI value on the
%%%%x-axis, Nr. of induced spikes on the y-axis, for each trial one
%%%%datapoint. I have seen that for very small IStimIs, the Nr. of induced
%%%%spikes is decreased, but it saturates fir IsIs>4 sec.
%In the experiments conducted with sinudoidal input stim, the IstimI come in discrete steps of one sec
%define the IstimI

function Response_length_IstimI(datname,ls,stim_times,stim_raster, nr_spikes, CHANNELS)


Nr_ch        = length(CHANNELS);
Hw_ch        = cr2hw(CHANNELS);
Nr_trials    = length(stim_times);

Nr_intervals = 10;
IstimI       = diff(stim_times);




%find the bursts in the responses:
%make a burst detection for the resp channels during the resp period, FROM
%the RESPONSE SPIKES
Responses = struct('time',[],'channel',[]);
for ii=1:Nr_ch
    
    for jj=1:Nr_trials
        %find all the indices for the spikes >0
        trial_ind     = find(stim_raster(Hw_ch(ii)+1,:,jj) >0 );
  
        %construct the response structure
        if ~isempty(trial_ind)
            Responses.time    = [Responses.time stim_raster(Hw_ch(ii)+1,trial_ind,jj) + stim_times(jj)];
            Responses.channel = [Responses.channel Hw_ch(ii)*ones(1,length(trial_ind))]; 
        end
       
    end
end

Response_burst = burst_detection_all_ch(Responses);


%Note that this can also include bursts which come some time later than the
%stim, depending on the window that was choosen for the stim_raster
%calculation, therefore define the burst onsets now
for ii=1:Nr_ch
    burst_starts{ii} = cellfun(@(x) x(1), Response_burst{1,Hw_ch(ii)+1}(:,3));
    %find those bursts that are actually sue to the stim
    burst_ind  = [];
    trial_ind  = [];
    for jj=1:Nr_trials
        rel_ind =  find(burst_starts{ii}>=stim_times(jj) & burst_starts{ii}<stim_times(jj)+1);
        if ~isempty(rel_ind)
            burst_ind = [burst_ind rel_ind(1)];
            trial_ind  = [trial_ind jj];
        end
    end
    Response_burst_temp{ii}                        = Response_burst{1,Hw_ch(ii)+1}(burst_ind,:);
    Response_burst_temp{ii}(1:length(burst_ind),1) = num2cell(1:length(burst_ind));
     %define a new entry, namely the trial that leads to the detected burst
    Response_burst_temp{ii}(1:length(burst_ind),5) = num2cell(trial_ind);
    %I can conveniently define the length of the response as the time
    %between stim onset and burst end
    Response_burst_temp{ii}(1:length(burst_ind),6) = num2cell(cellfun(@(x) x(end), Response_burst_temp{ii}(:,3)) - stim_times(trial_ind)');
end

clear Response_burst
Response_burst = Response_burst_temp;



%go over to find the trials with different IStimI
%find the indices in IstimI where it is either 1,2,3,...sec
%work in discrete steps
for jj=1:Nr_intervals;
    IstimI_ind{jj} = find(IstimI>=jj-1 +0.5 & IstimI<=jj+0.5);
end


screen_size_fig();
color_order = get(gca,'Colororder' )

mean_Resp_length = cell(Nr_ch, Nr_intervals);
for ii =1:Nr_ch
    for jj=1:Nr_intervals
        %the following finds the stim trials with IstimI jj, where channel
        %ii responds with a burst, and stores the row-index in
        %Response_burst for this channels. use this to calculate the length
        %later
        %I have to take the IstimI+1 stim trials, because to stim nr xx
        %belongs IstimI nr xx-1
        [actual_resp_trials ind_a ind_b]=intersect([Response_burst{ii}{:,5}], IstimI_ind{jj}+1);
        mean_Resp_length{ii,jj}(1)    = mean([Response_burst{ii}{ind_a,6}]);
        mean_Resp_length{ii,jj}(2)    = length(ind_a);
        mean_Resp_length{ii,jj}(3)    = std([Response_burst{ii}{ind_a,6}]);
        mean_Resp_nr_spikes{ii,jj}(1) = mean([Response_burst{ii}{ind_a,2}]);
        mean_Resp_nr_spikes{ii,jj}(2) = length(ind_a);
        mean_Resp_nr_spikes{ii,jj}(3) = std([Response_burst{ii}{ind_a,2}]);
    end  
    %to plot the Response length
%     plot(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_length(ii,:)),'d','Markersize', 12,'Color',color_order(ii,:)); 
%     hold on
    %errorbar(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_length(ii,:)),cellfun(@(x) x(3), mean_Resp_length(ii,:)),'-r');
    
     %to plot the response nr spikes
     plot(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_nr_spikes(ii,:)),'d','Markersize', 12,'Color',color_order(ii,:)); 
     hold on
%      %also include the errorbars
%      errorbar(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_nr_spikes(ii,:)),cellfun(@(x) x(3), mean_Resp_nr_spikes(ii,:)),'-r')
end

legend_string = num2str(CHANNELS');
legend(legend_string);



for ii=1:Nr_ch
     %estimate a polynomial fir
    %poly_coeff(ii,:) = polyfit(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_length(ii,:)),6);
    %poly_coeff(ii,:) = polyfit(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_nr_spikes(ii,:)),6);
    %poly_eval        = polyval(poly_coeff(ii,:),1:Nr_intervals);
    %plot(1:Nr_intervals,poly_eval,'Color', color_order(ii,:));
    %estimate an exponential saturation fit of the form A*(1 -
    %exp(-lambda*t))
    [estim_param model] = exp_saturation_fit(1:Nr_intervals,cellfun(@(x) x(1), mean_Resp_nr_spikes(ii,:)));
    %evaluate the model
    [sse Fit_model] = model(estim_param);
    plot(1:Nr_intervals,Fit_model,'Color', color_order(ii,:));
    hold on
end
xlim([0 Nr_intervals])
xlabel('Inter stimulus Interval [sec] ');
%ylabel('Average Nr. of elicited spikes');
ylabel('Average Response length [sec]');
title({['datname: ', num2str(datname)];...
    ['Calculation of the (average) Nr. of induced spikes,for individual channels, as a function of the Inter stimulus interval']},'Interpreter', 'none')



% %give rasters with different examples for stim trials that have a long,
% %medium or short IstimI; the rasters, i.e the responses sould look
% %different. The rasters, i.e. the spike responses should have been
% %extracxted previously, e.g. with the fct extract_short_term_response
% 
Nr_int_plot = 7;
subplot_r   = Nr_int_plot;
subplot_c   = Nr_ch;
diff_istim_rasters_fig = screen_size_fig

for ii=1:Nr_int_plot
  
    for jj=1:Nr_ch
          subplot(subplot_r, subplot_c,(ii-1)*Nr_ch+jj);
          Trial_vec = IstimI_ind{ii}+1;
        
         for kk=1:length(Trial_vec)
             trial = Trial_vec(kk);
           plot(stim_raster(Hw_ch(jj)+1,1:nr_spikes(Hw_ch(jj)+1,trial),trial),kk*ones(nr_spikes(Hw_ch(jj)+1,trial),1),'ok','MarkerSize',2,'Markerfacecolor','k','Markeredgecolor','k');
           hold on;
         end;
         ylim([0 length(Trial_vec)]);
         if ii==1
             subplot(subplot_r, subplot_c,jj)
             title(['Channel: ', num2str(CHANNELS(jj))]);
            
             xlabel('time r.t. stimulus [sec]');
         end
    end
    subplot(subplot_r, subplot_c,(ii-1)*Nr_ch+1)
    ylabel(['Trial, IstimI', num2str(ii),'seconds']);
    
end

%  
 
 
 
 
 
 
