% A modification of the orifginal StimulusEffect function, becuase this
% needs due to some wack kcoding too much space cbecause of latge matrices.
% An elegant solution is to use sparse matrices. However, this of course
% would make older useage of the stim_raster arrray unusabel, so I use it
% here as a new file which will then later be used more frequenbtly, once
% the code is established
% 
% 
%function [StimRaster_Sparse Nr_spikes] = StimulusEffect_SPARSE(datname,ls,Pre_time,Post_time,stim_times,PLOT_OUTPUT);
%
% 
% input: 
% datname:              The file name
% 
% ls:                   The usual list with spike information
% 
% 
%Pre_time, Post_time    extend of the raste rplot to the left and right of
%                       0, in seconds
%
%stim_times             Stimulation times
%
%
%
%PLOT_OUTPUT            1 if result should be plotted, o 0therwise, only
%                       return values givem


% 
% OUTPUT:
% StimRaster_Sparse        A cell array, one cell for each chanmel. Each cell contains a sparse matrix
%                            The sparse matrix can be accessed with the normnal notation. E.g.
%                            StimRaster_Sparse{ii}(jj,kk) 
%                            is the jjth spike in the kkth trial for channel ii. H
%     
% Nr_spikes             stores the nr of spikes in the PRE to POST-window.
%                        NOte that this is NOT the nr. of response spikes
%
function [StimRaster_Sparse Nr_spikes] = StimulusEffect_SPARSE(datname,ls,Pre_time,Post_time,stim_times,PLOT_OUTPUT);


TRIALS     = length(stim_times)

PRESTIMULI  = Pre_time; %i.e. 20*25 samples
POSTSTIMULI = Post_time;  %working is=n sec here
XDATAPRE    = -Pre_time
XDATAPOST   = Post_time



StimRaster_Sparse = cell(1,64); %here to store the info for the rasterplot

for channelnr=0:63
    channelnr
    chindex      = find(ls.channel==channelnr);
    chtimestamps = ls.time(chindex);
    for jj=1:TRIALS  %i.e for every trial
    prepostwindow              = find((chtimestamps>(stim_times(jj)-PRESTIMULI)) & (chtimestamps<(stim_times(jj)+POSTSTIMULI)));
    chtimes                    = chtimestamps(prepostwindow);
    Nr_spikes(channelnr+1,jj)  = length(chtimes);
    relativetimes              = chtimes-stim_times(jj);
    
    %store sthe Stimraster
    StimRaster_temp(1:length(relativetimes),jj) = relativetimes(1:end);
    %StimRaster_temp{jj} = relativetimes;
    end;
    
    
    if channelnr>=60 & ~isempty(StimRaster_temp)
        
        %trig_pos                    =  cellfun(@(x) find(x==0),StimRaster_temp);
        for jj=1:TRIALS
            trig_pos = find(StimRaster_temp(:,jj)==0);
            if ~isempty(trig_pos)
                %find the pos. where the analog channels actually do have a
                %trigger
                trig_pos = trig_pos(1);
                trig_trial = jj;
                 %add one sampel step so that it gets stored in the sparse
                 %matrix
                StimRaster_temp(trig_pos,trig_trial) = StimRaster_temp(trig_pos,trig_trial)+1/25000;
            end
        end
        %trig_trial                  =  find(cellfun(@(x)
        %~isempty(x),StimRaster_temp));
        
    end
    %this converts to a sparse matrix
    StimRaster_Sparse{1,channelnr+1} = sparse(StimRaster_temp);
    
   
    %before going to the next channel, clear the StimRaster_temp
    clear StimRaster_temp
    
    
    
   
end;


if ~PLOT_OUTPUT
    return
end
%otherwise just continue


%Plot the result
    plotfig=figure;
    title('dataset: ');
    for channelnr = 0:63
        
    [xposi,yposi]=hw2cr(channelnr);
    plotpos=xposi+8*(yposi-1);
    hsub(channelnr+1)=subplot(8,8,plotpos);
