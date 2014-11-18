% Saving variables from valid experiments 
% Exp 3,5,6,7

%% setting the directory structures and data-set locations


rootdir = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\';
dataPool.Expdir = {[rootdir,'Experiments3\NetControl\']; ...
            [rootdir,'Experiments5\NetControl\']; ...
            [rootdir,'Experiments6\NetControl\']; ...
            [rootdir,'Experiments7\NetControl\']; ...
            };

dataPool.pathNames{1} = {...
 'PID317_CID4346\131009_session_1_4346\131009_session_1';...
 'PID317_CID4346\131014_session_2_4346\131014_session_2'; ...
 'PID317_CID4350\131014_session_1_4350\131011_session_1';...
 };

dataPool.pathNames{2} = {...
 'PID321_CID4409\2014-02-04_session5';...
 'PID323_CID4449\2014-02-11_session1'; ...
 };

dataPool.pathNames{3} = {...
 '\PID328_CID4518\2014-04-02_session1\';...
 '\PID328_CID4517\2014-04-03_session1\'; ...
 '\PID328_CID4517\2014-04-03_session2\';...
 '\PID328_CID4515\2014-04-06_session1\';...
 '\PID329_CID4528\2014-04-09_session1\';...
 '\PID329_CID4528\2014-04-09_session2\';...
 '\PID329_CID4524\2014-04-10_session1\';...
 '\PID329_CID4525\2014-04-11_session1\';...
 '\PID329_CID4525\2014-04-14_session2\';...
 '\PID332_CID4569\2014-05-05_session3\';...
 };


dataPool.pathNames{4} = {...
 'PID332_CID4569\2014-04-26_session1';...
 'PID332_CID4569\2014-04-27_session2'; ...
 'PID334_CID4591\2014-05-15_session1'; ...
 };

%% Iterating through the structure in sec.1
Expno = [3,5,6,7];
for expdir = 1:1%length(dataPool.Expdir)
    for sample = 1:length(dataPool.pathNames{expdir})
        NetControlData = eval(['NetControl_analysis_Exp',num2str(Expno(1)),'();']);
        CID = NetControlData.Culture_details.CID;
        session_no = NetControlData.Session_number;
        AllData.(['C',CID,'_s',session_no]) = NetControlData;
        disp([':: ',CID,' session: ', session_no, ' SUCCESSFULLY LOADED ::']);
    end
end

%% Alter
for sample = 1:length(dataPool.pathNames)
    clc
    close all;
    clearvars -except ImportantVars dataPool sample
    datName = dataPool.datName;
    pathName = dataPool.pathNames{sample};
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

% save 'C:\Sreedhar\Mat_work\Closed_loop\workspace_garage\ImportantVars_E6.mat' ImportantVars;
