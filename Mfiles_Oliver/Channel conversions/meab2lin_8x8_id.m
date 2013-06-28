
%this function converts hardware channel numbers as recorded with meabench
%to linear channel ids from 1:63 as in the MCS 8x8 notation

%INPUT
%ls_in:      spike structure ls as loaded with
%            loadspike_longcutouts_noc_...

%ls_out:     returned spike structure, the entries in ls.channel are converted
%            to linear MCS 8x8 ids

function [ls_out] = meab2lin_8x8_id(ls_in)

mb59plus1_2mcs60_2 = [29,30,28,27,22,21,14,20,13,6,12,5,19,11,4,3,10,18,2,9,1,8,17,7,16,15,26,25,23,24,32,31,33,34,39,40,47,41,48,55,49,56,42,50,57,58,51,43,59,52,60,53,44,54,45,46,35,36,38,37,61,62,63,64];

for kk=0:63
    ls_in.channel(find(ls_in.channel==kk))=mb59plus1_2mcs60_2(kk+1);
end

%make reassignment, only the channel no entries were changed
ls_out             = ls_in;