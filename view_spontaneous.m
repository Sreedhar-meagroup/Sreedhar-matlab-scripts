[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments2\StimRecSite\StimPolicy2';
end

[datName,pathName]=uigetfile('*.spike','Select MEABench Data file',srcPath);
datRoot = datName(1:strfind(datName,'.')-1);
spikes = loadspike([pathName,datName],2,25);

inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end

%% Fig 1a: global firing rate
% sliding window; bin width = 1s
[counts,timeVec] = hist(spks.time,0:ceil(max(spks.time)));
figure(1); fig1ha(1) = subplot(3,1,1); bar(timeVec,counts);
axis tight; ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Fig 1b: General raster
gfr_rstr_h = figure(1); 
handles(1) = gfr_rstr_h;
fig1ha(2) = subplot(3,1,2:3);
linkaxes(fig1ha, 'x');
hold on;
rasterplot2(spks.time,spks.channel,'b-')
% for ii = 1:60 
%     plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.');
%     %axis tight;
% end
hold off;
set(gca,'TickDir','Out');
xlabel('Time (s)');
ylabel('Channel #');
title('Raster plot of spontaneous activity');
zoom xon;
