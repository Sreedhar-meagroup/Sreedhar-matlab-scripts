function [varargout]=rasterplot_so(SPIKETIME,SPIKECHANNEL,varargin)
% plot a rasterplot with vertical lines for spikes
% okujeni 8/5/13
% ------------------------------------------------------------
dontPlot = 0;
SPIKETIME = SPIKETIME';
SPIKECHANNEL = SPIKECHANNEL'; % converted to column vector -- @ssk,12.08.13
LineStyle = 'k-';
LineWidth = 1;
Color = [0 0 0];
if strcmpi(varargin{1},'data')
    dontPlot = 1;
elseif nargin==3,
    LineStyle = varargin{1};
elseif mod(length(varargin),2)~=0
        pvpmod(varargin(2:end));
else
        pvpmod(varargin);
end

% ------------------------------------------------------------
hold on;
[SPIKETIME id]=sort(SPIKETIME);
SPIKECHANNEL = SPIKECHANNEL(id);
[~, id] = sort([1:length(SPIKETIME),1:length(SPIKETIME),1:length(SPIKETIME)]);
tvec = [SPIKETIME;SPIKETIME;SPIKETIME];
tvec = tvec(id);
lvec = [SPIKECHANNEL;SPIKECHANNEL;SPIKECHANNEL]+[zeros(size(SPIKECHANNEL));0.80*ones(size(SPIKECHANNEL));nan(size(SPIKECHANNEL))];
lvec = lvec(id)-0.4+1; % centralizes the line and adds 1 to convert to channel nos 1 - 60
% ------------------------------------------------------------

if ~dontPlot
    if nargin==3,
        varargout{1} = plot(tvec,lvec,LineStyle); 
        axis tight;
    else
        varargout{1} = plot(tvec,lvec,LineStyle,'Color',Color,'LineWidth',LineWidth); 
        axis tight;
    end
else
    varargout{1} = tvec;
    varargout{2} = lvec;
end