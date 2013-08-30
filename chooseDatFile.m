function [datName,pathName] = chooseDatFile(varargin)
%Asks user to choose the data file and returns the filename.
%INPUTS: 'spont' -- looks only for spontaneous data files.
%        'stimResponse' -- looks only for stimulus response data files.
% to be completed later
% 30.08.2013 -- SSK

[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\Spontaneous';
end
[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);
end


