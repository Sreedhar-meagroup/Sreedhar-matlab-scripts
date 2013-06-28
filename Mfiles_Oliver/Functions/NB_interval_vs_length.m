

Spont_act_datasets(1).name   =  '010906_228.spike';  %Superbursting
Spont_act_datasets(2).name   =  '010906_229.spike';  %Superbursting, only 0.4 hrs
Spont_act_datasets(3).name   =  '040906_228.spike';  %Superbursting
Spont_act_datasets(4).name   =  '17_11_06_335.spike';  %partly Superbursting, with short Superbursts, Note that the whole recording is >70 hrs
Spont_act_datasets(5).name   =  '28_11_06_331_feedbackstim.spike';  %this is a control recording
Spont_act_datasets(6).name   =  '08_01_07_400_fbonburst_fakestim.spike';  %Superbursting, and very long, >14 hrs.
Spont_act_datasets(7).name   =  '09_01_07_401_fbonburst_fakestim.spike'   %traditionally Superbursting
Spont_act_datasets(8).name   =  '18_01_07_400_fbonburst_fakestim.spike';  %partly reduced NB detection 
Spont_act_datasets(9).name   =  '19_01_07_400_fbonburst_fakestim.spike'  %Superbursting 
Spont_act_datasets(10).name   = '28_06_07_674_NetwResp.spike';  %take hr 0-1.5, Superbursts however.
Spont_act_datasets(11).name   = '29_06_07_676_NetwResp.spike';  %take only hr 0-1 of this recording, short bursts, good detection. no SB
Spont_act_datasets(12).name   = '01_08_07_744_spont.spike' ;  %no Superbursts, clear detection
%look at the NB interval distribution. This looks almost bimodal, with many
%short intervals. This might explain why the correlation with NB length is
%with the preceding interval. short intervals in superburst-like periods
%(rel. long bursts at rel. short intervals)
%destroy the correlation that casn be expected with periodic bursting with comparable IBIs (unimodal distribution) 
Spont_act_datasets(13).name   = '01_08_07_745_spont.spike' ;  %no SB, quite good detection of NBs
Spont_act_datasets(14).name   = '02_08_07_743_spont.spike';   %no SBs, good detection of NBs, bimodal INBI distribution
Spont_act_datasets(15).name   = '06_08_07_742_spont.spike';  
Spont_act_datasets(16).name   = '21_08_07_764_spont.spike';  %some short and long-intervals. Not really unimodal NB interval distribution. If those intervals are removed (and acc. NBs), the correlation with the preceding interval is lost
Spont_act_datasets(17).name   = '23_08_07_775_spont.spike'; %no SB, good NB detection
%A somewhat strange type of activity. There is one chanel that fires almost
%persistently. It starts firing somewhere inbetween the NB and continues
%until the start of the NB, where it also participates. After the NB, it
%quickly stops until it starts firing again. The NB periodicity/structure
%is unclear in this dataset. Furthermore, there is a period with and
%without Superbursts
Spont_act_datasets(18).name   = '24_08_07_767_spont.spike';
Spont_act_datasets(19).name   = '28_08_07_760_spont.spike';  %AS Superbursting as it gets!
Spont_act_datasets(20).name   = '02_10_07_918_spont.spike';  %Very short NBs, almost unimodal length distribution
Spont_act_datasets(20).name   = '02_10_07_920_spont.spike' ; %Very short NBs, at small intervals. Almost unimodal NB length distribution. Somehwat short- and longer intervals
Spont_act_datasets(21).name   = '08_10_07_918_spont.spike'; %Still vwey short NBs, at relatively small intervals. Interval distribution almost unimodal, no SBs. Some short- and long intervals.
%This is a very good example how the preceding interval correlates with NB
%length. Correlation is as high as 0.5 and drops for other intervals. NB
%interval distribution is log-normal like. NB length distr is amost bimodal
Spont_act_datasets(22).name   = '27_10_07_923_spont.spike';
%A very good example how SB influcne the correlation measure. The maximum
%correlation is aeen at the -6th and -7th interval!. Because, herer, Superbursts
%consist of a very long burst followed by 7-8 other bursts and a long
%interval afterwards. By that, the shift after the 7th interval leads to
%high correlations. NB length distributions is almost bimodal with many short intervals. NB length distribution has many short bursts but also a wide dispersion of long bursts. 
Spont_act_datasets(23).name   = '31_10_07_921_spont.spike';
%Again a typical example. Taking periods with Superbursts results in a max
%correlation at lag -6 to -8 (compare to upper dataset with same culture).
%If I take period without Superbursts (hr. 07 - 1.1), this results in a max. correlation
%at lag +1, i.e the preceding interval. Why is that?
Spont_act_datasets(24).name   = '07_11_07_921_spont.spike'






%no of datasets, for looping
No_spont_data = length(Spont_act_datasets);


%define burst criterion a priori
BURST_MAX_INTERVAL_LENGTH = 0.1;
BURST_MAX_BURST_INT       = 0.2;
BURST_MIN_NO_SPIKES       = 3;

%NB criteria
MIN_DELAY                         = 0.1;
MIN_DELAY_EXTRA                   = 0.2
MIN_NO_ELEC                       = 3
NO_CH                             = 60   %take the maximum no channels possible

%loop through each dataset, load the data, calculate burst and NBs, define
%NB lengths, intervals etc and make the covariance analysis and plot it.
%Covariances of the sam kind are plotted in the same figure, for different
%datastes. A mean is finally calculated overr all datasets
Cov_fig_h = screen_size_fig();

