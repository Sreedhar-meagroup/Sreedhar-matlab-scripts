function [PID, CID]= getCultureDetails(pathName)
% Returns the culture ID from the data file path name. This method is inelegant and needs revision.

pos = strfind(pathName, 'CID');
CID = pathName(pos+3:pos+6);

pos = strfind(pathName, 'PID');
PID = pathName(pos+3:pos+5);