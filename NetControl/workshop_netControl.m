dt = 0.5;
IBI_data = NetControlData.Post_spontaneous.NetworkBursts.IBIs;
timeVec = floor(min(IBI_data)):dt:ceil(max(IBI_data));
counts = histc(IBI_data,timeVec);
learned_time = mean(NetControlData.Silence_s(end-100:end));
figure;
bar_h = plt_IBIdist(IBI_data,dt,'NetWork, post');
hold on;
bar2_h = bar(timeVec(timeVec<learned_time), counts((timeVec<learned_time))/length(IBI_data),'histc');
set(bar2_h,'EdgeColor','w','FaceColor','g');
% h = findobj(gca,'Type','patch');
% set(h,'FaceAlpha',0.5);
xlim([-1,50])
line([learned_time, learned_time],[0, 0.07],'LineWidth',2,'Color','r');

%%
