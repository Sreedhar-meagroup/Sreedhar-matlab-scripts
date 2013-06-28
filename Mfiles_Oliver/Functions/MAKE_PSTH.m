%%file MAKE-PSTH
% 
% 
% %This function should be as universal as possible.
% % As an input, only the trigger information is required (i.e the allignment
% % time of the PSTH) and the channel nrs for which the PSTHs should be
% % generated, and of course the structure ls
% 
% 
% 
%function ch_psth =MAKE_PSTH(ls,channel_vec,Trigger_times,PSTH_BIN_WIDTH,PRE_TRIG_TIME,POST_TRIG_TIME,bool_plot)
% %%input:
% %ls                     The usual structure that holds the spiek
% %                       information
% 
% %channel_vec:           vector of MEA channel Nrs, MAXIMALLY 3!
% 
% %trig_times;            vector of allignment times in the PSTH
% 
% 
%BIN_WIDTH                Bin width of the PSTH in sec
%
%PRE_TRIG_TIME             Time pre and post of the trigger in sec 
%POST_TRIG_TIME    
%
%
% %bool_plot (optional)   give a 0 here if no plot is desired
% 
% 
% 
% %output:
% %ch_psth:               the vector that stores the values for plotting the
% %                       PSTH, in the rows are the channels, in the columns are the bin values
% 
% %generates a figure with the individual PSTHs
% 
% 

function ch_psth = MAKE_PSTH(ls,channel_vec,Trigger_times,PSTH_BIN_WIDTH,PRE_TRIG_TIME,POST_TRIG_TIME,bool_plot)



%just check if a plot is desired or not, for nargin ==3 (i.e no input
%there wil be a plot
if nargin == 6
    bool_plot = 1;
end

  


% PRE_TRIG_TIME       = 1;
% POST_TRIG_TIME      = 3;
% 
% PSTH_BIN_WIDTH      = 0.005;

TRIAL_TIME_VEC      = -PRE_TRIG_TIME:PSTH_BIN_WIDTH:POST_TRIG_TIME-PSTH_BIN_WIDTH;

hw_ch          = cr2hw(channel_vec);
nr_ch          = length(channel_vec);
nr_subplot_row = ceil(sqrt(nr_ch));     
nr_subplot_col = ceil(nr_ch/nr_subplot_row);



if (~iscell(Trigger_times))
    for ii=1:nr_ch
        trig_times{ii} = Trigger_times;
    end
     time_start     = Trigger_times(1);
     time_end       = Trigger_times(end);
else
    for ii=1:nr_ch
        trig_times{ii} = Trigger_times{ii};
    end
    time_start     = Trigger_times{1}(1);
    time_end       = Trigger_times{1}(end);
end


ch_psth = zeros(nr_ch,(PRE_TRIG_TIME+POST_TRIG_TIME)/PSTH_BIN_WIDTH);

if (bool_plot)
    psth_fig = figure;
end

for ii=1:nr_ch
    
    
    if (bool_plot)
        subplot(nr_subplot_row,nr_subplot_col,ii);
        %ch_fig(ii)=figure;
    end
    
    nr_trig = length(trig_times{ii});
    for jj=1:nr_trig
        
         if ~rem(jj,100)
        %just displaying each 100th cycle
             jj
         end
         
        ch_spikes     = ls.time(find(ls.channel==hw_ch(ii) & ls.time>trig_times{ii}(jj)-PRE_TRIG_TIME & ls.time<trig_times{ii}(jj)+POST_TRIG_TIME));
        rel_ch_times  = ch_spikes-trig_times{ii}(jj);
        
        if(~isempty(rel_ch_times))
            
         if PSTH_BIN_WIDTH      == 0.01
             ch_hist       = hist(rel_ch_times,TRIAL_TIME_VEC);
             ch_psth(ii,:) = ch_psth(ii,:) + ch_hist;
             
         elseif PSTH_BIN_WIDTH  == 0.005
             ch_hist       = histc(rel_ch_times,TRIAL_TIME_VEC);
             ch_psth(ii,:) = ch_psth(ii,:) + ch_hist;
         else
             %disp(' What is the Bin width? Take care of not binning the blanking period!' );
             %return;
             ch_hist       = histc(rel_ch_times,TRIAL_TIME_VEC);
             ch_psth(ii,:) = ch_psth(ii,:) + ch_hist;
         end
         
        end
    end
    
   
    if(bool_plot)
        plot(TRIAL_TIME_VEC,ch_psth(ii,:)/(PSTH_BIN_WIDTH*nr_trig));
        xlabel(' time r.t. trigger [sec]');
        ylabel('rate in trial [Hz]');
        title({['PSTH, all trials alligned on the same trigger condition'];...
            ['during hr. ',num2str(floor(time_start/360)/10),' to ', num2str(ceil(time_end/360)/10),' of recording'];...
            ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: ', num2str(channel_vec(ii))]});
        xlim([-PRE_TRIG_TIME POST_TRIG_TIME]);
    end
end

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        





