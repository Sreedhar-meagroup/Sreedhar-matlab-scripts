%DOCUMENTATION
%March, 3rd
%NOTE: the first version calculated the cross covariance between network burst length and interval in the following way
%xcov(length,interval,...), i.e. first input to xcov was the vector of lengths, the 2nd input was the vector of nb intervals
%  This led to the fact that in the series of cross-covariance measures, a positive index ment actually a preceding interval,
%  and negative indices following interval. This is somewhat counterintuitive and difficult to communicate in plots. Therefore, it is
%  advisable to change the calculation of the cross-covariance to xcov(interval, length,...), in order to relate
%  positive indices with following intervals and negative indices with preceding intervals.
%  It has to be taken great care that old a new way of calclation, analyzed data, or even plotted results don't mix up.
%  I run the whole analysis from scratch with the new way of calculation for all datasets.
% %
%
%INPUT: 

% Spont_act_datasets:   The structure which is a return value from the fct get_spont_act_datasets.
%                       information about spont act data is stored in this structure
%                       
%                       
% Dataset_ID:           The acc. dataset numer in this structure which should be analyzed                      

function NB_interval_length_cov_analysis(Spont_act_datasets, Dataset_ID)



Save_folder = 'C:\Program Files\MATLAB71\work\Spontaneous activity & Network bursts'
curr_folder = cd;

%Positions of the subplots
subplot_row = 3;
subplot_col = 5;
Subplot_fig{1} = [1:3];
Subplot_fig{2} = [4:5];
Subplot_fig{3} = [6]; Subplot_fig{4} = [7];
Subplot_fig{5} = [9]; Subplot_fig{6} = [10];
Subplot_fig{7} = [11]; Subplot_fig{8} = [12];
Subplot_fig{9} = [14]; Subplot_fig{10} = [15];

%no of datasets, for looping
No_spont_data = length(Dataset_ID);

%loop through each dataset, load the data, calculate burst and NBs, define
%NB lengths, intervals etc and make the covariance analysis and plot it.
%Covariances of the sam kind are plotted in the same figure, for different
%datastes. A mean is finally calculated overr all datasets
%Cov_fig_h = screen_size_fig();

