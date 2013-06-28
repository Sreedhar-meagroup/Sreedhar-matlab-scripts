%file cat_datasets
% 04/04/07
% This is intended to concatenate different datasets. Due to varying experimental techniques over time,
% it happened that I have pieces of data that should better belong together.
% Here, I intend to write a function that has as input arguments the different file names, in order of concatenation,
% and the field names which should actually be concatenated. If I work with timestamps only,
% % I do only need time and channel
% 
% 
% 
% 
%function ls=cat_datasets(datname1,datname2,bool_time_cat,field1, field2,field3, field4, field5)
function ls=cat_datasets(datname1,datname2,bool_time_cat,field1, field2, field3, field4, field5)

%load first of all both datasets
ls1=loadspike_longcutouts_noc_bigfiles(datname1,2,25);
ls2=loadspike_longcutouts_noc_bigfiles(datname2,2,25);

%when I concatenate, and the datasets are from differnt recordings, with a stop of the rawsrv inbetween,
%I have to be aware that in each dataset, the time %starts from 0 again.
%Therefore, I have to modify the timestamps of the 2nd dataset
if bool_time_cat
    ls2.time=ls2.time+ls1.time(end);
end

%then search for the nr. of given fields to produce as output
nr_fields=nargin-3;

if nr_fields==5
 ls.(field1) = [ls1.(field1) ls2.(field1)]
 ls.(field2) = [ls1.(field2) ls2.(field2)]
 ls.(field3) = [ls1.(field3) ls2.(field3)]
 ls.(field4) = [ls1.(field4) ls2.(field4)]
 ls.(field5) = [ls1.(field5) ls2.(field5)]
 
elseif nr_fields==4
 ls.(field1) = [ls1.(field1) ls2.(field1)]
 ls.(field2) = [ls1.(field2) ls2.(field2)]
 ls.(field3) = [ls1.(field3) ls2.(field3)]
 ls.(field4) = [ls1.(field4) ls2.(field4)]
 
elseif nr_fields==3
 ls.(field1) = [ls1.(field1) ls2.(field1)]
 ls.(field2) = [ls1.(field2) ls2.(field2)]
 ls.(field3) = [ls1.(field3) ls2.(field3)]

elseif nr_fields==2
 ls.(field1) = [ls1.(field1) ls2.(field1)]
 ls.(field2) = [ls1.(field2) ls2.(field2)]  
else
 ls.(field1) = [ls1.(field1) ls2.(field1)]
end