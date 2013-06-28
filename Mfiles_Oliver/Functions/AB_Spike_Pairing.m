% %
% Check the influence of single spikes from one electrode on the spiking on
% another electrode. Check if a spike one electrode A is followed by a
% spike on electrode B in the interval before A spikes again. If so, the
% spike on A entailed B to spike, if not, A was not successfull in
% eliciting a spike on B. 
% The interval to look at is defined by the nest spike on A, or a set
% maximum interval of e.g. 50 msec. If A elicits for example more than one
% spike on B, store both intervals.                 
% Of course a cross correlation of A and B would do a similar thing, but it
% does not consider if e.g. for a given tau, A has spikes already again,
% and therefore might relate the spiking at delay tau on B to a spike at 0
% on A which would in fact not be true
% 
% 
% It was observed, and postulated by others, that groups, or subsets of
% channels (neurons) exist which entail each other more often and faster
% than neurons from another group. Sth. like that should be seen in such
% kind of analysis, because a fast and regular entailment should be
% reflected in a peak at short delays when considering the influence of
% spiking A in spiking B





%%%%%%%%
% input:
% 
% 
%datname                         The fiel name 
% 
% 
% 
% ls:                           The ususal list with spiek information
% 


% 
% 
% 
% CHANNEL_VEC                   A couple of MEA channel nrs for which the
%                               analysis should be done
% 
% 
% time_start, time_end          start and end time of considered period
% 
% 
% 
% 



function AB_Spike_Pairing(datname,ls,NB_onset,CHANNEL_VEC,time_start,time_end)


%some predefinitions:

%since analysis works with small bin sizes, and therefore long vectors,
%restrict the nr. of spikes under consideration at once
NR_SPIKES_PERIOD    = 2^15;   %just one way to do it

%maximum interval to consider after a spike on A, in MSEC!
MAX_TIME_INT       = 20;


%Bin_width for spike trains and interval histograms, in MSEC!
BIN_WIDTH          = 0.5;



%nr of channels
nr_ch  =  length(CHANNEL_VEC);

NB_set = NB_onset(find(NB_onset(:,2) > time_start*3600 & NB_onset(:,2)<time_end*3600),2);

%extract all the spikes in the relevant period, AND TAKE ONLY SPIKES AROUND
%A NB ONSET
all_spikes_ind = [];
for nr_NB = 1:length(NB_set)
    all_spikes     = find(ls.time>NB_set(nr_NB) & ls.time<NB_set(nr_NB)+ 3*MAX_TIME_INT/1000);
    all_spikes_ind = [all_spikes_ind all_spikes];
end

    
    
%take all spikes, 
%all_spikes_ind = find(ls.time > time_start*3600 & ls.time<time_end*3600);


% if length(all_spikes_ind) > NR_SPIKES_PERIOD
%     nr_periods = floor(length(all_spikes_ind)/NR_SPIKES_PERIOD);
%     %assure that there are only fully filled periods
%     for ii=1:nr_periods;
%         period_ind{ii} = all_spikes_ind((ii-1)*NR_SPIKES_PERIOD+1:ii*NR_SPIKES_PERIOD);
%     end
% else
%    disp('NOT ENOUGH SPIKES IN PERIOD, give longer period');
%    return;
% end

%don't look at different periods because I extarct spikes shortly after NB only,
%there are not that much
if length(all_spikes_ind) > NR_SPIKES_PERIOD
    period_ind{1} = all_spikes_ind(1:NR_SPIKES_PERIOD);
else
    period_ind{1} = all_spikes_ind;
end



%start with looping through the periods

