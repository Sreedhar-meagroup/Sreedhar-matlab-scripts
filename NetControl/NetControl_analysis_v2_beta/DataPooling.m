dataPool.datName = 'spon_train.spike';
pathRoot = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\NetControl\';
dataPool.pathNames = {...
 [pathRoot, '\PID328_CID4518\2014-04-02_session1\'];...
 [pathRoot, '\PID328_CID4517\2014-04-03_session1\']; ...
 [pathRoot, '\PID328_CID4517\2014-04-03_session2\'];...
 [pathRoot, '\PID328_CID4515\2014-04-06_session1\'];...
 [pathRoot, '\PID329_CID4528\2014-04-09_session1\'];...
 [pathRoot, '\PID329_CID4528\2014-04-09_session2\'];...
 [pathRoot, '\PID329_CID4524\2014-04-10_session1\'];...
 [pathRoot, '\PID329_CID4525\2014-04-11_session1\'];...
 [pathRoot, '\PID329_CID4525\2014-04-14_session2\'];...
 [pathRoot, '\PID332_CID4569\2014-05-05_session3\'];...
 };


for sample = 1:length(dataPool.pathNames)
    clc
    close all;
    clearvars -except GlobalData dataPool sample
    datName = dataPool.datName;
    pathName = dataPool.pathNames{sample}
    NetControl_analysis_v2_1;
    %% learned time
    CID = NetControlData.Culture_details.CID;
    session_number = NetControlData.Session_number;
    for ii = 2:2:nSessions
        learnedTime_s(ii/2) = mean(silence_s(session_vector(ii)+1:session_vector(ii+1)));
    end
    GloablData.(['Data_',CID,'_s',session_number]).learnedTime_s = learnedTime_s;

    %% The raw data
%     GlobalData.(['Data_',CID,'_s',session_number]).NetControlData =
%     NetControlData; %  all data

%  only spont (pre and post)
    GlobalData.(['Data_',CID,'_s',session_number]).SpontaneousData.Pre =  NetControlData.Pre_spontaneous; 
    GlobalData.(['Data_',CID,'_s',session_number]).SpontaneousData.Post = NetControlData.Post_spontaneous; 
    
    %% Prespont IBI statistics

    [~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Pre_spontaneous.NetworkBursts.IBIs,dt,'no plot');
    maximizer_s = timeVec(counts_norm == max(counts_norm));
    till_here   = find(timeVec>learnedTime_s(end),1,'first');
    prob_interruption = sum(counts_norm(1:till_here));
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.NetPeak = maximizer_s;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.prob_interruption = prob_interruption ;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.distData.timeVec = timeVec;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.distData.counts_norm = counts_norm;



    [~,timeVec_rc,counts_norm_rc] = plt_IBIdist(NetControlData.Pre_spontaneous.RecChannelBursts.IBIs,dt,'no plot');
    maximizer_s_rc = timeVec_rc(counts_norm_rc == max(counts_norm_rc));
    till_here_rc   = find(timeVec_rc > learnedTime_s(end),1,'first');
    prob_interruption_rc = sum(counts_norm_rc(1:till_here_rc));
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.recChanPeak = maximizer_s_rc;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.prob_interruption_rc = prob_interruption_rc ;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.distData.timeVec_rc = timeVec_rc;
    GlobalData.(['Data_',CID,'_s',session_number]).preSpont.distData.counts_norm_rc = counts_norm_rc;

    
    %% Postspont IBI statistics

    [~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Post_spontaneous.NetworkBursts.IBIs,dt,'no plot');
    maximizer_s = timeVec(counts_norm == max(counts_norm));
    till_here   = find(timeVec>learnedTime_s(end),1,'first');
    prob_interruption = sum(counts_norm(1:till_here));
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.NetPeak = maximizer_s;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.prob_interruption = prob_interruption ;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.distData.timeVec = timeVec;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.distData.counts_norm = counts_norm;

    
    
    [~,timeVec_rc,counts_norm_rc] = plt_IBIdist(NetControlData.Post_spontaneous.RecChannelBursts.IBIs,dt,'no plot');
    maximizer_s_rc = timeVec_rc(counts_norm_rc == max(counts_norm_rc));
    till_here_rc   = find(timeVec_rc > learnedTime_s(end),1,'first');
    prob_interruption_rc = sum(counts_norm_rc(1:till_here_rc));
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.recChanPeak = maximizer_s_rc;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.prob_interruption_rc = prob_interruption_rc ;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.distData.timeVec_rc = timeVec_rc;
    GlobalData.(['Data_',CID,'_s',session_number]).postSpont.distData.counts_norm_rc = counts_norm_rc;
    
    GlobalData.(['Data_',CID,'_s',session_number]).Emodel_para = getEmodelPara(NetControlData);
    
end

save('C:\Sreedhar\Mat_work\Closed_loop\workspace_garage\GlobalData_E6_onlySpontaneous.mat', 'GlobalData', '-v7.3');
