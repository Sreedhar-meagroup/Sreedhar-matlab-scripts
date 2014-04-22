function varargout = ConvertNoahSamora(varargin)
%Function which takes either Noah's spike format and converts it to
%Samora's or takes Samora's spike format and converts it to Noah's.
%Designed for Noah's data - e.g., 256 MEA.
% Inputs:
% (1) First argument, direction for conversion: 'n2s' or 's2n'
% (2) If n2s, second argument is index channel
%     If s2n, second argument is EAfile structure
% (3) If n2s, third argument is t (spike times in units of sample number)
% Outputs:
% (1) If n2s, first output is EAfile structure.
%     If s2n, first output is t
% (2) Only if s2n, second output is index channel

% ic, index channel is setup as follows:
% [ 18   52   86   205   222   239;     <- Channel IDs
%   1    1    1    1     1     1;       <- Neuron IDs (in case sorting was used, otherwise all 1's)
%   1    505  1661 6779  6895  6904;    <- Index in t vector where spike times for a given channel start
%   504  1660 6778 6894  6903  6921 ]   <- Index in t vector where spike times for a given channel end

% t, spike times is setup as follows:
% [1136269,1136250,1136285...1.6607e+07, 1375335...1.6604e+07] <- Spike times in sample number (ascending order within channel), arranged by channel. Sampled at 12KHz
% [1      ,2      ,3...      504       , 505...    1660]       <- Index (not part of vector, just for illustration)
% [18     ,18     ,18...     18        , 52...    52]          <- Channel (not part of vector, just for illustration)
% Written by: Noah Levine-Small
% Last Modified: 22/04/2014

%% 16x16 90CW MeaMap Inverted
MeaMap = [127,130,223,254,55,91,122,21,52,88,115,18,45,81,82,128;196,226,193,224,25,56,92,119,87,118,17,48,84,111,112,13;195,225,158,194,123,26,53,89,117,20,47,83,114,44,79,109;159,198,228,157,93,124,23,54,19,50,86,113,43,80,110,11;131,162,197,227,253,94,121,24,49,85,116,14,77,107,12,39;229,134,161,200,230,160,156,51,22,15,46,78,108,9,40,75;202,232,133,164,199,132,155,90,120,41,42,105,10,37,76,106;166,201,231,136,163,135,234,129,16,74,35,7,38,73,103,8;138,233,203,168,137,165,204,215,125,104,5,33,6,101,71,36;236,206,167,140,235,174,173,150,186,63,2,69,34,3,102,72;205,170,139,238,208,183,245,185,151,247,30,100,70,31,4,99;169,144,237,207,142,180,192,153,59,250,220,217,97,67,32,1;143,242,212,171,182,145,175,187,149,57,248,218,27,98,68,29;241,211,172,184,243,177,189,152,62,251,221,246,216,28,95,65;141,240,239,213,179,191,176,188,148,60,252,222,244,214,96,66;255,210,209,181,147,178,190,154,61,146,58,249,219,64,126,256];

%% Which Direction to Convert?
direction = varargin{1};

%% Perform Conversion
switch direction
    case 'n2s'
        ic=varargin{2};
        if isstruct(ic)
            error('Invalid input for conversion direction, did you mean s2n?');
        end
        if size(varargin)<3
            error('Insufficient Number of Arguments')
        else
            t=varargin{3};
        end
        vec = ConvertIC2Samora(ic);
        varargout{1}.INFO.MEA.TYPE = '16x16';
        varargout{1}.RAWDATA.CHANNELMAP = MeaMap; % or your channelmap variable
        varargout{1}.RAWDATA.SPIKETIME = t/12*1000; %Spikes in Microscecond
        varargout{1}.RAWDATA.SPIKECHANNEL = vec;
        varargout{1}.RAWDATA.GROUNDEDCHANNEL = [];
        varargout{1}.RAWDATA.REFERENCECHANNEL = [];
        varargout{1}.INFO.FILE.LIMITS=[0,9.843999995291233e+09];
    case 's2n'
        EAfile=varargin{2};
        if ~isstruct(EAfile)
            error('Invalid input for conversion direction, did you mean n2s?');
        end
        varargout{1} = EAfile.RAWDATA.SPIKETIME*12/1000;
        varargout{2} = ConvertSamora2IC(EAfile.RAWDATA.SPIKECHANNEL);
    otherwise
        error('Incorrection Direction Assignment. Please make s2n or n2s your first input');
end

%% Sub-functions
    function ic = ConvertSamora2IC(vec);
        % Function to convert Samora's format into ic. Essentially
        % replaces vec (matrix of size (1,numel(t)) with ic where for each spike
        % time recorded in t, the appropriate channel ( ic(1,x) ) where this spike was recorded
        % is placed in ic
        % by: Noah Levine-Small, last modified: 23/10/12
        ic(1,:) = unique(vec,'stable');
        for ii=1:size(ic,2)
            ic(2,ii) = 1;
            ic(3,ii)=find(vec==ic(1,ii),1,'First');
            ic(4,ii)=find(vec==ic(1,ii),1,'Last');
        end
    end

    function vec = ConvertIC2Samora(ic);
        % Function to convert the t,ic format into Samora's format. Essentially
        % replaces ic with vec (matrix of size (1,numel(t)) where for each spike
        % time recorded in t, the appropriate channel ( ic(1,x) ) where this spike was recorded
        % is placed in vec
        % by: Noah Levine-Small, last modified: 23/10/12
        for iii=1:size(ic,2)
            vec(ic(3,iii):ic(4,iii))=ones(ic(4,iii)-ic(3,iii)+1,1).*ic(1,iii);
        end
    end

end

