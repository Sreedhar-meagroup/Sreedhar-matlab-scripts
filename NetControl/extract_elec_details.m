function electrode_details = extract_elec_details(filename)
% Extracts the Stimulating, Recording and Response Electrodes used for closed-loop experiments(NetControl)from train.cls
% Input arg  : Filename
% Output arg : Structure with self explanatory fields 
% -------------------------------------------------------------------------------------
% MATLAB Version 7.9.0.529 (R2009b)
% Operating System: Microsoft Windows Vista Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_12-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% Date   : 09.04.2014
% Author : SSK

text = fileread(filename);

key_stim    = 'stim_stim_electrodes\s*=\s*(\d\d)';
tok_stim    = regexp(text,key_stim,'tokens');
key_rec     = 'mea_recording_electrodes\s*=\s*(\d\d)';
tok_rec     = regexp(text,key_rec,'tokens');
key_res     = 'mea_response_electrodes\s*=\s*(\d\d)';
tok_res     = regexp(text,key_res,'tokens');

electrode_details.description    = 'All electrodes are in cr(11 to 88)';
electrode_details.stim_electrode = str2double(tok_stim{:});
electrode_details.rec_electrode  = str2double(tok_rec{:});
electrode_details.res_electrode  = str2double(tok_res{:});

