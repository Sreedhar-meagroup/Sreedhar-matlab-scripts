function preStim_bursts = recSite_prestim_bursts(NetControlData)
% function returns the pre-stimulus bursts at the recording site during the closed-loop
% experiment as a cell array the size of the no. of stimuli. Each cell
% contains the time stamps of the spikes in such a burst.

recSite_in_hwpo = cr2hw(NetControlData.Electrode_details.rec_electrode)+1;
inAChannel      = NetControlData.InAChannel;
stimTimes       = NetControlData.StimTimes;
burst_criterion = 0.2;

recChanSpikes = inAChannel{recSite_in_hwpo};
preStim_bursts = cell(size(stimTimes));

for ii = 1:length(stimTimes)
    burst_flag = 1;
    first_sp_ind = find(recChanSpikes<stimTimes(ii),1,'last');
    temp = recChanSpikes(first_sp_ind);
        while burst_flag & first_sp_ind>1
            if recChanSpikes(first_sp_ind) - recChanSpikes(first_sp_ind-1) <= burst_criterion
                temp = [recChanSpikes(first_sp_ind-1), temp];
                first_sp_ind = first_sp_ind - 1;
            else
                burst_flag = 0;
            end
        end
    preStim_bursts{ii} = temp;    
end
