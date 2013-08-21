function [h]=rasterplot2(SPIKETIME,SPIKECHANNEL,varargin)
% plot a rasterplot with vertical lines for spikes
% okujeni 8/5/13
% ------------------------------------------------------------

SPIKETIME = SPIKETIME';
SPIKECHANNEL = SPIKECHANNEL'; % converted to column vector -- @ssk,12.08.13
LineStyle = 'k-';
LineWidth = 1;
Color = [0 0 0];
if nargin==3,
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
lvec = [SPIKECHANNEL;SPIKECHANNEL;SPIKECHANNEL]+[zeros(size(SPIKECHANNEL));0.75*ones(size(SPIKECHANNEL));nan(size(SPIKECHANNEL))];
lvec = lvec(id);
% ------------------------------------------------------------

if nargin==3,
    h = plot(tvec,lvec,LineStyle);
else
    h = plot(tvec,lvec,LineStyle,'Color',Color,'LineWidth',LineWidth);
end