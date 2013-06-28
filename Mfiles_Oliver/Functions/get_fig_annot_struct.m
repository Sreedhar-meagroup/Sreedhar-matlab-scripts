% for better figure annotation, fill the 'Userdata' property for each
% figure, with a specified set of fields that give various, comprehensive 
%information

function S=get_fig_annot_struct();

S=struct();
S.datname                = [];
S.recording_length       = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make the field stimulation have various subfields
S.stimulation            = [];
S.stimulation.paradig    = [];
S.stimulation.time       = [];
S.stimulation.type       = [];
S.stimulation.IstimI     = [];
S.stimulation.amplitude  = [];
S.stimulation.length     = [];
S.stimulation.channel    = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.analysis               = [];
S.description            = [];




