%There is the idea that there are distinct subgroups of NBs (others call it
%SBE, synchronized burst events, Ben-Jacob, Segev and others). Each
%subgroup has its own spatio-temporal fingerprint. I.e. in the different
%subgroups different electrodes participate with e.g. different strength and
%delay in the NB. Finding these subgroups is of interest in terms of how
%many, or which differnt pathways exist in the network. Furthermore, are
%there e.g. differences in stimulation/response properties for neurons from
%different subgroups?
% The following analysis is mostly based Segev et al, 2005 PRL. It includes cross-corrlation, 
% clustering algorithms and dendrograms.
%
%It was modified to my own needs, basically I played around with the nr. of
%spikes after the NB start to consider for cross correlation, the Kernel
%width (the mentioned authors take an activity-dependent kernel width), or
%if it is even better to consider all spikes in a fixed size window. 
% It seemed that taking all spikes in the burst gives bad results, at least given the different 
% other settings (fixed kernel width). However to make the algorithm work
% successfully, adjsutement of the parameters is probbaly necessary for
% each dataset individually
% 
% 
% 
% 
% 
%
%
%
%%%%%%%%%%%%%%%%%%%
% input: 
% datname:              the file name
% 
% 
% ls:                   the usual structure with spike information
% 
% 
% 
% burst_detection       all the detcted bursts in datname, generated with
%                       the function burst_detection_all_ch
% 
% 
% 
% network_burst        all the detected Network bursts, generated with the
%                      function NB_detection
% 
% 
% NB_onset             All the Network burst onset times,a retrun value of the NB_detection fucntion 
% 
% 
% b_ch_mea             the relevant MEA-style bursting channels, also a
%                      return value from NB_detection
% 
% 
% time_start,          start and end time of recording where the analysis should be done 
% time_end 
% 








function NB_subgroups(datname,ls,burst_detection,network_burst,NB_onset,b_ch_mea,time_start,time_end)

%define some basics
nr_ch    = length(b_ch_mea);
hw_ch    = cr2hw(b_ch_mea);


%first of all, find all the NBs that lie in the specified period between
%time_start and time_end
NB_ind   = find(NB_onset(:,2) >time_start*3600 & NB_onset(:,2)<time_end*3600);
nr_NBs   = length(NB_ind)


%define the Bin width for binningh the spiek trains, use a small value (<5
%msec)
BIN_WIDTH    = 0.001; %in sec


%define differnt values of the Kernel width with which the spike trains are
%convoluted. Different Kernel Widths can be used to test the power of the
%algorithm w.r.to this parameter. Running the algorithm in a loop with
%different values for Kernel Width and comparing in the end the results
%gives hints about the best value. So far, small Kernel widths are used (2
%to3 msec), larger values probably smear out the spike trains and make them
%more equal (testes on one dataset). So far, I have only implememnted a
%fixed Kernel size, others used an activity dependent Kernel size. Might be
%worth checking
KW_ARRAY     = [1:3];

