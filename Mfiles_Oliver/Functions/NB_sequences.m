%A function that, based on the Network burst detection, calculates
%distributions of onset delays in network bursts for electrodes and plots
% (averaged) temporal sequences of network bursts. I.e. the ' average' case
% of a network burst
%
%
%
% input:
%
%datname:                                 name of the file
%
%
%
% network_burst:                           The cell array with information
%                                          about network bursts, as obtained from 
%                                          Networkburst detection
%                                          I DO STORE CHANNELS AS
%                                          HW-CHANNELS+1!!!
% 
% 
% 
% 
% start_NB                                start of the first NB, in hrs,
%                                         which is considered for analysis
% 
% 
% end_NB                                  end of the last NB which is
%                                         considered for analysis
% 
% 
% CHANNELS                                 The channels for which tha
%                                         analysis should be done
% 
% varargin                                can be a plot_handle to plot the
%                                         plot with the Nr of NB starts on a separate figure
% Output:
% Delay_hist_fig = Returns a handle to the plotted figure
% 
% nr_starts:                                Vector that stores the result of the calculation of NB starts
% 
% 
% EL_return                                 EL_return, according vactor with MEA electrodes


function [Delay_hist_fig nr_starts EL_return] =NB_sequences(datname,network_burst_all, start_NB,end_NB,CHANNELS, varargin);


if ~isempty(varargin)
    plot_handle = varargin{1}
end

%make the preselection of NB, according to start_NB and end_NB

nr_NB          = size(network_burst_all,1);
ind_ct         = 0;
network_burst  = cell(1,5);
for jj=1:nr_NB
    NB_onset_all(jj) = network_burst_all{jj,2}(1);
    
    
    if NB_onset_all(jj) > start_NB*3600 & NB_onset_all< end_NB*3600
        ind_ct=ind_ct+1;
        for kk=1:size(network_burst_all,2)
            network_burst{ind_ct,kk} = network_burst_all{jj,kk};
        end  
    end
    
    
end
%%%%end of making the preselection, going on with the cell array
%%%%network_burst




nr_NB = size(network_burst,1);


%find first of all a set of the mostly participating channels
EL_set  = [];
for ii=1:nr_NB;
    EL_set = cat(1,EL_set,network_burst{ii,1});
end
    
el_group     = hist(EL_set,0:59);
active_EL    = find(el_group > nr_NB/4)-2 ;  %because  I initially store hw-channel_nr+1 and have here again  an index that again runs from 0 to 59, I need to substartct to to get to hw-channel_nr


active_EL = cr2hw(CHANNELS)
%sort the active electrodes according to MEA nr
active_EL_MEA            = hw2cr(active_EL);
[active_EL_MEA sort_ind] = sort(active_EL_MEA);
active_EL                = active_EL(sort_ind);

nr_active_EL = length(active_EL); 
%active_EL stores the hardware channel nrs which have the most bursts. 


NB_onset_delay = cell(nr_active_EL,nr_NB);





for jj=1:nr_NB
    %check if the current NB has at least a minimum set of all the bursting
    %electrodes
    %Or additionally, take just ALL NBs
    %if length(setdiff(active_EL+1,network_burst{jj,1})) < nr_active_EL/2
        
        %I have to resort the indics, according to the initial appearance
        %in network_burst{jj,1}
        [EL_tp ind_EL ind_NB] = intersect(active_EL+1, network_burst{jj,1});
        [tp ind_sort]         = sort(ind_NB);
        ind_EL                = ind_EL(ind_sort);
        
        
        %the first electrode has always delay 0
        NB_onset                     = network_burst{jj,2}(1);
        NB_onset_delay{ind_EL(1),jj} = 0;
        
        
        for kk=2:length(ind_EL)
            NB_onset_delay{ind_EL(kk),jj} = network_burst{jj,2}(kk) - NB_onset;
        end
    %end
end



Delay_hist_fig=screen_size_fig;

nr_subplot_col = 3
if (rem(nr_active_EL,nr_subplot_col))
    subplot_row = ceil(nr_active_EL/nr_subplot_col)+1;
    
