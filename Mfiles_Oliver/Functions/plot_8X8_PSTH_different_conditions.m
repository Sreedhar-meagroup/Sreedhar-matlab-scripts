%function plot_8x8_PSTH_different_condition
% 
%If 8x8 PSTHs are calcualted on the server, here ist the function that
%plots it. Furthermore, If I want to plot several conditions for each
%electrode (e.g. different stimulaion site), I can do this when I ask at
%the beginning how many cnditions there are and then run the loop for each conditio.
%Of course, the input vectors have to be
%modified in order to match the nr of desired conditions to plot.
% 
% 
% 
%
% INPUT:
% datname:            the name of the dataset
% 
%ch_psth              The cell array which stores the PSTHs for each
%                     channel (columns) and each conditon (rows). The function MAKE_PSTH_8X8
%                      only returns a (1,60)-cell array (i.e. for one condition. So here, I have
%                     to construct my cell array at the beginning, i.e. concatenating the
%                     different rows
% 
% 
% nr_triggers         The nr of stimuli over which the PSTH was averaged in
%                     each condition, This is a vector with a length according to the nr of 
%                     conditions 
% 
% PRE_TRIG_TIME       The extend of the PSTh pre and post stimulus, in sec.
%                     should be the same for each condition
% POST_TRIG_TIME
% 
%PSTH_BIN_WIDTH       the bin width of the PSTH, should also be the same
%                     for each condition
%
% 
%
%OUTPUT
%
%hsub                 A handle vector, with one entry for each subplot of
%t                    he 8X8 plot
%
%
% hsub =  plot_8X8_PSTH(datname,ch_psth,nr_triggers,PRE_TRIG_TIME,POST_TRIG_TIME,PSTH_BIN_WIDTH)
% 
% 
function hsub = plot_8X8_PSTH_different_conditions(datname,ch_psth,nr_triggers,PRE_TRIG_TIME,POST_TRIG_TIME,PSTH_BIN_WIDTH)

nr_ch               = 64;
TRIAL_TIME_VEC      = -PRE_TRIG_TIME:PSTH_BIN_WIDTH:POST_TRIG_TIME-PSTH_BIN_WIDTH;


disp('How many different plots (conditions) per channel?' );
Nr_conditions = input('Give Nr. of different conditions ');


%There are some bins that should be removed due to artifacts etc. Which
    %%bins and how many depends on the PSTH_BIN_width etc...
    remove_length   = 6;  %How many MSEC after 0 should the bins be emptied
    NR_bins_removed = ceil(remove_length/1000/PSTH_BIN_WIDTH);

    %the first bin in a histogram generated with histc that comes after 0 (i.e.including all the values >=0 and <0+bin_width )is
    first_remove_bin = PRE_TRIG_TIME/PSTH_BIN_WIDTH+1;

%Making the Bins after 0 Nan for all conditions
for mm = 1:Nr_conditions
    
    for ii=1:60  %only for the recording electrodes
        ch_psth{mm,ii}(first_remove_bin:first_remove_bin+NR_bins_removed-1)=NaN;
    end

end



%ALSO APPLY THE NORMALIZATION HERE;

for mm=1:Nr_conditions
    for ii =1:nr_ch
    ch_psth{mm,ii} = ch_psth{mm,ii}/(nr_triggers(mm)*PSTH_BIN_WIDTH);
    end
end


%DEFINE the string for the legend
legend_string = cell(Nr_conditions,1);

disp('Define a legend string (OTHERWISE press enter): ');
for ii =1:Nr_conditions
    disp(['Legend ', num2str(ii)])
legend_string{ii} = input( 'Legend string input: ' , 's'); 

%if enter is pressed (i.e no defined legend)
    if isempty(legend_string{1})
        for ii = 1 :Nr_conditions
    legend_string{ii} = ['period ', num2str(ii)];
        end
        break
    end
end

PSTH_8x8_fig = screen_size_fig;
color_spec = get(gca,'Colororder');
rate_limits  = [16 32 64 128 256 512 1024 2048];  


        for ii=1:nr_ch
            %find the rigt position
            [xposi,yposi]=hw2cr(ii-1);

            plotpos            = xposi+8*(yposi-1);
            hsub(ii)           = subplot(8,8,plotpos);
            plot_handle(:,ii) = plot(TRIAL_TIME_VEC,cell2mat(ch_psth(:,ii)));
            %for later plotting, have a hold on here
            xlim([-PRE_TRIG_TIME POST_TRIG_TIME]);
            ylimits      = get(gca,'Ylim');
            max_ylim(ii) = ylimits(2);
            %determine the "activity"of the current electrode, for later color
            %coding
            firing_range_diff = rate_limits - max_ylim(ii);
            firing_range_ind  = find(firing_range_diff>0);
            %take the first positive value
            firing_range_ind  = firing_range_ind(1);
            color_limit_ch(ii)= firing_range_ind;
            rate_limit_ch(ii) = rate_limits(firing_range_ind);
            set(plot_handle(ii),'color',color_spec(firing_range_ind,:));
            set(hsub(ii),'Ylim',[0 rate_limit_ch(ii)]);
            title(['channel: ', num2str(hw2cr(ii-1))]);
        end
        
    %end % end of the if loop
    
%end%end of the loop over the different condition


 %set(hsub(1:59),'Ylim',[0 max(max_ylim(1:59))])
 subplot(8,8,1)
 xlabel(' time r.t. trigger [sec]');
 ylabel('rate in trial [Hz]');
 title({['datname ',num2str(datname)];[' PSTH, averaged over ', num2str(nr_triggers),' trials'];...
        ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: 61']},'Interpreter', 'none');
  
    
    
    
disp('Now give some Channels that should be plotted enlarged \n');

nr_plots           = input('How many plots?')

selected_mea_input = cell(1,nr_plots);

for ii=1:nr_plots
selected_mea_input{ii} = input('Give channels (MEA-style, vector type) to show enlarged.\n ');
end



    for jj = 1:nr_plots
        Sel_ch_PSTH_fig = screen_size_fig;
        ch_input_hw     = cr2hw(selected_mea_input{jj})

  
            for kk = 1:length(ch_input_hw)
              subplot(length(ch_input_hw),1,kk)
              active_hw_ch = ch_input_hw(kk)+1;
              %plot(TRIAL_TIME_VEC,cell2mat(ch_psth(:,active_hw_ch)),'Color',color_spec(color_limit_ch(active_hw_ch),:));
              plot(TRIAL_TIME_VEC,cell2mat(ch_psth(:,active_hw_ch)));
              xlim([-PRE_TRIG_TIME POST_TRIG_TIME]);
              %ylim([0 rate_limit_ch(active_hw_ch)]);
              xlabel(' time r.t. stimulus [sec]');
              ylabel('rate in trial [Hz]');
              title(['channel: ',num2str(selected_mea_input{jj}(kk))]);
              legend(legend_string)
              xlim([-PRE_TRIG_TIME POST_TRIG_TIME])
            end

  
            subplot(length(ch_input_hw),1,1)
             title({['datname: ', num2str(datname)];['PSTH, averaged over ', num2str(nr_triggers),' trials'];...
                ['bin width: ', num2str(PSTH_BIN_WIDTH*1000),' msec, channel: ',num2str(selected_mea_input{jj}(1))]},'Interpreter', 'none');
    end
        
        
        
    
    
    
    