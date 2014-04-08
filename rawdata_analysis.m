%% Analyzing raw data dents in MEABench - I

% data = loadraw('140311_4513_raw.raw',2);
% ch = 25; % hw+1
% % slicing by window width
% window1e3 = data(ch,1:10*25e3) - 683;
% window500 = data(ch,15*25e3:25*25e3) - 683;
% window200 = data(ch,30*25e3:40*25e3) - 683;
% figure();
% figha(1) = subplot(311);
% title('1000 ms window'); hold on;
% plot(linspace(1,10,length(window1e3)),window1e3);
% box off;
% figha(2) = subplot(312);
% title('500 ms window'); hold on;
% plot(linspace(1,10,length(window500)),window500);
% box off;
% figha(3) = subplot(313);
% title('250 ms window'); hold on;
% plot(linspace(1,10,length(window200)),window200);
% box off;
% linkaxes(figha,'x');
% zoom xon;
% pan xon;
% suplabel('time [s]')
% suplabel('Voltage [\mu V]','y');

%% Analyzing raw data dents in MEABench - II
[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data\NetControl\Experiments5\misc\';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments5\misc\';
end
[datName,pathName]=uigetfile('*.raw','Select MEABench Data file',srcPath);
data = cell(4,1);
for ii = 1:4
    datRoot = datName(1:strfind(datName,'.')-1);
    data{ii} = loadraw([pathName,datRoot(1:end-1),num2str(ii),'.raw'],2);
end
%% changing channel data
ch = input('Enter a channel no (0-59): ');
windowNone = data{1}(ch,5*25e3:15*25e3)- 683;
window1e3 = data{2}(ch,5*25e3:15*25e3) - 683;
window500 = data{3}(ch,5*25e3:15*25e3) - 683;
window250 = data{4}(ch,5*25e3:15*25e3) - 683;

%% plotting part
figure();
figha(1) = subplot(411);
title(['channel:',num2str(ch),',   No scope'],'FontSize',16); hold on;
plot(linspace(0,10,length(windowNone)),windowNone);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(2) = subplot(412);
title('1000 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window1e3)),window1e3);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(3) = subplot(413);
title('500 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window500)),window500);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(4) = subplot(414);
title('250 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window250)),window250);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

linkaxes(figha,'x');
zoom xon;
pan xon;
[~,h4] = suplabel('time [s]');
[~,h5] = suplabel('Voltage [\muV]','y');
set(h4,'FontSize',16);
set(h5,'FontSize',16);


%% saving the figure in landscape
% h=gcf;
% set(h,'PaperPositionMode','auto'); 
% set(h,'PaperOrientation','landscape');
% set(h,'Position',[50 50 1200 800]);
% if strcmpi(strtrim(name),'sree-pc')
%     print(gcf, '-depsc', ['C:\Users\Sree\Desktop\jf_140318\rawData','_ch',num2str(ch),'.eps']);
% elseif strcmpi(strtrim(name),'petunia')
%     print(gcf, '-depsc', ['C:\Users\duarte\Desktop\jf_140318\rawData','_ch',num2str(ch),'.eps']);
% end

%% filtering and plotting

deltaT = 1000; % no: of initial indices to skip

window1e3_trials = reshape(window1e3(1,1:end-1),25e3,[]);
window500_trials = reshape(window500(1,1:end-1),25e3/2,[]);
window250_trials = reshape(window250(1,1:end-1),25e3/4,[]);

window1e3_mean = mean(window1e3_trials,2);
window500_mean = mean(window500_trials,2);
window250_mean = mean(window250_trials,2);
a = 1; b = 1/500*ones(1,500);
y1e3 = filter(b,a,window1e3_mean);
a = 1; b = 1/250*ones(1,250);
y500 = filter(b,a,window500_mean);
a = 1; b = 1/100*ones(1,100);
y250 = filter(b,a,window250_mean);

time1e3 = linspace(0,1000,length(y1e3));
time500 = linspace(0,500,length(y500));
time250 = linspace(0,250,length(y250));

[~,maxind1e3] = max(y1e3(deltaT:end));
maxind1e3 = maxind1e3 + deltaT;
[~,maxind500] = max(y500(deltaT:end));
maxind500 = maxind500 + deltaT;
[~,maxind250] = max(y250(deltaT:end));
maxind250 = maxind250 + deltaT;

figure();
hold on;
plot(time1e3,window1e3_trials,'g');
plot(time1e3,window1e3_mean);
plot(time1e3,y1e3,'r','LineWidth',2);
line([maxind1e3/25,maxind1e3/25],[-20,10],'Color','k');
title('1000 ms window','FontSize',14);
xlabel('time [ms]','FontSize',14);
ylabel('Voltage [\muV]','FontSize',14);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;



figure();
hold on;
plot(time500,window500_trials,'g');
plot(time500,window500_mean);
plot(time500,y500,'r','LineWidth',2);
line([maxind500/25,maxind500/25],[-20,10],'Color','k');
title('500 ms window','FontSize',14);
xlabel('time [ms]','FontSize',14);
ylabel('Voltage [\muV]','FontSize',14);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;
axis tight;

figure();
hold on;
plot(time250,window250_trials,'g');
plot(time250,window250_mean);
plot(time250,y250,'r','LineWidth',2);
line([maxind250/25,maxind250/25],[-20,10],'Color','k');
title('250 ms window','FontSize',14);
xlabel('time [ms]','FontSize',14);
ylabel('Voltage [\muV]','FontSize',14);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;
axis tight;

%%
% [~, name] = system('hostname');
% if strcmpi(strtrim(name),'sree-pc')
%     srcPath = 'D:\Codes\mat_work\MB_data\NetControl\Experiments5\misc\';
% elseif strcmpi(strtrim(name),'petunia')
%     srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments6\misc\';
% end
% [datName,pathName]=uigetfile('*.raw','Select MEABench Data file',srcPath);
% data = loadraw([pathName,datName],2);
% data1 = data - 683;
% ch = 26;
% figure;
% h(1) = subplot(3,1,1);
% time = 25*25e3:30*25e3;
% plot(time/25e3,data1(ch,time));
% axis tight
% box off;
% set(gca,'XGrid','On')
% 
% h(2) = subplot(3,1,2);
% time = 38*25e3:43*25e3;
% plot(time/25e3,data1(ch,time));
% axis tight
% box off;
% set(gca,'XGrid','On')
% 
% h(3) = subplot(3,1,3);
% time = 85*25e3:90*25e3;
% plot(time/25e3,data1(ch,time));
% axis tight
% box off;
% set(gca,'XGrid','On')
% 
% suplabel('Time [s]');
% suplabel('Voltage [\muV]','y');