else
    subplot_row = ceil(nr_active_EL/nr_subplot_col)+1;
end
    

for ii=1:nr_active_EL
     h_sub(ii) = subplot(subplot_row,nr_subplot_col,ii);
     
     all_delays       = [NB_onset_delay{ii,:}];
     nr_ch_NB(ii)     = length(all_delays);
     %exclude the 0 from the following calculation
     median_delay     = median(all_delays(find(all_delays>0)));
     mean_delay(ii)       = mean(all_delays(find(all_delays>0 & all_delays<0.05)));
     MEA_CH(ii)         =  hw2cr(active_EL(ii));
     std_delay        = std(all_delays(find(all_delays>0)));
     nr_starts(ii)    = length(find(all_delays==0));
     
     
     
     %define the bin centers for the histogram, do it like that to get the
     %0-bin in as a standalone
     bin_centers = -0.0005:0.001:0.3;
     hist_NB_delay=hist([NB_onset_delay{ii,:}], bin_centers);
     bar(bin_centers,hist_NB_delay)
     max_y_val(ii) = max(hist_NB_delay(2:end));
     xlim([0 0.1]);
     title([' channel: ', num2str(hw2cr(active_EL(ii))),', participating in ', num2str(nr_ch_NB(ii)),' NBs']);
     xlabel('onset delay [sec]');
     ylabel('counts');
     %text(0.05,max(max_y_val)*0.8,{[num2str(nr_starts(ii)),' NB starts'];['mean:    ', num2str(round(mean_delay*10000)/10),' msec'];['median: ',num2str(round(median_delay*10000)/10),' msec'];['std:       ',num2str(round(std_delay*10000)/10),' msec']})
     text(0.05,max(max_y_val)*0.8,{[num2str(nr_starts(ii)),' NB starts']});
     
end
    ylims    = get(h_sub,'ylim');
    max_ylim = max([ylims{:}]);
    %set(h_sub,'ylim', [0 max_ylim]);
    set(h_sub,'ylim', [0 max(max_y_val)*1.2]);
    
    if exist('plot_handle')
        axes(plot_handle)
    else
        h_sub(ii+1) = subplot(subplot_row,nr_subplot_col,[nr_subplot_col*subplot_row-(nr_subplot_col-1) nr_subplot_col*subplot_row-1]);
    end
    
    [sorted_nrs sort_ind] =  sort(nr_starts,'descend');
    EL_array=1:nr_active_EL;
    
    bar(EL_array,nr_starts(sort_ind));
    if exist('plot_handle')
        set(gca,'XTick',1:length(sort_ind),'xtickLabel',num2str(hw2cr(active_EL(EL_array((sort_ind))))'));
    else
        set(h_sub(end),'XTick',1:length(sort_ind),'xtickLabel',num2str(hw2cr(active_EL(EL_array((sort_ind))))'));
    end
    xlabel(' electrode' )
    ylabel(' Nr. of NB starts' );
    title([' channels starting a NB, total of ', num2str(nr_NB),' NBs detected during considered period'])
    
    if exist('plot_handle')
        title({[' datname: ', num2str(datname),', hr ', num2str(start_NB),' to ', num2str(end_NB),' of recording' ];...
         [' channel: ', num2str(hw2cr(active_EL(1))),', participating in ', num2str(nr_ch_NB(1)),' NBs']},'Interpreter', 'none');
     close(Delay_hist_fig)
    else
        subplot(subplot_row,nr_subplot_col,1)
        title({[' datname: ', num2str(datname),', hr ', num2str(start_NB),' to ', num2str(end_NB),' of recording' ];...
         [' channel: ', num2str(hw2cr(active_EL(1))),', participating in ', num2str(nr_ch_NB(1)),' NBs']},'Interpreter', 'none');
    
    end
   
    
  %Define the Electrode vector that goes with the nr_starts vector, for
  %return values
  EL_return = hw2cr(active_EL);
    
    
    
    
    
    
    
    
    
    
    
    
    






