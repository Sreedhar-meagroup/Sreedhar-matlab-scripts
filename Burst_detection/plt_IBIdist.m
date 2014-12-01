function [h,varargout] = plt_IBIdist(spon_data, dt, varargin)
% [h,varargout] = plt_IBIdist(spon_data, dt, varargin):
% plots and (optional) returns the normalized histogram of inter-burst intervals (IBIs).
% INPUT ARGUMENTS: spon_data(struct), dt (step-size), varargin{'no plot'/'title'}
% OUTPUT ARGUMENTS: h (fig handle), varargout{probabilities}

try 
    IBI_data = spon_data.IBIs;
catch
    try
        IBI_data = spon_data.NetworkBursts.IBIs;
    catch
        disp('Something wrong with the input data structure!!!');
        return;
    end
end

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
    set(gca, 'FontSize', 16, 'Layer','Top')
    ylabel('probability')
    xlabel('IBI [s]')
    title(tag);
end

varargout{1} = timeVec;
varargout{2} = counts/length(IBI_data);
