dataPool.datName = 'spon_train.spike';
dataPool.pathNames = {...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID328_CID4518\2014-04-02_session1\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID328_CID4517\2014-04-03_session1\'; ...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID328_CID4517\2014-04-03_session2\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID328_CID4515\2014-04-06_session1\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID329_CID4528\2014-04-09_session1\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID329_CID4528\2014-04-09_session2\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID329_CID4524\2014-04-10_session1\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID329_CID4525\2014-04-11_session1\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID329_CID4525\2014-04-14_session2\';...
 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\PID332_CID4569\2014-05-05_session3\';...
 };


for sample = 1:length(dataPool.pathNames)
    clc
    close all;
    clearvars -except ImportantVars dataPool sample
    datName = dataPool.datName;
    pathName = dataPool.pathNames{sample}
    NetControl_analysis_v2_1;
    %% learned time
    CID = NetControlData.Culture_details.CID;
    session_number = NetControlData.Session_number;
    for ii = 2:2:nSessions
        learnedTime_s(ii/2) = mean(silence_s(session_vector(ii)+1:session_vector(ii+1)));
    end
    ImportantVars.(['Data_',CID,'_s',session_number]).learnedTime_s = learnedTime_s;

    %% Prespont IBI statistics

    [~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Pre_spontaneous.NetworkBursts.IBIs,dt,'no plot');
    maximizer_s = timeVec(counts_norm == max(counts_norm));
    till_here   = find(timeVec>learnedTime_s(end),1,'first');
    prob_interruption = sum(counts_norm(1:till_here));
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.NetPeak = maximizer_s;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.prob_interruption = prob_interruption ;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.distData.timeVec = timeVec;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.distData.counts_norm = counts_norm;



    [~,timeVec_rc,counts_norm_rc] = plt_IBIdist(NetControlData.PreSpontaneous.RecChannelBursts.IBIs,dt,'no plot');
    maximizer_s_rc = timeVec_rc(counts_norm_rc == max(counts_norm_rc));
    till_here_rc   = find(timeVec_rc > learnedTime_s(end),1,'first');
    prob_interruption_rc = sum(counts_norm_rc(1:till_here_rc));
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.recChanPeak = maximizer_s_rc;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.prob_interruption_rc = prob_interruption_rc ;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.distData.timeVec_rc = timeVec_rc;
    ImportantVars.(['Data_',CID,'_s',session_number]).preSpont.distData.counts_norm_rc = counts_norm_rc;

    
    %% Postspont IBI statistics

    [~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Post_spontaneous.NetworkBursts.IBIs,dt,'no plot');
    maximizer_s = timeVec(counts_norm == max(counts_norm));
    till_here   = find(timeVec>learnedTime_s(end),1,'first');
    prob_interruption = sum(counts_norm(1:till_here));
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.NetPeak = maximizer_s;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.prob_interruption = prob_interruption ;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.distData.timeVec = timeVec;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.distData.counts_norm = counts_norm;

    
    
    [~,timeVec_rc,counts_norm_rc] = plt_IBIdist(NetControlData.PostSpontaneous.RecChannelBursts.IBIs,dt,'no plot');
    maximizer_s_rc = timeVec_rc(counts_norm_rc == max(counts_norm_rc));
    till_here_rc   = find(timeVec_rc > learnedTime_s(end),1,'first');
    prob_interruption_rc = sum(counts_norm_rc(1:till_here_rc));
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.recChanPeak = maximizer_s_rc;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.prob_interruption_rc = prob_interruption_rc ;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.distData.timeVec_rc = timeVec_rc;
    ImportantVars.(['Data_',CID,'_s',session_number]).postSpont.distData.counts_norm_rc = counts_norm_rc;
    
    ImportantVars.(['Data_',CID,'_s',session_number]).Emodel_para = getEmodelPara(NetControlData);
    
end

save 'C:\Sreedhar\Mat_work\Closed_loop\workspace_garage\ImportantVars.mat' ImportantVars;

% %% some analysis
% exp_sessions = fieldnames(ImportantVars);
% figure(); hold on;
% for ii = 1: numel(exp_sessions)
%     final_learned(ii) = ImportantVars.(exp_sessions{ii}).learnedTime_s(end)-0.2;
%     preSpont_NetPeaks(ii) = ImportantVars.(exp_sessions{ii}).preSpont.NetPeak(1)+0.5;
%     postSpont_NetPeaks(ii) = ImportantVars.(exp_sessions{ii}).postSpont.NetPeak(1)+0.5;
%     temp = find(final_learned(ii) > ImportantVars.exp_sessions{ii}.preSpont.distData.timeVec,1,'first')
%     
%     plot(ii,ImportantVars.(exp_sessions{ii}).learnedTime_s(end)-0.2,'^');
%     plot(ii,ImportantVars.(exp_sessions{ii}).preSpont.NetPeak(1)+0.5,'r*');
%     plot(ii,ImportantVars.(exp_sessions{ii}).postSpont.NetPeak(1)+0.5,'ko');
% end
