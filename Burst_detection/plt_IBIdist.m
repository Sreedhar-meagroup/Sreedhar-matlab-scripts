function [h,varargout] = plt_IBIdist(IBI_data, dt, varargin)
plot_flag = 1;
h = 0;

timeVec = floor(min(IBI_data)):dt:ceil(max(IBI_data));

counts = histc(IBI_data,timeVec);
tag = 'IBI statistics';
if nargin>2
    if ~strcmpi(varargin{1},'no plot')
        tag = varargin{1};
    else
        plot_flag = 0;
    end 
end

if plot_flag
    h = figure('name', tag, 'NumberTitle', 'off');
    bar_h = bar(timeVec,counts/length(IBI_data),'histc');
    box off;
    set(bar_h,'EdgeColor','w','FaceColor','k');
    set(gca,'TickDir','Out');
    set(gca,'XMinorTick','On');
    % axis tight;
    set(gca, 'FontSize', 16)
    ylabel('probability')
    xlabel('IBI [s]')
    title(tag);
end

varargout{1} = timeVec;
varargout{2} = counts/length(IBI_data);
