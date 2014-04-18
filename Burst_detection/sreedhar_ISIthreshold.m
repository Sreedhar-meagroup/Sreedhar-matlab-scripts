function NB_extrema = sreedhar_ISIthreshold(spiketimes_n_channels, varargin)

%% HELP:
% NB_extrema = sreedhar_ISIthreshold(spiketimes_n_channels,varargin) returns the
% start and stop times for network bursts(NBs) from a multichannel recording.
% Input args:
%     spiketime_n_channels: 2xN matrix of spiketimes and their
%                           corresponding channels
%      varargin (optional): 'raster', also plots the data in a raster plot.
% Output args: 
%     NB_extrema: Mx2 matrix, with each column carrying the NB start and
%                 stop times in seconds respectively for each of the M
%                 detected NBs.

%% README:
% -------------------------------------------------------------------------
% This algorithm(original implementation courtesy Oliver Weihberger) is an
% inter-spike-interval(ISI) threshold detector with various ad and post hoc
% criteria. It detects bursts first on single channel spiketrains and then
% combines this information to identify NBs. Post-hoc
% criteria were introduced to better fit the data.
% 
% Single channel burst detection is based on the following three parameters
%     1. Maximum ISI = 100 ms,
%     2. Minimum no: of spikes to qualify for a burst = 3,
%     3. Minimum IBI (inter-burst-interval) = 200 ms.
% 
% The network burst detection algorithm then lumps the single-channel
% events based on their temporal coincidence across channels.
% Its parameters are:
%     1. Minimum delay for 2 channels to be considered co-incident = 75 ms,
%     2. Minimum extra delay = 150 ms. Atmost one channel can have a delay
%        within this limit and still be considered co-incident,
%     3. Minimum no: of electrodes = 3.
% 
% Post hoc criterion : Any spike that appears atmost 50 ms prior to the
% current network burst onset (NB_onset) is included in the NB whose onset
% time is then corrected to this new value.
% -------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b) MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service
% Pack 1) Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java
% HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------

%**************************************************************************
%%
plot_flag = 0;
if nargin > 1
   plot_flag = strcmpi(varargin{1},'raster');   
   if ~plot_flag        
    disp('Warning :: The valid option is ''raster''.');
   end
end

spks.time = spiketimes_n_channels(1,:);
spks.channel = spiketimes_n_channels(2,:);

burst_detection = burstDetAllCh_sk(spks);
[~, ~, NB_onsets, NB_ends] ...
    = Networkburst_detection_sk('test_data',spks,burst_detection,10);

% modifying NB_onsets by a post hoc criterion. 
mod_NB_onsets = NB_onsets(:,2);

for ii = 1:length(NB_onsets)
    spikes_pre_NB_onset = find(spks.time > NB_onsets(ii,2)-50e-3 & ...
        spks.time < NB_onsets(ii,2), 1); % searching 50ms prior to onsets

    if ~isempty(spikes_pre_NB_onset)
        mod_NB_onsets(ii) =  spks.time(spikes_pre_NB_onset(1));
    end
end

NB_extrema = [mod_NB_onsets, NB_ends];

if plot_flag
    spontData.Spikes = spks;
    spontData.NetworkBursts.NB_extrema = NB_extrema;
    plt_gfrWithRaster(spontData);
end



%% Additional comments:

% sreedhar_ISIthreshold_data1.mat has the following details
% PID              : 328
% CID              : 4517
% MEA              : 12168
% Mea type         : 6x10
% Preparation date : 04.03.2014
% Recording date   : 02.04.2014
% Age              : 29 DIV
% Recording context: 2500 s spontaneous recording session prior to closed-loop experiment.
% Filename         : 140402_4517_spontaneous1.spike
% Further details  : 140402_4517_spontaneous1.spike.desc



