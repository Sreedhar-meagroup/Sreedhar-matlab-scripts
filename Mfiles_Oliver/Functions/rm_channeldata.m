%A FUNCTION TO REMOVE SOME THRASH FROM DATASETS, I.E IF A CHANNESL IS
%EXTREMELY NOISY    

%input
%ls:                the spike information, with the usual entries, which has to be cleaned
%mea_channel:       one (or more) channels whose raw data should be removed

%output:
%ls_mew           the new, modified spike information


function ls_new=rm_channeldata(ls,mea_channel)

hw_channel     = cr2hw(mea_channel);

%if there are more than ome channels given
nr_channels=length(mea_channel)
ch_ind         = find(ls.channel==hw_channel);

ls.channel(ch_ind)=[];
ls.time(ch_ind)=[];
ls.height(ch_ind)=[];
ls.width(ch_ind)=[];
ls_new=ls;