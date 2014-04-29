function h = plt_IBIdist(IBI_data, dt, varargin)

timeVec = 0:dt:max(IBI_data);
counts = histc(IBI_data,timeVec);
tag = 'IBI statistics';
if nargin>1
    tag = varargin{1};
end
h = figure('name', tag, 'NumberTitle', 'off');
bar_h = bar(timeVec,counts/length(IBI_data),'histc');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
set(gca, 'FontSize', 16)
ylabel('probability')
xlabel('IBI [s]')
title(tag);
