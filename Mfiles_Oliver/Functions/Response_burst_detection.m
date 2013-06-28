%function Response_burst_detection.
% For the detection of reponses as bursts, by means of the stimraster, stim times, for a specific set of chaannels-
%     Here realized as an externaö function
%     
%     
%     
% INPUT:   
% 
% stim_times:              stimulation times
% 
% StimRaster_Sparse:     Return value of the fct StimulusEffect_SPARSE
% 
% ANA_ch:                 Channels (MEA) for which this analysis is carried out
%     
%     
%     
%     
% OUTPUT:
% 
% Response_burst:    A cell array, one cell for each analyzed channel, storing th resuklt of the response detection

function Response_burst = Response_burst_detection(stim_times,StimRaster_Sparse,ANA_ch)


   %detect the positive parts of the stim raster (==response)
   %and make a burst detection form those spikes
   
    Nr_ana_ch = length(ANA_ch);
    Hw_ch     = cr2hw(ANA_ch);
    Nr_trials = length(stim_times);
    Responses = struct('time',[],'channel',[]);
    for jj = 1:Nr_ana_ch
        for kk=1:Nr_trials
            %find all the indices for the spikes >0
            trial_ind     = find(StimRaster_Sparse{Hw_ch(jj)+1}(:,kk) >0 );
            %construct the response structure
            if ~isempty(trial_ind)
                Responses.time    = [Responses.time full(StimRaster_Sparse{Hw_ch(jj)+1}(trial_ind,kk))' + stim_times(kk)];
                Responses.channel = [Responses.channel Hw_ch(jj)*ones(1,length(trial_ind))]; 
            end
        end
    end
    %Make a burts detection on the responses
    Response_burst = burst_detection_all_ch(Responses);

   
    %Note that this can also include bursts which come some time later than the
    %stim, depending on the window that was choosen for the stim_raster
    %calculation, therefore define the burst onsets now
    for jj=1:Nr_ana_ch
        burst_starts{jj} = cellfun(@(x) x(1), Response_burst{1,Hw_ch(jj)+1}(:,3));
        %find those bursts that are actually sue to the stim
        burst_ind  = [];
        trial_ind  = [];
        for kk=1:Nr_trials
            rel_ind =  find(burst_starts{jj}>=stim_times(kk) & burst_starts{jj}<stim_times(kk)+1);
            if ~isempty(rel_ind)
                burst_ind = [burst_ind rel_ind(1)];
                trial_ind  = [trial_ind kk];
            end
        end
        Response_burst_temp{jj}                        = Response_burst{1,Hw_ch(jj)+1}(burst_ind,:);
        Response_burst_temp{jj}(1:length(burst_ind),1) = num2cell(1:length(burst_ind));
         %define a new entry, namely the trial that leads to the detected burst
        Response_burst_temp{jj}(1:length(burst_ind),5) = num2cell(trial_ind);
        %I can conveniently define the length of the response as the time
        %between stim onset and burst end
        Response_burst_temp{jj}(1:length(burst_ind),6) = num2cell(cellfun(@(x) x(end), Response_burst_temp{jj}(:,3)) - stim_times(trial_ind)');
    end

    clear Response_burst
    Response_burst = Response_burst_temp;