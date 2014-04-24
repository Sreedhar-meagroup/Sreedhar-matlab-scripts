% Qtable analysis

qname = [pathName,'qtables\','trained.qtable0'];
temp = plt_qtable(qname);
hold on;
title('Post training 1');
qname = [pathName,'qtables\','trained.qtable1'];
temp = plt_qtable(qname);
hold on;
title('Post training 2');
qname = [pathName,'qtables\','trained.qtable2'];
temp = plt_qtable(qname);
hold on;
title('Post training 3');