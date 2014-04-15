function h = plt_IBIdist(data, dt, varargin)

IBIs = data.NetworkBursts.IBIs;
timeVec = 0:dt:max(IBIs);
counts = histc(IBIs,timeVec);
tag = 'IBI statistics';
if nargin>1
    tag = varargin{1};
end
figure('name', tag, 'NumberTitle', 'off');
bar_h = bar(timeVec,counts/length(IBIs),'histc');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
set(gca, 'FontSize', 16)
ylabel('probability')
xlabel('IBI [s]')
title(tag);
