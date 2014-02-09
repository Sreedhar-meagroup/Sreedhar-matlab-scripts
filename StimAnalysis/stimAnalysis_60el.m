% -------------------------------------------------------------------------------------
% Purpose: Analyse 60 electrode stim responses 

% Author: SSK
% Date: 22.11.2013
%% Version details 
% MATLAB Version 7.12.0.635 (R2011a)
% MATLAB License Number: 97144
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% MATLAB                                                Version 7.12       (R2011a)
% Simulink                                              Version 7.7        (R2011a)
% Data Acquisition Toolbox                              Version 2.18       (R2011a)
% Fixed-Point Toolbox                                   Version 3.3        (R2011a)
% Image Processing Toolbox                              Version 7.2        (R2011a)
% MATLAB Compiler                                       Version 4.15       (R2011a)
% Neural Network Toolbox                                Version 7.0.1      (R2011a)
% Parallel Computing Toolbox                            Version 5.1        (R2011a)
% Signal Processing Toolbox                             Version 6.15       (R2011a)
% Statistics Toolbox                                    Version 7.5        (R2011a)
% Wavelet Toolbox                                       Version 4.7        (R2011a)
%--------------------------------------------------------------------------------------
%% Load data
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(3,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes  = loadspike([pathName,datName],2,25);

thresh  = extract_thresh([pathName, datName, '.desc']);
%% Stimulus locations and time
%Get stim info into analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
% I do this before cleaning the spikes because I do not want to clean off
% the stim times in the analog channels.

inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end

nStimSites = 60;
stimSites = repmat(hw2cr(0:59),1,50); % in cr
stimTimes = cell(1,nStimSites);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end



%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells

%Introducing dc offset correction
off_corr_contexts = offset_correction(spikes.context); % comment these two lines out if you do not want offset correction
spikes_oc = spikes;
spikes_oc.context = off_corr_contexts;
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);
% [spks, selIdx, rejIdx] = cleanspikes(spikes, thresh);
spks = blankArtifacts(spks,stimTimes,1);
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3); % cleans the switching artifacts

spks.stimTimes = stimTimes;
spks.stimSites = stimSites;

% getting data into a 60x1 cell-array; each cell stands for a channel.
inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end


%% Visualizing slices of the data

plotTimeSlice(spks, 5000, 5100); % raster plot from 100 s <= t <= 200 s