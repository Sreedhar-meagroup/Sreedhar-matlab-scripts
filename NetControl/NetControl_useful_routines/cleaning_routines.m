function spks = cleaning_routines(spikes, stimTimes, electrode_details, thresh)
% Runs through the gamut of cleaning and artifact removal routines.
% INPUT ARGS : spikes, (meabench data structure)
%              stimTimes, vector of stimulation times 
%              electrode_details, structure returned by the function extract_elec_details()


% offset correction
off_corr_contexts = offset_correction(spikes.context); % comment these two lines out to switch off offset correction
spikes_oc = spikes;
spikes_oc.context = off_corr_contexts;

% cleaning based on slopes and spike shape
[spks, selIdx, rejIdx] = cleanspikes(spikes_oc, thresh);

% blanking spikes in a 1ms span after each stimulation
spks = blankArtifacts(spks,stimTimes,1);

% removing the switching artifacts if any
spks = cleandata_artifacts_sk(spks,'synch_precision', 120, 'synch_level', 0.3);

% Adding additional data to the structure (review this procedure later)
spks.stimTimes = stimTimes;
% spks.stimSites = repmat(electrode_details.stim_electrodes,size(stimTimes));
% spks.recSite = electrode_details.rec_electrodes;