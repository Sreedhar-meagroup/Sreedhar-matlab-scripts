function NB_extrema = sreedhar_ISIN_threshold(spiketimes_n_channels, varargin)

%% HELP:
% NB_extrema = sreedhar_ISI_N_threshold(spiketimes_n_channels,varargin) returns the
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
% For details regarding this algorithm, refer Bakkum et al.
% (2014),`Parameters for burst detection', Frontiers in Computational
% Neuroscience, doi:10.3389/fncom.2013.00193. Briefly, a network burst is
% reported when N spikes occurred in less than T ms. N is the no: of spikes
% in the smallest burst to consider, and the threshold time T is
% automatically determined from observing the probability distribution of
% inter-spike-intervals.

% N is set to 10 in this function.
% 
% -------------------------------------------------------------------------
% MATLAB Version: 8.2.0.701 (R2013b) MATLAB License Number: 886889
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service
% Pack 1) Java Version: Java 1.7.0_11-b21 with Oracle Corporation Java
% HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------

%**************************************************************************


plot_flag = 0;
if nargin > 1
   plot_flag = strcmpi(varargin{1},'raster');   
   if ~plot_flag        
    disp('Warning :: The valid option is ''raster''.');
   end
end

spks.time = spiketimes_n_channels(1,:);
spks.channel = spiketimes_n_channels(2,:);

Steps = 10.^[-5:.05:1.5];
N = 10;  % N is set to 10
valleyMinimizer_ms = HistogramISIn(spks.time, N, Steps); % The time threshold is identified


Spike.T = spks.time;
Spike.C = spks.channel;
ISI_N = valleyMinimizer_ms/1e3; % in seconds

[Burst Spike.N] = BurstDetectISIn( Spike, N, ISI_N );

NB_extrema = [Burst.T_start', Burst.T_end'];

if plot_flag
    spontData.BurstDetector = 'ISI_N threshold';
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