for ii=1:1 %nr_periods
    spike_indices  = period_ind{ii};
    binning_start  = ls.time(spike_indices(1));
    binning_end    = ls.time(spike_indices(end));
    
    %start to look at each channel, store the spike time
    %Furthermore make spike trains from the spike times by binning the spike times
    binning_vec = binning_start:BIN_WIDTH/1000:binning_end;
   
    for jj=1:nr_ch
        ch_spikes{jj}      =  ls.time(spike_indices(find(ls.channel(spike_indices)==cr2hw(CHANNEL_VEC(jj)))));
        ch_spikes_hist{jj} =  hist(ch_spikes{jj},binning_vec);
        hist_ind{jj}       =  find(ch_spikes_hist{jj}>=1);
    end
    
    
    
    
    AB_Spike_entailing   = cell(nr_ch,nr_ch);
    %now cycle through each 'reference' channel and  target channel and
    %look at the spike times in the reference channel and if there is a
    %spike on the target channel before the reference channels spike again
    
    
    for ref_ch = 1:nr_ch
        spikes_entailed = zeros(1,nr_ch);
        
        %look at each spike on the ref channel, except for the last one
        for ref_ch_ct = 1:length(hist_ind{ref_ch})-1;
                
            
            %these are the indices in ch_spikes_hist, meaning the binned
            %vectors, with BIN_WIDTH
            hist_ind_current = hist_ind{ref_ch}(ref_ch_ct);
            hist_ind_next    = hist_ind{ref_ch}(ref_ch_ct+1);
            
            
            %now look at the target channels, for the respective spike on
            %the reference channel
            for target_ch = 1:nr_ch
                %a counter that counts the elicited spikes on target by the
                %reference
                other_ch_spike = false;
                
                if target_ch==ref_ch
                    %don't look at target_ch == ref_ch
                    continue
                end
                
                if sum(ch_spikes_hist{target_ch}(hist_ind_current:hist_ind_next-1)) >=1
                    %the case when there is at least one spike on the target channel
                    
                    %find the spike delay on the target channel relative to the reference spike 
                    target_ch_ind = hist_ind{target_ch}(find(hist_ind{target_ch} >= hist_ind_current & hist_ind{target_ch} <= hist_ind_next-1));
                    %store the target_ch_ind as relative indices
                    target_ch_ind = target_ch_ind - hist_ind_current;
                    
                    for nr_follow = 1:length(target_ch_ind);
                        
                        %check if the ' entailed' spikes are in the desired
                        %window after the reference spike
                        if target_ch_ind(nr_follow)*BIN_WIDTH  <= MAX_TIME_INT 
                            
                            
                            for other_ch = setdiff([1:nr_ch],[target_ch,ref_ch]);
                                %IF any of the OTHER channels spike
                                %s inbetween the reference channel and the
                                %tartget channel, don't consider this as an
                                %entailement
                                %I need again absolute values of the
                                %target_ch_ind, not the relative ones
                                if sum(ch_spikes_hist{other_ch}(hist_ind_current:(hist_ind_current+target_ch_ind(nr_follow)-1))) > 0
                                   other_ch_spike = true;
                                   break;
                                end
                            end
                            
                                
                            if other_ch_spike
                                break;
                            end
%                             now I really have an elicited spike on the
%                             target
                            spikes_entailed(target_ch) = spikes_entailed(target_ch)+1;
                            
                            AB_Spike_entailing{ref_ch,target_ch}(spikes_entailed(target_ch))  = target_ch_ind(nr_follow)*BIN_WIDTH;
                        end
                    end %closing the for nr_follwo loop
                end %closing the if sum(...) loop
            
            end  %closing the target_ch loop
            
        end  %closing the ref_ch_ct loop
        
        spikes_entailed;    
    end%closing the ref_ch loop
    

    
    %if all the target intervals on all the target channels are found,
    %calculate the histograms of interval distribution
    
    AB_Spike_entail_hist = cell(nr_ch,nr_ch);
    hist_vec             = 0:BIN_WIDTH:MAX_TIME_INT;
    %also generate a plot
    Spike_entail_fig     = screen_size_fig();
    subplot_row          = nr_ch;
    subplot_col          = nr_ch;
    %a_filter             = 1;
    %b_filter             = 1/5*ones(1,5);
    triang_smooth         = 2/10*triang(10);
    for ref_ch = 1:nr_ch
            for target_ch = 1:nr_ch
                if target_ch == ref_ch
                    h_sub((ref_ch-1)*nr_ch+target_ch) = subplot(subplot_row,subplot_col,(ref_ch-1)*nr_ch+target_ch);
                    continue
                end
                AB_Spike_entail_hist{ref_ch,target_ch} = [hist(AB_Spike_entailing{ref_ch,target_ch},hist_vec)];
                
                h_sub((ref_ch-1)*nr_ch+target_ch)      = subplot(subplot_row,subplot_col,(ref_ch-1)*nr_ch+target_ch);
                smoothed_profile                       = conv(triang_smooth,AB_Spike_entail_hist{ref_ch,target_ch});
                bar(hist_vec,smoothed_profile(5:end-5)/sqrt(length(ch_spikes{ref_ch})*length(ch_spikes{target_ch})));
                title(['channel ', num2str(CHANNEL_VEC(ref_ch)),' and ', num2str(CHANNEL_VEC(target_ch))]);
                xlabel('delay t [msec]' );
                ylabel('counts' );
                xlim([-5 MAX_TIME_INT+5]);
                
            end
    end
    subplot(subplot_row,subplot_col,1);
    title({['datname: ', num2str(datname),' hr. ', num2str(time_start),' to ', num2str(time_end),' of recording'];...
           ['Spike delays when Channel A spikes followed by a spike on Channel B.'];...
           ['No spike on another Channel inbetween. Bin width ' num2str(BIN_WIDTH), 'msec']},'Interpreter', 'none' );




end




disp(' hallo' );


































