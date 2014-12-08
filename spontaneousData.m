function SpontaneousData = spontaneousData(varargin)
% spon_data = spontaneousData(varargin):
% INPUT Arguments, in the following order:
%     1. Experiment no. (optional);  default = 5
%     2,3,... parameter, value pairs e.g. spontaneousData('burst_detector', ISIN_threshold)

%% Version info, aim
% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site

% Author: Sreedhar S Kumar
% Date: 12.09.2014
%--------------------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b)
% MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
% ----------------------------------------------------------------------------------------------------

%% Initial gimmicks; inviting the data
    Exp_no = 8; % default value
    burst_detector = 'ISI_threshold'; % Could be 'ISI_threshold' or 'ISIN_threshold'
    if nargin    
        if isa(varargin{1},'double')
            Exp_no = varargin{1};
        elseif mod(nargin-1,2)
            pvpmod(varargin);
        else
            disp('Check input arguments');
        end
    end


    disp(['The applied burst-detector:', burst_detector])
    
    if ~exist('datName','var')|| ~exist('pathName','var')
        [datName,pathName] = chooseDatFile(Exp_no,'Spontaneous');
    end
    datRoot = datName(1:strfind(datName,'.')-1);
    spikes=loadspike_sk([pathName,datName],2,25);
    try
        thresh  = extract_thresh([pathName, datName, '.desc']);
    catch
        thresh = input('Enter the threshold manually: ');
    end
           
%% Cleaning spikes, getting them into channels
    off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
    spikes_oc = spikes;
    spikes_oc.context = off_corr_contexts;
    [spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
    spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts
    % [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh);

%     spks = spikes_oc;% switching off cleaning
    inAChannel = cell(60,1);
    for ii=0:59
        inAChannel{ii+1,1} = spks.time(spks.channel==ii);
    end
    
    
    
%% Burst detection part
if strcmpi(burst_detector, 'ISI_threshold')
    NetworkBursts = sreedhar_ISI_threshold(spks);
elseif strcmpi(burst_detector, 'ISIN_threshold')
    NetworkBursts = sreedhar_ISIN_threshold(spks);
end


%% Data logging
SpontaneousData.fileName = datRoot;
SpontaneousData.Spikes = spks;
SpontaneousData.InAChannel = inAChannel;
SpontaneousData.NetworkBursts = NetworkBursts;
SpontaneousData.NetworkBursts.BurstDetector = burst_detector;
SpontaneousData.Readme.fileName = 'Holds filename of data in the format YYMMDD_PID_CID_DIV_description.';
SpontaneousData.Readme.Spikes = 'Holds MEABench data structure with spike-times,channels, heights, widths, cutouts(-2ms to +3ms around peak) and channel-wise thresholds respectively.';
SpontaneousData.Readme.InAChannel = 'A 60x1 matlab cell array with each cell holding spike-times recorded at that channel.';
SpontaneousData.Readme.NetworkBursts = 'NB_slices (cell array of structs)- Struct holds time-stamps and channel numbers corresponding to each network burst (cell). NB_extrema is an Nx2 matrix holding the detected starts and ends of each NB. IBIs is a vector of inter-butst-intervals. Burst-detector holds the algorithm used.';



