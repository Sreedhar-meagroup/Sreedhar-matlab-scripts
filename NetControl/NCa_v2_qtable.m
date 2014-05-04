% Qtable analysis
for ii = 1:nSessions/2
qtab_id = num2str(ii-1);    
qname = [pathName,'qtables\','trained.qtable',qtab_id];
temp = plt_qtable(qname);
title(['Post training: ',num2str(ii)]);
end