for ii = 1:No_spont_data
    datname = Spont_act_datasets(ii).name;

    %load the data
    if strcmp(datname,'010906_228.spike') | strcmp(datname,'010906_229.spike') | strcmp(datname,'040906_228.spike')

        ls = loadspike_noc_shortcutouts(datname,2,25);

    else
        ls = loadspike_longcutouts_noc_bigfiles(datname,2,25);
    end

    %there are some datasets where I use only a reduced size
    if strcmp(datname,'010906_228.spike')
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'17_11_06_335.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'08_01_07_400_fbonburst_fakestim.spike')
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'28_06_07_674_NetwResp.spike');
        ls = get_shrinked_ls(ls,0,1.5);
    elseif strcmp(datname,'29_06_07_676_NetwResp.spike');
        ls = get_shrinked_ls(ls,0,1);
    elseif strcmp(datname,'02_08_07_743_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'06_08_07_742_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'12_11_07_923_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'24_01_08_1028_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'15_04_08_1134_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname, '14_05_08_1162_spont.spike');
        ls = get_shrinked_ls(ls,0,2);
    end

    %define the standard burst criterion a priori
    BURST_MAX_INTERVAL_LENGTH = 0.1;
    BURST_MAX_BURST_INT       = 0.2;
    BURST_MIN_NO_SPIKES       = 3;

    %NB criteria
    MIN_DELAY                         = 0.1;
    MIN_DELAY_EXTRA                   = 0.2;
    MIN_NO_ELEC                       = 3;
    NO_CH                             = 60;   %take the maximum no channels possible

    %make changes on the burst and NB detection for indiv. datsets
    if strcmp(datname,'010906_228.spike')
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'010906_229.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'040906_228.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'17_11_06_335.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'28_11_06_331_feedbackstim.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'08_01_07_400_fbonburst_fakestim.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'18_01_07_400_fbonburst_fakestim.spike');
        MIN_NO_ELEC         = 2;
    elseif strcmp(datname,'19_01_07_400_fbonburst_fakestim.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
        MIN_DELAY_EXTRA           = 0.4
    elseif strcmp(datname,'28_06_07_674_NetwResp.spike');
        BURST_MIN_NO_SPIKES       = 2
    elseif strcmp(datname,'29_06_07_676_NetwResp.spike');
        BURST_MIN_NO_SPIKES       = 2
    elseif strcmp(datname,'01_08_07_745_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.15;
        BURST_MAX_BURST_INT       = 0.3;
    elseif strcmp(datname,'02_08_07_743_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.15;
        BURST_MAX_BURST_INT       = 0.3;
    elseif strcmp(datname,'24_08_07_767_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.15;
        BURST_MAX_BURST_INT       = 0.3;
        MIN_DELAY                 = 0.2;
    elseif strcmp(datname,'28_08_07_760_spont.spike');
        MIN_NO_ELEC               = 2;
        BURST_MAX_INTERVAL_LENGTH = 0.25;
        BURST_MAX_BURST_INT       = 0.5;
        MIN_DELAY                 = 0.2;
    elseif strcmp(datname,'02_10_07_918_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
        MIN_NO_ELEC               = 2;
    elseif strcmp(datname,'08_10_07_918_spont.spike');
        BURST_MIN_NO_SPIKES = 2;
        MIN_NO_ELEC         = 2;
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
    elseif strcmp(datname,'07_11_07_921_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.25;
        BURST_MAX_BURST_INT       = 0.5;
        MIN_DELAY_EXTRA           = 0.4;
    elseif strcmp(datname,'09_11_07_923_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
        MIN_DELAY_EXTRA           = 0.4;
    elseif strcmp(datname,'24_01_08_1028_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
        MIN_DELAY_EXTRA           = 0.4;
    elseif strcmp(datname,'15_02_08_1058_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
        MIN_DELAY_EXTRA           = 0.4;
    elseif strcmp(datname,'22_02_08_1089_spont.spike');
        MIN_NO_ELEC = 2;
    elseif strcmp(datname,'28_02_08_1092_spont.spike');
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
    elseif strcmp(datname,'05_03_08_1089_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
        BURST_MAX_INTERVAL_LENGTH = 0.2;
        BURST_MAX_BURST_INT       = 0.4;
    elseif strcmp(datname,'10_03_08_1086_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
        MIN_NO_ELEC               = 2;
    elseif strcmp(datname,'10_03_08_1078_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
    elseif strcmp(datname,'09_05_08_1164_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
    elseif strcmp(datname,'14_05_08_1162_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
        MIN_NO_ELEC               = 2;
    elseif strcmp(datname,'24_09_08_1256_spont.spike');
        BURST_MIN_NO_SPIKES       = 2;
        MIN_NO_ELEC               = 2;
    end


    %MAKE burst and NB detection
    burst_detection  = burst_detection_all_ch(ls,BURST_MAX_INTERVAL_LENGTH,BURST_MAX_BURST_INT ,BURST_MIN_NO_SPIKES);
    %NB detection
    [b_ch_mea network_burst NB_onset] = Networkburst_detection(datname,ls,burst_detection,NO_CH,MIN_DELAY ,MIN_DELAY_EXTRA,MIN_NO_ELEC);

    %calculate the no. of active channels and the average no of NBs per min
    [no_b_ch no_bursts] = get_bursting_ch(burst_detection,NO_CH);
    rec_time            = ls.time(end) - ls.time(1);
    %the criterion is >= 20 bursts per hour on average
    Spont_act_datasets(ii).no_act_ch = length(find(no_bursts/(rec_time/3600)>=20));
    no_NBs                        = size(network_burst,1);
    %average no of NBs per minute
    Spont_act_datasets(ii).NB_min = round(no_NBs/(rec_time/60)*1000)/1000;

    %check if the detection was good enough
    %this return the command to command line, settings can be made in the
    %mfile
    %keyboard
    close(gcf);

    NB_starts    = cellfun(@(x) x(1),network_burst(:,2));
    NB_ends      = cellfun(@(x) max(x),network_burst(:,5));
    NB_intervals = NB_starts(2:end) - NB_ends(1:end-1);
    NB_lengths   = NB_ends - NB_starts;
    %calculate the no of spikes rather than the length in time

    NB_lengths_spikes     = zeros(1,length(NB_lengths));
    NB_rate               = zeros(1,length(NB_lengths));
    for jj=1:length(NB_lengths);
        NB_lengths_spikes(jj) = length(find(ls.time>=NB_starts(jj) & ls.time<=NB_ends(jj)));
        %also calculate the rate
        NB_rate(jj)           = NB_lengths_spikes(jj)/NB_lengths(jj);
    end


    %generate the figure where all the subplots go
    Fig_h(ii) = screen_size_fig();
    %plot the rate in the first subplot
    sub_fig(ii,1) = subplot(subplot_row, subplot_col,Subplot_fig{1});
    Superburst_array_rate(ls,ls.time(1)/3600,ls.time(end)/3600,sub_fig(ii,1));
    title({[num2str(datname)];['rate profile']});
    xlabel('time [hrs]')
    ylabel('rate [Hz]');


    %plot a raster with detected NBs for a specific time
    sub_fig(ii,2)   = subplot(subplot_row, subplot_col,Subplot_fig{2});
    rec_length   = ls.time(end) - ls.time(1);
    raster_start = rec_length/2;
    raster_end   = raster_start+500;
    spike_ind    = find(ls.time>=raster_start & ls.time<=raster_end);
    %make the rqster plot,
    plot(ls.time(spike_ind),ls.channel(spike_ind),'ok','markersize',2,'markerfacecolor','k');
    title({['100 sec. raster plot'];['NB on- and offset in red and blue']});
    xlabel('time [sec]');
    ylabel('electrode');

    NB_ind   = find(NB_starts > raster_start & NB_ends < raster_end);
    %onset times of NB in the plot
    nb_onset_marker_times  = NB_starts(NB_ind);
    nb_onset_marker_lines  = line([nb_onset_marker_times' ; nb_onset_marker_times'],[-1 64]);
    %end times of NB in the plot
    nb_end_marker_times  = NB_ends(NB_ind);
    nb_end_marker_lines  = line([nb_end_marker_times' ; nb_end_marker_times'],[-1 64]);

    %set the markers in different color
    set(nb_onset_marker_lines(:),'Color','r');
    set(nb_end_marker_lines(:),'Color','b');

    ylim([-1 64]);
    %show only 100 sec. of the raster plot
    xlim([raster_start+150 raster_end-150]);



    %plot the  distributions of NB length, intervals, rate...
    sub_fig(ii,3) = subplot(subplot_row, subplot_col,Subplot_fig{3});
    NB_length_std  = std(NB_lengths);
    NB_length_max  = max(NB_lengths);
    NB_length_mean = mean(NB_lengths);
    NB_length_vec = 0:NB_length_std/10:4*NB_length_mean;
    NB_length_hist = hist(NB_lengths,NB_length_vec);
    bar(NB_length_vec,NB_length_hist./length(NB_lengths));
    xlabel('[sec]');
    ylabel('probability'); title(['Network burst length']);
    axis square;


    %Network burst lengths distribution
    sub_fig(ii,4) = subplot(subplot_row, subplot_col,Subplot_fig{4});
    NB_lengths_spikes_std  = std(NB_lengths_spikes);
    NB_lengths_spikes_max  = max(NB_lengths_spikes);
    NB_lengths_spikes_mean = mean(NB_lengths_spikes);
    NB_lengths_spikes_vec = 0:NB_lengths_spikes_std/10:4*NB_lengths_spikes_mean;
    NB_lengths_spikes_hist = hist(NB_lengths_spikes,NB_lengths_spikes_vec);
    bar(NB_lengths_spikes_vec,NB_lengths_spikes_hist./length(NB_lengths_spikes));
    xlabel('[spikes]');
    ylabel('probability'); title(['Network burst length '])
    axis square;


    %Network burst rate distribution
    sub_fig(ii,7) = subplot(subplot_row, subplot_col,Subplot_fig{7});
    NB_rate_std  = std(NB_rate);
    NB_rate_max  = max(NB_rate);
    NB_rate_mean = mean(NB_rate);
    NB_rate_vec = 0:NB_rate_std/5:4*NB_rate_mean;
    NB_rate_hist = hist(NB_rate,NB_rate_vec);
    bar(NB_rate_vec,NB_rate_hist./length(NB_rate));
    xlabel('[Hz]');
    ylabel('probability'); title(['Network burst rate'])
    axis square;


    %Network burst interval distribution
    sub_fig(ii,8) = subplot(subplot_row, subplot_col,Subplot_fig{8});
    NB_intervals_std  = std(NB_intervals);
    NB_intervals_max  = max(NB_intervals);
    NB_intervals_mean = mean(NB_intervals);
    NB_intervals_vec = 0:NB_intervals_std/5:4*NB_intervals_mean;
    NB_intervals_hist = hist(NB_intervals,NB_intervals_vec);
    bar(NB_intervals_vec,NB_intervals_hist./length(NB_intervals));
    xlabel('[sec]');
    ylabel('probability'); title(['Network burst intervals'])
    axis square;

    %same axes limits for the four subplots
    set_maximum_axlimits(sub_fig(ii,[3:4 7:8]),'y')


    %Analysis of correlation between network burst length and interval
    Bivariat_mat = [NB_lengths(1:end-1) NB_intervals NB_lengths_spikes(1:end-1)' NB_rate(1:end-1)'];
    MAX_LAG      = 10;

    %calculate the covarianc sequences. The covariance at lag 0 is the
    %correlation coefficient
    %TAKE CARE. CHANGE THE CALCULATION FROM XCOV(length,interval,...) to
    %xcov(interval, length,..), for inportant reasons stated at the beginning of this
    %file.
    [cov_seq{ii,1} lags] = xcov(Bivariat_mat(:,2),Bivariat_mat(:,1),MAX_LAG,'coeff');
    [cov_seq{ii,2} lags] = xcov(Bivariat_mat(:,2),Bivariat_mat(:,3),MAX_LAG,'coeff');
    [cov_seq{ii,3} lags] = xcov(Bivariat_mat(:,2),Bivariat_mat(:,4),MAX_LAG,'coeff');

    sub_fig(ii,5)           = subplot(subplot_row, subplot_col,Subplot_fig{5});
    cov_seq_h(ii,1)         = plot(lags,cov_seq{ii,1},'Color','r','Linewidth',1);
    xlabel('NB interval index')
    ylabel('correlation coefficient')
    title({['length (sec) and interval'];['0 denotes following, +1 prec. interval']})
    axis square;

    sub_fig(ii,6)           = subplot(subplot_row, subplot_col,Subplot_fig{6});
    cov_seq_h(ii,2)      = plot(lags,cov_seq{ii,2},'Color','r','Linewidth',1);
    xlabel('NB interval index');
    ylabel('correlation coefficient');
    title(['length (spikes) and interval']);
    axis square;

    sub_fig(ii,9)           = subplot(subplot_row, subplot_col,Subplot_fig{9});
    cov_seq_h(ii,3)      = plot(lags,cov_seq{ii,3},'Color','r','Linewidth',1);
    xlabel('NB interval index');
    ylabel('correlation coefficient');
    title(['rate and interval']);
    axis square;


    set_maximum_axlimits(sub_fig(ii,[5:6 9]),'y');
    for kk = [5:6 9]
        axes(sub_fig(ii,kk))
        line_h = line([0 0],[min(ylim) max(ylim)],'Color','k','Linestyle','--');
    end

    %make the annotation as last on the subplot
    annot_pos = [0.7813    0.1400    0.1237    0.18]
    annot_h   = annotation('textbox',annot_pos);
    fd_names  = fieldnames(Spont_act_datasets(ii))
    fd_chars  = struct2cell(Spont_act_datasets(ii))
    for ll=2:7
        annot_string{ll} = horzcat(fd_names{ll},':   ',num2str(fd_chars{ll}));
    end
    set(annot_h,'string',annot_string,'Linestyle','none','Fontsize',12)


    %save the figure as a matlab and emf figure
    cd(Save_folder)
    data_folder = strcat(Save_folder,'\',datname);
    if ~exist(data_folder)
        mkdir(data_folder);
    end
    cd(data_folder);

    save_fn_fig = strcat(datname,'_NB_cov.fig');
    save_fn_emf = strcat(datname,'_NB_cov.emf');
    saveas(Fig_h(ii),save_fn_fig,'fig');
    saveas(Fig_h(ii),save_fn_emf,'emf');
    %save the the workspace variables for this dataset
    ALL_NB_int_mean{ii}            = NB_intervals_mean;
    ALL_NB_lengths_spikes_mean{ii} = NB_lengths_spikes_mean;
    ALL_NB_length_mean{ii}         = NB_length_mean;

    save(strcat(datname,'Cov_analysis.mat'));
    cd(curr_folder)

end
%END of calculation for indiv. datasets


%Now plot the Covariances for each dataset and of course the mean
Cov_seq_NB_int_length_fig = screen_size_fig();

%for the correlation between interval and length (sec)
Dataset_ind  = 1:No_spont_data; 
sub_h_cov(1) = subplot(2,2,1)
for ii = Dataset_ind
    plot(lags,[cov_seq{ii,1}],'-','Color',[0.8 0.8 0.8]);
    hold on
end
%make a mean over all datasets
   Mean_cov{1} = mean([cov_seq{Dataset_ind,1}],2);
   plot(lags,Mean_cov{1},'r','Linewidth',3);
   xlabel('NB interval index')
   ylabel('correlation coefficient')
   title({['All datasets, average in red'];['NB length (sec) and interval']})
   
   
%for the correlation between interval and length (no. of spikes)
sub_h_cov(2) = subplot(2,2,2)
for ii = Dataset_ind
    plot(lags,[cov_seq{ii,2}],'-','Color',[0.8 0.8 0.8]);
    hold on
end
%make a mean over all datasets
   Mean_cov{2} = mean([cov_seq{Dataset_ind,2}],2);
   plot(lags,Mean_cov{2},'r','Linewidth',3);
   xlabel('NB interval index')
   ylabel('correlation coefficient')
   title({['All datasets, average in red'];['NB length (no. of spikes) and interval']});
   
   
%for the correlation between interval and NB rate
sub_h_cov(3) = subplot(2,2,3)
for ii = Dataset_ind
    plot(lags,[cov_seq{ii,3}],'-','Color',[0.8 0.8 0.8]);
    hold on
end
%make a mean over all datasets
   Mean_cov{3} = mean([cov_seq{Dataset_ind,3}],2);
   plot(lags,Mean_cov{3},'r','Linewidth',3);
   xlabel('NB interval index')
   ylabel('correlation coefficient')
   title({['All datasets, average in red'];['NB rate and interval']});
   
   
%finally also save this figure
save_fn_all_data_fig = 'Spont_act_NB_cov.fig';
save_fn_all_data_emf = 'Spont_act_NB_cov.emf';

cd(Save_folder)
saveas(Cov_seq_NB_int_length_fig,save_fn_all_data_fig,'fig');
saveas(Cov_seq_NB_int_length_fig,save_fn_all_data_emf,'emf');


%also save the whole workspace
save('Spont_act_NB_cov.mat');
cd(curr_folder);





%%AS OF DEC. 11th 2008, the part below here is not supposed to work
%%properly. It was old code used for test purposes.


screen_size_fig();
subplot(2,1,1)
NB_index = [2:length(NB_lengths)-1];
plot(NB_intervals(NB_index),NB_lengths(NB_index),'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2)
axis square
xlabel('NB interval (following) [sec]')
 ylabel('NB length [sec]')
title({[num2str(datname)];[' following interval, NB index ',num2str(NB_index(1)),' to ',num2str(NB_index(end))]})


subplot(2,1,2)
plot(NB_intervals(NB_index-1),NB_lengths(NB_index),'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2)
xlabel('NB interval (preceding) [sec]')
ylabel('NB length [sec]')
title({[num2str(datname)];[' preceding interval, NB index ',num2str(NB_index(1)),' to ',num2str(NB_index(end))]})
axis square

%plot the Nb length n vs n+1
screen_size_fig();
subplot(2,1,1)
plot(NB_lengths(1:end-1),NB_lengths(2:end),'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2)
axis square
xlabel('NB length [sec], no. n ')
ylabel('NB length [sec], no. n+1 ')
title({[num2str(datname)];[' NB length,n vs. n+1']})
hold on
line_h = line([0 4],[0 4])
set(line_h,'Color','r','linewidth',2)

x_length = NB_lengths(1:end-1);
y_length = NB_lengths(2:end);
delta_y  = x_length - y_length;

nb_length_delta_y_histc = histc(delta_y,-2:0.05:2);
subplot(2,1,2);
bar(-2:0.05:2,nb_length_delta_y_histc)
xlabel('delta y = length(n) - length(n+1)')
ylabel('counts');
axis square






%FOR SUPERBURST DATA

NR_datasets = length([SB_stat_analysis.CID])
curr_path  = cd;

for jj=1:NR_datasets
    data_folder = SB_stat_analysis(jj).name;
    cd(data_folder);
    data_name = strcat(SB_stat_analysis(jj).name,'_SB_analysis.mat');
    load(data_name);
    cd(curr_path)

%     NR_SB = size(Superburst_analysis.Superburst,1);
%     datname = Superburst_analysis.name;
% 
%     SB_NB_last  = [];
%     SB_NB_first = [];
%     SB_onset    = [];
%     SB_offset   = [];
%     for ii=1:NR_SB
% 
%         SB_NB_last(ii)  = Superburst_analysis.Superburst{ii,sum(cellfun(@(x) ~isempty(x),Superburst_analysis.Superburst(ii,:)))}(3);
%         SB_NB_first(ii) = Superburst_analysis.Superburst{ii,1}(3);
%         SB_onset(ii)    = Superburst_analysis.Superburst{ii,1}(1);
%         SB_offset(ii)   = Superburst_analysis.Superburst{ii,sum(cellfun(@(x) ~isempty(x),Superburst_analysis.Superburst(ii,:)))}(2);
%     end
% 
%     SB_length = SB_offset - SB_onset;
% 
%     NB_starts    = cellfun(@(x) x(1),Superburst_analysis.NB(:,2));
%     NB_ends      = cellfun(@(x) max(x),Superburst_analysis.NB(:,5));
%     NB_intervals = NB_starts(2:end) - NB_ends(1:end-1);
% 
% 
% 
%     mean_nb_int    = mean(NB_intervals(setdiff(1:length(NB_intervals),[SB_NB_first-1:SB_NB_last])));
%     mean_SB_length = mean(SB_length);
%     
%     
% %     screen_size_fig();
% %     subplot(2,1,1)
% %     plot(NB_intervals(SB_NB_last)./mean_nb_int,SB_length,'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2)
% %     xlabel('interval following SB [sec]')
% %     ylabel('SB length [sec]')
% %     axis square
% %     title({[num2str(datname)];['following interval and Superburst']});
% % 
% % 
% %     subplot(2,1,2)
% %     plot(NB_intervals(SB_NB_first-1)./mean_nb_int,SB_length,'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2)
% %     xlabel('interval preceding SB [sec]')
% %     ylabel('SB length [sec]')
% %     axis square
% %     title({[num2str(datname)];['preceding interval and Superburst']})
% 
%     ALL_NB_INT_SB{jj,1} = NB_intervals(SB_NB_first-1);
%     ALL_NB_INT_SB{jj,2} = SB_length;
%     ALL_NB_INT_SB{jj,3} = NB_intervals(SB_NB_last);
%     ALL_NB_INT_SB{jj,4} = mean_nb_int;
%     ALL_NB_INT_SB{jj,5} = mean_SB_length;
    ALL_SB_struct(jj).Superbursts = Superburst_analysis.Superburst
    
end%of all datasets




screen_size_fig();
subplot(2,1,1)
for kk=1:11
    plot(ALL_NB_INT_SB{kk,3}./ALL_NB_INT_SB{kk,4},ALL_NB_INT_SB{kk,2}./ALL_NB_INT_SB{kk,5},'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2);
    hold on
end
axis square
xlabel('rel. interval following SB [norm. to mean]')
ylabel('rel. SB length [norm. to mean]')

subplot(2,1,2)
for kk=1:11
    plot(ALL_NB_INT_SB{kk,1}./ALL_NB_INT_SB{kk,4},ALL_NB_INT_SB{kk,2}./ALL_NB_INT_SB{kk,5},'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2);
    hold on
end
xlabel('rel. interval preceding SB [norm. to mean]')
ylabel('rel. SB length [norm. to mean]')
axis square







screen_size_fig()
Nr_Datasets           = size(ALL_SB_struct,2);
ALL_subburst_diff_vec = [];
for ii=1:Nr_Datasets
    NR_SB = size(ALL_SB_struct(ii).Superbursts);
    for jj=1:NR_SB
        nr_subburst = sum(cellfun(@(x) ~isempty(x),ALL_SB_struct(ii).Superbursts(jj,:)));
        for kk=1:nr_subburst
            %gives the subburst length
            SB_cell{ii}{jj}(kk) = ALL_SB_struct(ii).Superbursts{jj,kk}(2) - ALL_SB_struct(ii).Superbursts{jj,kk}(1);
        end
        if nr_subburst>1
            x_vec = SB_cell{ii}{jj}(1:nr_subburst-1);
            y_vec = SB_cell{ii}{jj}(2:nr_subburst);
            plot(x_vec,y_vec,'o','Markerfacecolor','b','Markeredgecolor','b','Markersize',2);
            ALL_subburst_diff_vec  = [ALL_subburst_diff_vec; [x_vec - y_vec]'];
            hold on;
        end
    end
end

line_h = line([0 18],[0 18])
set(line_h,'Color','r','linewidth',2)