for ii = 1:No_spont_data
    datname = Spont_act_datasets(ii).name;
    
    %load the data
    if strcmp(datname,'010906_228.spike') | strcmp(datname,'010906_229.spike') | strcmp(datname,'040906_228.spike')
        
        ls = loadspike_noc_shortcutouts(datname,2,25);
        
    else
        ls = loadspike_longcutouts_noc_bigfiles(datname,2,25);
    end
    
    %there are some datasets where I use only a reduced size
    if strcmp(datname,'17_11_06_335.spike');
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'08_01_07_400_fbonburst_fakestim.spike')
        ls = get_shrinked_ls(ls,0,2);
    elseif strcmp(datname,'28_06_07_674_NetwResp.spike');
        ls = get_shrinked_ls(ls,0,1.5);
    elseif strcmp(datname,'29_06_07_676_NetwResp.spike');
        ls = get_shrinked_ls(ls,0,1);
    end
    
    
    %MAKE burst and NB detection
    burst_detection  = burst_detection_all_ch(ls,BURST_MAX_INTERVAL_LENGTH,BURST_MAX_BURST_INT ,BURST_MIN_NO_SPIKES);
    %NB detection
    [b_ch_mea network_burst NB_onset] = Networkburst_detection(datname,ls,burst_detection,NO_CH,MIN_DELAY ,MIN_DELAY_EXTRA,MIN_NO_ELEC);

    %check if the detection was good enough
    %this return the command to command line, settings can be made in the
    %mfile
    keyboard
    
    NB_starts    = cellfun(@(x) x(1),network_burst(:,2));
    NB_ends      = cellfun(@(x) max(x),network_burst(:,5));
    NB_intervals = NB_starts(2:end) - NB_ends(1:end-1);
    NB_lengths   = NB_ends - NB_starts;
    %calculate the no of spikes rather than the length in time
    NB_lengths_spikes     = [];
    NB_rate               = [];
for jj=1:length(NB_lengths);
    NB_lengths_spikes(jj) = length(find(ls.time>=NB_starts(jj) & ls.time<=NB_ends(jj)));
    %also calculate the rate
    NB_rate(jj)           = NB_lengths_spikes(jj)/NB_lengths(jj);
end

%plot the INBI distribution
% screen_size_fig();; 
% subplot(2,2,1)
% bar(0:0.3:max(NB_intervals),hist(NB_intervals,0:0.3:max(NB_intervals)));
% xlabel('NB interval [sec]');
% ylabel('counts'); title({[num2str(datname)];['Network burst interval distribution']})
% 
% subplot(2,2,2)
% bar(0:15:max(NB_rate),hist(NB_rate,0:15:max(NB_rate)));
% xlabel('NB rate [Hz]');
% ylabel('counts'); title({[num2str(datname)];['Network burst rate distribution']})
% 
% subplot(2,2,3)
% bar(0:4:max(NB_lengths_spikes),hist(NB_lengths_spikes,0:4:max(NB_lengths_spikes)));
% xlabel('NB no. spikes');
% ylabel('counts'); title({[num2str(datname)];['Network burst no. of spikes distribution']})
% 
% subplot(2,2,4);
% bar(0:0.05:3,hist(NB_lengths,0:0.05:3));
% xlabel('NB length [sec]');
% ylabel('counts'); title({[num2str(datname)];['Network burst length distribution']})


%Analysis of correlation between network burst length and interval
Bivariat_mat = [NB_lengths(1:end-1) NB_intervals NB_lengths_spikes(1:end-1)' NB_rate(1:end-1)'];
MAX_LAG      = 10;

%calculate the covarianc sequences. The covariance at lag 0 is the
%correlation coefficient
[cov_seq{ii,1} lags] = xcov(Bivariat_mat(:,1),Bivariat_mat(:,2),MAX_LAG,'coeff');
[cov_seq{ii,2} lags] = xcov(Bivariat_mat(:,3),Bivariat_mat(:,2),MAX_LAG,'coeff');
[cov_seq{ii,3} lags] = xcov(Bivariat_mat(:,4),Bivariat_mat(:,2),MAX_LAG,'coeff');

screen_size_fig();
subplot(2,2,1)
cov_seq_h(ii,1)      = plot(lags,cov_seq{ii,1},'Color','r','Linewidth',2)
xlabel('NB interval index')
ylabel('correlation coefficient')
title({[num2str(datname)];['NB length (sec) and interval'];['x-axis index 0 denotes following, +1 preceding interval']})


subplot(2,2,2)
cov_seq_h(ii,2)      = plot(lags,cov_seq{ii,2},'Color','r','Linewidth',2)
xlabel('NB interval index')
ylabel('correlation coefficient')
title({[num2str(datname)];['NB length (no. of spikes) and interval'];['x-axis index 0 denotes following, +1 preceding interval']})
line_h = line([0 0],[min(ylim) max(ylim)],'Color','k','Linestyle','--');

subplot(2,2,3)
cov_seq_h(ii,2)      = plot(lags,cov_seq{ii,3},'Color','r','Linewidth',2)
xlabel('NB interval index')
ylabel('correlation coefficient')
title({[num2str(datname)];['NB rate and interval'];['x-axis index 0 denotes following, +1 preceding interval']})
line_h = line([0 0],[min(ylim) max(ylim)],'Color','k','Linestyle','--');

set_maximum_axlimits(cov_seq_h(ii,:),'y');

for kk=1:3
    axes(cov_seq_h(ii,kk))
    line_h = line([0 0],[min(ylim) max(ylim)],'Color','k','Linestyle','--');
end

end





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




