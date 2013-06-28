% a 8*8 plot, one for each electrode, to show responses to stimuli on each
% electrode
% %The trigger times can either be calculated by giving the trigger channel
% (ususlly 61) and the timeperiods of stimulation, OR with the optional
% argumemnt varargin, in a sepearate vector as pre-extracted stim times
% 
% 
% 
% function [stimulusraster noofspikes] = StimulusEffect(datname,ls,TRIG_CH_ANALOG,Trig_start,Trig_end,Pre_time,Post_time,varargin)
%
% input: 
% datname:              The file name
% 
% ls:                   The usual list with spike information
% 
% TRIG_CH_ANALOG:       analog channel (60-63), from which  the trigger times should be extracted 
% 
% Trig_start,Trig_end   time of the first and last trigger, in hrs
% 
%Pre_time, Post_time    extend of the raste rplot to the left and right of
%                       0, in seconds
%
%varargin:              If the stim_times can't be obtained from this file, I
%                       have the option to call this function with the
%                       argument varargin that can e.g. store those stim
%                       times
% 
% OUTPUT:
% stimulusraster:        stores the resposne spikes for each trial, for each channels
%     
% noofspikes             stores the nr of spikes in the PRE to POST-window.
%                        NOte that this is NOT the nr. of response spikes
%
function [stimulusraster noofspikes] = StimulusEffect(datname,ls,TRIG_CH_ANALOG,Trig_start,Trig_end,Pre_time,Post_time,varargin);


%%%If I give the varargin input, I define the stimulus times a priori, i.e.
%%%I have extracted those times already before calling this function
if ~isempty(varargin)
    zeitpunkte = varargin{1};
    Trig_start = zeitpunkte(1)/3600;
    Trig_end   = zeitpunkte(end)/3600;
else
%timestamps of stimuli
positionen = find(ls.channel==TRIG_CH_ANALOG & ls.time>=Trig_start*3600 & ls.time<=Trig_end*3600);
zeitpunkte = ls.time(positionen);
end

TRIALS     = length(zeitpunkte)

%samplestep=0.00004;
%UNITLENGTH=25; %i.e. 25 samples are one ms
PRESTIMULI  = Pre_time; %i.e. 20*25 samples
POSTSTIMULI = Post_time;  %working is=n sec here
XDATAPRE    = -Pre_time
XDATAPOST   = Post_time


plotfig=figure;
title('dataset: ');
stimulusraster=zeros(64,10,TRIALS); %here to store the info for the rasterplot

for channelnr=0:63
    channelnr
    chindex=find(ls.channel==channelnr);
    chtimestamps=ls.time(chindex);
    for i=1:TRIALS  %i.e for every trial
    prepostwindow=find((chtimestamps>(zeitpunkte(i)-PRESTIMULI)) & (chtimestamps<(zeitpunkte(i)+POSTSTIMULI)));
    chtimes=chtimestamps(prepostwindow);
    noofspikes(channelnr+1,i)=length(chtimes);
    relativetimes=chtimes-zeitpunkte(i);
    
    stimulusraster(channelnr+1,1:length(relativetimes),i)=relativetimes(1:end);
    end;


    [xposi,yposi]=hw2cr(channelnr);
    plotpos=xposi+8*(yposi-1);
    hsub(channelnr+1)=subplot(8,8,plotpos);
    for i=1:TRIALS
plot(stimulusraster(channelnr+1,1:noofspikes(channelnr+1,i),i),i*ones(noofspikes(channelnr+1,i),1),'*k','MarkerSize',2);
hold on;
    end;
    title([num2str(hw2cr(channelnr))],'FontSize',12)
%   
end;
hchil=get(plotfig,'Children');
set(hchil(:),'YLim',[0 TRIALS]); % manuell
set(hchil(:),'XLim',[-PRESTIMULI POSTSTIMULI]); % manuell
%set(hchil(:),'YTick',[90 270 450]);
%set(hchil(:),'YTickLabel',['day 1';'day 2';'day 3']);
%set(hchil(:),'XTick',[-3000 -2000 -1000 0 1000 2000 3000]);
%set(hchil(:),'XTickLabel',['-3';'-2';'-1'; '0 '; '1 ';'2 ';'3 ']);
set(hchil(:),'FontSize',8);
%set(plotfigure,title([datname])
hsub=subplot(8,8,1);
htit=title({[datname];['Stimuli in ',num2str(TRIALS),' trials, between hr ', num2str(Trig_start),' and ', num2str(Trig_end),' of recording'];...
            ['channel ',num2str(hw2cr(60)),' (',num2str(60),')']},'Interpreter','none');



        
 disp('Now give some Channels that should be plotted enlarged ');

nr_plots           = input('How many plots?')

selected_mea_input = cell(1,nr_plots);

for ii=1:nr_plots

selected_mea_input{ii} = input('Give channels (MEA-style, vector type) to show enlarged.\n ');
end

       
        
        
for ii=1:nr_plots
    
selectedchannels   = cr2hw(selected_mea_input{ii});  %select channels based on Hardware specifications
channelcount       = length(selectedchannels);
subplotsizecolumn  = ceil(channelcount);
subplotsizerow     = ceil(channelcount/subplotsizecolumn);
selectedfig        = screen_size_fig;

for i=1:channelcount;
    selectedhsub(i) = subplot(subplotsizecolumn, subplotsizerow,i);% a figure handle for every subplot
     for trial=1:TRIALS
         plot(stimulusraster(selectedchannels(i)+1,1:noofspikes(selectedchannels(i)+1,trial),trial),trial*ones(noofspikes(selectedchannels(i)+1,trial),1),'*k','MarkerSize',2);
         hold on;
     end;
    title(['electrode ', num2str(hw2cr(selectedchannels(i)))], 'FontSize',14)
    xlabel('post stimulus time [sec]', 'FontSize', 14);
    ylabel('trial no. ','FontSize',14);
end;
   selectedchil=get(selectedfig,'Children');
   set(selectedchil(:),'FontSize',16);
   set(selectedchil(:),'FontWeight','Normal');
set(selectedchil(:),'YLim',[0 TRIALS]); % manuell
set(selectedchil(:),'XLim',[XDATAPRE XDATAPOST]); 
%set(selectedchil(:),'YTick',[90 270 450]);
%set(selectedchil(:),'YTickLabel',['day 1';'day 2';'day 3']);
set(selectedchil(:),'FontSize',8);

hold on;
hsub=subplot(subplotsizecolumn,subplotsizerow,1);
htit=title({[datname];['Stimulation  for ',num2str(TRIALS),' trials, between hr ', num2str(Trig_start),' and ', num2str(Trig_end),' of recording'];...
     ['Plot for channels ', num2str(selected_mea_input{ii}) ];...
     ['channel ',num2str(selected_mea_input{ii}(1))]},'Interpreter','none','Fontsize',14);


end
 
 
 
 
 
    