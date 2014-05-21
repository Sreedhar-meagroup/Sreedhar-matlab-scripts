%% learned time
CID = NetControlData.Culture_details.CID;
session_number = NetControlData.Session_number;
for ii = 2:2:nSessions
    learnedTime_s(ii/2) = mean(silence_s(session_vector(ii)+1:session_vector(ii+1)));
end
Importantvars.(['Data_',CID,'_s',session_number]).learnedTime_s = learnedTime_s;

%% Prespont IBI statistics

[~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Pre_spontaneous.NetworkBursts.IBIs,dt,'no plot');
maximizer_s = timeVec(counts_norm == max(counts_norm));
Importantvars.(['Data_',CID,'_s',session_number]).preSpont_Net = maximizer_s;

[~,timeVec_rc,counts_norm_rc] = plt_IBIdist(RecChannel_pre.IBIs,dt,'no plot');
maximizer_s_rc = timeVec_rc(counts_norm_rc == max(counts_norm_rc));
Importantvars.(['Data_',CID,'_s',session_number]).preSpont_recChan = maximizer_s_rc;

%% Postspont IBI statistics

[~,timeVec,counts_norm] = plt_IBIdist(NetControlData.Post_spontaneous.NetworkBursts.IBIs,dt,'no plot');
maximizer_s = timeVec(counts_norm == max(counts_norm));
Importantvars.(['Data_',CID,'_s',session_number]).postSpont_Net = maximizer_s;
