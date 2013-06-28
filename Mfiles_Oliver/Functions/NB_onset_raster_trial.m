%function NB_onset_raster_trial(datname,ls,NB_onset_times,Pre_time,Post_time)
% Basically a PURE copy of the StimulusEffect function, with the diffference that I trigger
% on the NB-onset times here. This gives the possibility to plot the spiking activity for each NB for each channel in the well-known fashion
% with the vertical allignment of the trials.
% a 8*8 plot, one for each electrode,
% 
% datname:              The file name
% 
% ls:                   The usual list with spike information
% 
%NB_onset_times         The onset times of the Network bursts
%
% 
%Pre_time, Post_time    extend of the raste rplot to the left and right of
%                       0
% 
function NB_onset_raster_trial(datname,ls,NB_onset_times,Pre_time,Post_time)


%timestamps of Triggers
zeitpunkte  = NB_onset_times
TRIALS      = length(zeitpunkte)
PRESTIMULI  = Pre_time; %i.e. 20*25 samples
POSTSTIMULI = Post_time;  %working is=n sec here
XDATAPRE    = -Pre_time
XDATAPOST   = Post_time


plotfig=figure;
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
    %relativetimes=relativetimes*samplestep*1000;  %in absolute values, relative to the stimulus, in ms
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
NB_first = ceil(zeitpunkte(1)/3600*100)/100;
NB_last  = ceil(zeitpunkte(end)/3600*100)/100;
htit=title({[datname];['Raster representation of the spiking activity after each Network burst'];...
    ['Total of ',num2str(TRIALS),' Network bursts in time period (hrs): ', num2str(NB_first), ' to ', num2str(NB_last)];...
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
selectedfig        = figure;

for i=1:channelcount;
    selectedhsub(i) = subplot(subplotsizecolumn, subplotsizerow,i);% a figure handle for every subplot
     for trial=1:TRIALS
         plot(stimulusraster(selectedchannels(i)+1,1:noofspikes(selectedchannels(i)+1,trial),trial),trial*ones(noofspikes(selectedchannels(i)+1,trial),1),'*k','MarkerSize',2);
         hold on;
     end;
    title(['channel ', num2str(hw2cr(selectedchannels(i)))], 'FontSize',14)
    xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
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
htit=title({[datname];['Raster representation of the spiking activity after each Network burst'];...
     ['Plot for channels ', num2str(selected_mea_input{ii}) ];...
     ['channel ',num2str(selected_mea_input{ii}(1))]},'Interpreter','none','Fontsize',14);


end
 
 