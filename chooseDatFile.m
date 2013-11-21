function [datName,pathName] = chooseDatFile(varargin)
%Asks user to choose the data file and returns the filename.
%INPUTS:
%varargin{1} -- has to be the experiment number
%varargin{1} -- has to be atleast the first two lettes(case insensitive) of the following dirs
%'Spontaneous' -- looks only for spontaneous data files.
%'StimRecSite' -- looks only for stimulus response data files.
%'ClosedLoop' -- looks only for stimulus response data files.
%'NetControl' -- NetControl Experiments
% OUTPUTS:
% datName -- filename
% pathName -- complete path to the above file
% 30.08.2013 -- SSK

exp_dir = '';
data_dir = '';

switch nargin
    case 1
        exp_dir = ['Experiments',num2str(varargin{1})];
    case 2
        exp_dir = ['Experiments',num2str(varargin{1})];
        if strncmpi(varargin{2},'spontaneous',2)
            data_dir = 'Spontaneous';
        elseif strncmpi(varargin{2},'stimulation',2)
            data_dir = 'StimRecSite';
        elseif strncmpi(varargin{2},'closed',2)
            data_dir = 'ClosedLoop';
        elseif strncmpi(varargin{2},'netcontrol',2)
            data_dir = 'NetControl';
        end
end

[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = ['C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\',exp_dir,'\',data_dir];
end
[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);
end