%Same holds for the Maximum_Time_Shift when calculating the cross
%correlation. Altough of course the cross correlation is calculated in
%steps of the BIN_WIDTH, the MAX_TIME_SHIFT determines how many such steps
%should be taken (in po. and neg. direction, i.e. [-tau +tau].
% It turned out that this parameter is also somewhat critical for the
% resulst, probablys small values are better, becuase this more or less
% then considers a jitter in the spike times, which should be in the range
% of a couple of msec. So far I came up with range 0 and 10 msec 
MAX_TS_ARRAY = [0:3];



%loop through the different Kernel Widths
for KW_ct = 1%:length(KW_ARRAY)
    
        KERNEL_WIDTH    = KW_ARRAY(KW_ct)
         
        %loop through the MAX_TIME_SHIFT
    for MAX_TS_ct = 1%:length(MAX_TS_ARRAY)
        
        MAX_TIME_SHIFT  = MAX_TS_ARRAY(MAX_TS_ct)

        %initialize the necessary cell arrays first
        ch_spikes_hist  = cell(nr_ch,nr_NBs);
        ch_rate_conv    = cell(nr_ch,nr_NBs);

        
        %define the Kernel fct with which the spike trains are convoluted
        %to get an inst. rate estimate and not only binary spike trains.
        %So far I use gaussian Kernel, limited in the range to +-10 times
        %the BIN_WIDTH
        kernel_fct      = gauss_kernel(-10:10,0,KERNEL_WIDTH);


        %extract all the spikes in the resp channels that are in bursts and
        %convolve them with the kernel to get a rate estimate
        for ii=1:nr_ch
            
            for jj=1:nr_NBs
                
                %find the position of the channel ii in the NB nr jj
                ch_pos                  = find(network_burst{NB_ind(jj),1}==hw_ch(ii)+1);
                
                %if hw_ch would start two times in a NB, this rarely
                %happens, but otherwise this would lead to an error
                if length(ch_pos >1)
                    ch_pos = ch_pos(1);
                end
                %find the burst index of the channel ii in the NB jj 
                ch_burst_ind            = network_burst{NB_ind(jj),4}(ch_pos);
                
                
                %extract the spike times of channel ii in the NB jj, RELATIVE TO
                %THE NB ONSET, take only the first X spikes in the burst,
                %if there is no spike, male ch_spikes empty
                NR_spikes_per_burst         = 1;
                if length([burst_detection{1,hw_ch(ii)+1}{ch_burst_ind,3}]) >= NR_spikes_per_burst
                    ch_spikes               = [burst_detection{1,hw_ch(ii)+1}{ch_burst_ind,3}(1:NR_spikes_per_burst)] - NB_onset(NB_ind(jj),2);
                    
                elseif length([burst_detection{1,hw_ch(ii)+1}{ch_burst_ind,3}]) < NR_spikes_per_burst & length([burst_detection{1,hw_ch(ii)+1}{ch_burst_ind,3}]) >0
                    ch_spikes               = [burst_detection{1,hw_ch(ii)+1}{ch_burst_ind,3}(1:end)] - NB_onset(NB_ind(jj),2);
                    
                else 
                    ch_spikes               = [];
                end

                
                %define a period how long the spiek traisn should be
                %binned, 
                TIME_AFTER_START = 0.05;

                %bin the burst-spike-train from the NB onset to the end on the
                %particular channel
                if ~isempty(ch_spikes) 
                    
                    %if there is only the first spike at 0, i.e the
                    %NB starting spike, or the first spike is amlles than
                    %the BIN_WIDTH, make the first bin fill automatically,
                    %BUT THIS SHOULD BE OBSOLETE BY USING HISTC instead of
                    %hist
                    if max(ch_spikes)<BIN_WIDTH
                        ch_spikes_hist{ii,jj}             = zeros(1,length(0:BIN_WIDTH:TIME_AFTER_START));
                        ch_spikes_hist{ii,jj}(1)          = 1;
                    else
                        %use histc to bin the spiek trains
                        ch_spikes_hist{ii,jj}             = histc(ch_spikes,0:BIN_WIDTH:TIME_AFTER_START);
                    end
                     
                    %calculate the inst. rate by convolving with the
                    %mentioned kernel fct
                    ch_rate_conv{ii,jj}                   = conv(ch_spikes_hist{ii,jj},kernel_fct)/BIN_WIDTH;
                end
                
                
            end %the nr_NBs loop
          
            
        end %the nr_ch loop




        %set the index for the MAX_TIME_SHIFT, this is the MAX_LAG
        %parameter in the function xcorr
        max_shift_ind  = MAX_TIME_SHIFT/1000/BIN_WIDTH;

        
        %go over and calculate the cross correaltion between the bursts of
        %electrode ii in the NBs n (ref) and m (target)
        %cycle through all reference bursts
        for ref = 1:nr_NBs
            
            ref
            temp_cross_corr    = cell(1,nr_NBs);
            
            %cycle also through all target bursts
            for targ = 1:nr_NBs

                %cycle through all channels
                for ii=1:nr_ch
                    
                   %if there are at least X spike in the spike trains
                   if (sum(ch_spikes_hist{ii,ref}) >0 & sum(ch_spikes_hist{ii,targ})>0) 
                          
                       %the cross_corr is normalized w.r.to the sqrt of the
                       %product of the nr of spikes in the ref burst and
                       %the target burst. This considers the activity
                       %levels in both bursts. Not sure yet if this is a
                       %useful normlization. But previous versions w/o
                       %normalizationwere not very useful (Maybe Ialso had
                       %wrong parameters). Maybe normalizarion is also only
                       %usefule when taking more than one spieke ina
                       %burst, Why should I have a normalization when I
                       %have always only one spike:?
                       %temp_cross_corr{targ}(ii,:) = xcorr(ch_rate_conv{ii,ref},ch_rate_conv{ii,targ},max_shift_ind)/(sqrt(sum(ch_spikes_hist{ii,ref})*sum(ch_spikes_hist{ii,targ})));
                        
                       %w/o normalization, as explained, normalization
                       %shouldn't be of interest when considering only the
                       %first spike
                       temp_cross_corr{targ}(ii,:) = xcorr(ch_rate_conv{ii,ref},ch_rate_conv{ii,targ},max_shift_ind);
                   end

                end %the nrch loop
                
            end %the targ burst loop
            
            %this gives the correlation for each target NB w.r.to the ref NB among the channels (summing
            %across channels. This is done according to Segev et al, 2004
            %PRE. Thsi is one way of comparing different NBs about their
            %similarity. It is important to note that I only calculate
            %cross correlations across different NBs for always same
            %channels, no cross correlation between channels! Maybe this is
            %a good thing to do, becuase firing patterns for same channels
            %but different NBs have more correlation that firing patrerns
            %for differnt channels but same NB
             NB_channel_sum_correl = cellfun(@sum,temp_cross_corr,'UniformOutput',false);
           
              
             %When teh summed cross correlation was obtained (Sum of teh
             %cross_corr from each chanel individually) I look at the
             %maximum obtained cross correlation w.r. to the shift tau.
             %I.e. take the value which is maximal. Example: If two NBs are
             %from the same 'type', the cross_corr for the individual
             %channels should be high, as well as the sum should be high,
             %so should there be a clearer maximum. When the two NBs are
             %not from the same type, the individual channels might have
             %maxima as well but the shifted in different directions. So
             %the sum should avergae out any bigger similarity between
             %these NBs
             NB_correl(ref,:)              = cellfun(@max,NB_channel_sum_correl);
            
        end %the ref burst loop

        
        %when a paramter test is done, sabe the result in an array
        NB_correl_TS_KW{MAX_TS_ct,KW_ct} = NB_correl;


    end   %end the MAX_TIME_SHIFT loop
    
    
end  %end the KERNEL_WIDTH loop


%save the paramter test results
save_file_name = strcat(datname,'_NB_subgroups_param_test.mat');
%save(save_file_name, 'NB_correl_TS_KW', 'MAX_TS_ARRAY', 'KW_ARRAY','BIN_WIDTH',  'datname', 'time_start', 'time_end', 'b_ch_mea') 

disp('halldo');





%Make the clustering:
% As already done previously, first calculate the pairwise distance for NB
% n and m as difference between the correaltion between n and m'  and m and
% m', summed over all m'. I.e. calculate  in how much n and m are similar
% compared toall other NBs. This is often used to calculate a similarity
% measure (distance in N-dimensional space).
% Then apply a single-linkage algorithm which finds the smallest ditance
% between two elements of a cluster and makes the assignement for each
% element to the cluster. 
% The following dendrogram function plots the hierarchical structure tree
% as obtained from the linkage function and generates arrays and indices
% for each element, to which cluster it belongs and indices for sorting
% (and later usage) the elements according to similarity.
% 
% The resulting plot is done with sorted indices already and should
% therefore show a block-structure, which indicates elements taht are
% similar in the n-dimensional space, i.e they form clusters
% 

for kw=1%1:length(KW_ARRAY)
    for ts=1%:length(MAX_TS_ARRAY)
        
        %work on a single parameter setting
        NB_correl     = NB_correl_TS_KW{ts,kw};

        %try to find clusters in the NB similarities with the single link
        %algorithm
        %calculate an euclidean distance between the row vectors in NB_correl, i.e.
        %the correlation of the NBs with all others, this is a 2*(nr_NB)*(nr_NB-1)
        %long array with the distances of NB 1 in (1,2),(1,3),...(1,nr_NB) and for
        %NB 2 in (2,1),(2,3),...(2,nr_NB)
        NB_cc_pdist   = pdist(NB_correl,'euclidean');


        %generate the hierarchical cluster tree with the linkage function
        % use single linkage clustering, the minimum distance between two elements
        % in two clusters determines the belonging to a cluster
        NB_cc_linkage = linkage(NB_cc_pdist,'single');


        %calculate and plot the dendrogram tree which shows the grouping of the NB
        %to the clusters, or leaves
        combfig = screen_size_fig();
        subplot(4,4,[1:3])
        [NB_dendrogr_handle NB_leaves NB_cc_perm_ind] = dendrogram(NB_cc_linkage,0);
        title({['datname: ', num2str(datname),', hr ', num2str(time_start),' to hr ', num2str(time_end),' of recording'];...
            ['Running a clustering algorithm on the NBs, considering the xcorr of indiv. channels across different Nbs'];...
            ['And making the sum of all channels, then taking the maxima as the similarity measure'];...
            [' MAX_TIME_SHIFT is: ',num2str(MAX_TS_ARRAY(ts)),' msec, KERNEL_WIDTH is: ', num2str(KW_ARRAY(kw)),' msec']},'Interpreter','none');
        
        %NB_subgroups_fig = screen_size_fig();
        subplot(4,4,[5:7 9:11 13:15]);
        imagesc(NB_correl(NB_cc_perm_ind,NB_cc_perm_ind));
        drawnow
        axis square
        title([' MAX_TIME_SHIFT is: ',num2str(MAX_TS_ARRAY(ts)),' msec, KERNEL_WIDTH is: ', num2str(KW_ARRAY(kw)),' msec'],'Interpreter','none');

    end  %end the Time shift loop
end %end the Kernel_width loop





%define a region of interest in the resorted matrix
%this is the NB_nr (innetwork burst) that make up the diagonal block
INTEREST_IND         = [206:248];

BINNING_WIDTH        = 0.001;
KERNEL_WIDTH         = 4;
TIME_WINDOW          = 0.15;

NB_ind_square_clust1 = NB_ind(NB_cc_perm_ind(INTEREST_IND));
NR_of_NB_in_clust    = length(NB_ind_square_clust1);

kernel_fct           = gauss_kernel(-10:10,0,KERNEL_WIDTH);
screen_size_fig();

for ii=1:nr_ch
    subplot(nr_ch,2,2*(ii-1)+1);
    conv_ch_rate = zeros(1,length(conv(kernel_fct,zeros(1,length(0:BINNING_WIDTH:2*TIME_WINDOW)))));
    
    for jj=1:NR_of_NB_in_clust
   
        if (find(network_burst{NB_ind_square_clust1(jj),1}==hw_ch(ii)+1))
            NB_start = NB_onset(NB_ind_square_clust1(jj),2);
            ch_ind   = find(network_burst{NB_ind_square_clust1(jj),1}==hw_ch(ii)+1);
            if length(ch_ind>1)
                ch_ind   = ch_ind(1);
            end
            ch_spikes = ls.time(find(ls.channel==hw_ch(ii) & ls.time >NB_start-0.15 & ls.time<NB_start+0.35));
            burst_nr  = network_burst{NB_ind_square_clust1(jj),4}(ch_ind);
           
            %plot([burst_detection{1,hw_ch(ii)+1}{burst_nr,3} - NB_start],jj,'k*','MarkerSize',3,'MarkerFaceColor','k');
            %plot([burst_detection{1,hw_ch(ii)+1}{burst_nr,3} - NB_start],jj,'k*');
            plot(ch_spikes - NB_start, jj,'k*' );
            hold on
            rel_burst_end     = burst_detection{1,hw_ch(ii)+1}{burst_nr,3}(end) - NB_start;
            hist_burst_spikes = hist([burst_detection{1,hw_ch(ii)+1}{burst_nr,3} - NB_start],0:BINNING_WIDTH:2*TIME_WINDOW);
            conv_ch_rate      = conv_ch_rate + conv(kernel_fct,hist_burst_spikes);
        end
        
        title(['channel: ', num2str(b_ch_mea(ii))],'FontSize',8);
        xlabel(['time r.t. NB start'],'FontSize',8);
        ylabel(['NB trial'],'FontSize',8);
        xlim([-0.15 TIME_WINDOW]);
        %xlim([-0.05 0.1]);
        ylim([ 0 length(INTEREST_IND)]);
       
    end
     rate_plot_handle(ii)  =  subplot(nr_ch,2,ii*2);
     rate_time_ind         = floor(length(kernel_fct)/2):(length(conv_ch_rate)- floor(length(kernel_fct)/2));
     conv_ch_rate_time_vec = [-floor(length(kernel_fct)/2):(length(hist_burst_spikes)+ floor(length(kernel_fct)/2)-1)]*BINNING_WIDTH;
     rate_max_val(ii)      = max(conv_ch_rate(1:TIME_WINDOW/BINNING_WIDTH)/(BINNING_WIDTH*NR_of_NB_in_clust));
     plot(conv_ch_rate_time_vec,conv_ch_rate/(BINNING_WIDTH*NR_of_NB_in_clust));
     xlim([-0.15 TIME_WINDOW]);
     %xlim([-0.15 0.1]);
     ylabel(['rate [Hz]'],'FontSize',8);
     xlabel(['time r.t. NB start'],'FontSize',8);
     title(['channel: ', num2str(b_ch_mea(ii))],'FontSize',8);
end
         set(rate_plot_handle(:),'ylim',[0 1.2*max(rate_max_val)]);   
         subplot(nr_ch,2,1);
         title({['Taking indices ', num2str(INTEREST_IND(1)),' to ', num2str(INTEREST_IND(end)),' from the sorted sqaure matrix NB_correl'];...
                ['channel: ', num2str(b_ch_mea(1))]},'interpreter', 'none','FontSize',8);


















    