%     
        for jj=1:TRIALS
            %reconvert to to full representation, only for plotting
            %purposes
            spikes_full = full(StimRaster_Sparse{channelnr+1}(:,jj));
            %plotted are of course only he corresp. entries nonzero
            if find(spikes_full)
                %plot(spikes_full(find(spikes_full)),jj*ones(1,Nr_spikes(channelnr+1,jj)),'*k','MarkerSize',2);
                plot(spikes_full(find(spikes_full)),jj*ones(1,length(find(spikes_full))),'ok','MarkerSize',2,'Markerfacecolor','k','Markeredgecolor','k');
                hold on;
            end
            %if there are no spikes in this trial, just don't plot
                
            
        end;
    title([num2str(hw2cr(channelnr))],'FontSize',12)
    end
    
hchil=get(plotfig,'Children');
set(hchil(:),'YLim',[0 TRIALS]); % manuell
set(hchil(:),'XLim',[-PRESTIMULI POSTSTIMULI]); % manuell
set(hchil(:),'FontSize',8);

hsub=subplot(8,8,1);
htit=title({[datname];['Stimuli in ',num2str(TRIALS),' trials, between hr ', num2str(stim_times(1)/3600),' and ', num2str(stim_times(end)/3600),' of recording'];...
            ['channel ',num2str(hw2cr(60)),' (',num2str(60),')']},'Interpreter','none');


% 
%         
% disp('Now give some Channels that should be plotted enlarged ');
% 
% nr_plots           = input('How many plots?')
% 
% selected_mea_input = cell(1,nr_plots);
% 
% for ii=1:nr_plots
% 
% selected_mea_input{ii} = input('Give channels (MEA-style, vector type) to show enlarged.\n ');
% end
% 
%        
%         
%         
% for ii=1:nr_plots
% 
%     selectedchannels   = cr2hw(selected_mea_input{ii});  %select channels based on Hardware specifications
%     channelcount       = length(selectedchannels);
%     subplotsizecolumn  = ceil(channelcount);
%     subplotsizerow     = ceil(channelcount/subplotsizecolumn);
%     selectedfig        = screen_size_fig;
% 
%     for i=1:channelcount;
%         selectedhsub(i) = subplot(subplotsizecolumn, subplotsizerow,i);% a figure handle for every subplot
%         active_ch       = selectedchannels(i);
%         for jj=1:TRIALS
%             %reconvert to to full representation, only for plotting
%             %purposes
%             spikes_full = full(StimRaster_Sparse{active_ch+1}(:,jj));
% 
%             %plotted are of course only he corresp. entries nonzero
%             if find(spikes_full)
%                 plot(spikes_full(find(spikes_full)),jj*ones(1,length(find(spikes_full))),'ok','MarkerSize',2,'Markerfacecolor','k','Markeredgecolor','k');
%             end
%             %if there are no spikes in this trial, just don't plot
% 
%             hold on;
%         end;
%         title(['electrode ', num2str(hw2cr(selectedchannels(i)))], 'FontSize',14)
%         xlabel('post stimulus time [sec]', 'FontSize', 14);
%         ylabel('trial no. ','FontSize',14);
%     end;
%     selectedchil=get(selectedfig,'Children');
%     set(selectedchil(:),'FontSize',16);
%     set(selectedchil(:),'FontWeight','Normal');
%     set(selectedchil(:),'YLim',[0 TRIALS]); % manuell
%     set(selectedchil(:),'XLim',[XDATAPRE XDATAPOST]);
%     %set(selectedchil(:),'YTick',[90 270 450]);
%     %set(selectedchil(:),'YTickLabel',['day 1';'day 2';'day 3']);
%     set(selectedchil(:),'FontSize',8);
% 
%     hold on;
%     hsub=subplot(subplotsizecolumn,subplotsizerow,1);
%     htit=title({[datname];['Stimulation  for ',num2str(TRIALS),' trials, between hr ', num2str(stim_times(1)/3600),' and ', num2str(stim_times(end)/3600),' of recording'];...
%         ['Plot for channels ', num2str(selected_mea_input{ii}) ];...
%         ['channel ',num2str(selected_mea_input{ii}(1))]},'Interpreter','none','Fontsize',14);
% 
% 
% end
% 

 
 
 
    