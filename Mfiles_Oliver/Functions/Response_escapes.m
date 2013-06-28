% %in the paper Eytan et al, J. Neurosci 2003,'selective adaptation...',
% they talk in figure5 about 'escapes' in the (network) responsiveness (see paper and notes there.
% I assume these escapes are due to superbursts. This assumption is supported by the fact that they observe it for small IstimIs,but not for large ones.
% Replicate theit analysis and see if I get similar escapes. But if this is the case in superburst datasets, I know where they come from
%work on a Superbursting dataset, that has preferntially varying IstimIs,
%as well as also very short IstimIs. The dataset
%04_09_07_760_stim_in_silence_test_run can be a good example. 
%Dataset 04_09_07_760;
%First actual stimulu scomes at 3674 sec (trial 1284)


%
%function Response_escapes(datname,ls)
% 
% INPUT:
% datname:              the name of the dataset
% 
% 
% stim_times            the stimulation time points, they should be the same as used for the calculation in nr_spikes
% 
% nr_spikes:            A return value of StimulusEffect, this gives the nr of elicited spikes after stimulation, for each channel separatly.
%                      I calculate the Network response as the sum over all channels
% 
% 
% 
% 
% 
% 
% 
% 
function Response_escapes(datname,ls,StimRaster_Sparse_per1,StimRaster_Sparse_per2,nr_spikes_per1,nr_spikes_per2)



%calculate the nr of reponse spikes by means of the Stim raster Sparse
%function
%minimize the dataset:
%%Comment out different cells if running the file with data tthat is loaded
%%in the workspace already

%ls                            = get_shrinked_ls(ls,0,7);



%get all stimulaton trials
stim_times_all = ls.time(find(ls.channel==61));

%get the trials of stimulation
%only conside a specific nr of trials
Nr_trials                     = 500;
stim_times                    = stim_times_all(1284:1284+Nr_trials-1);
%Remove artifacts
%ls = Remove_artifact(ls,hw2cr([0:60]),stim_times,0,7);


PRE_STIM  = 0;
POST_STIM = 1
%[StimRaster_Sparse_per1 nr_spikes_per1] = StimulusEffect_SPARSE(datname,ls,PRE_STIM,POST_STIM,stim_times,0);



StimRaster_Sparse = StimRaster_Sparse_per1
nr_spikes         = nr_spikes_per1;



%define first of all artificial stim points, then create the real ones by
%looking at the actual stimlation times;

Stim_start = stim_times(1);
Stim_end   = stim_times(end);

Stim_intervals    = [3 50]; %this is in seconds
Nr_diff_intervals = length(Stim_intervals);

for ii=1:Nr_diff_intervals
    stim_series_opt{ii} = Stim_start:Stim_intervals(ii):Stim_end;
end
%the cell vector stim_series_opt defines for the different stim intervals, the
%optimal case of stim series

%for each stimseries, find an experimental counterpart that matches it
%nicely.
stim_series_exp =cell(2,Nr_diff_intervals);
for ii=1:Nr_diff_intervals
    %look at each (defined) stim times
    for jj=1:length(stim_series_opt{ii})
        %find the index in stim_times that has the smallest distsnce to the
        %optimal stim time
        diff_vec     = stim_times - stim_series_opt{ii}(jj);
        stim_ind(jj) = find(abs(diff_vec) == min(abs(diff_vec)));
        if (jj>1 & stim_ind(jj-1) ==stim_ind(jj))
            continue
        else
            stim_series_exp{1,ii} = [stim_series_exp{1,ii}  stim_times(stim_ind(jj))];
            stim_series_exp{2,ii} = [stim_series_exp{2,ii}  stim_ind(jj)];
        end
    end
    IstimI_exp{ii}      = diff(stim_series_exp{1,ii});
end

%for information purposes, plot the experimentally deriveds IstimI
%distribution
screen_size_fig;

for ii=1:Nr_diff_intervals
    subplot(Nr_diff_intervals,1,ii);
    start_bin = Stim_intervals(ii) - Stim_intervals(ii)/2;
    end_bin   = Stim_intervals(ii) + Stim_intervals(ii)/2;
    bar(start_bin:0.2:end_bin,histc(IstimI_exp{ii},start_bin:0.2:end_bin));
    title(['Experimentally derived IstimI distribution for (optimal) IstimI = ', num2str(Stim_intervals(ii)),' sec']);
    xlabel('times [sec]');
    ylabel('counts')
end



%define the 'network response'as the sum of the nr of elicited spikes for
%ALL channels
Netw_resp = sum(nr_spikes);

%define a smoothing kernel, as a rectangular window, as in the Eytan paper,
%over 5 'trials'
Rect_width       = 5;
averaging_kernel = 1/Rect_width*rectwin(Rect_width);

%make the calculation of the (average) Network response for the different
%choSosen stimulation trials with differnt IstimI. The avergae is however
%always over 5 consecutive IstimIs

for ii=1:Nr_diff_intervals
    
    Avg_exp_Netw_resp{ii} = conv(averaging_kernel,Netw_resp(stim_series_exp{2,ii}));
    rm_ind = [1:floor(Rect_width/2) length(Avg_exp_Netw_resp{ii})-floor(Rect_width/2)+1:length(Avg_exp_Netw_resp{ii})];
    Avg_exp_Netw_resp{ii}(rm_ind)=[];
end
%the convolution adds indices at the beginning and end, remove them


%define the trial numbr where from the network response is plotted, the
%temporal extend etc
Trial_start = 131;
Time_window = 600; %in sec;


%plot the result, with respective timeaxis
screen_size_fig;
Markersign{1} = '-';
Markersign{2} = '--';

sub_h  = subplot(Nr_diff_intervals,1,1);
%set a new axes position, make it smaller
curr_pos = get(gca,'Position')
set(sub_h,'Position',[curr_pos(1) curr_pos(2) 0.35 0.25]);


for ii=1:Nr_diff_intervals
    %the respective stim time for the according istimi distribution
    norm_ind   = find(stim_series_exp{2,ii}==Trial_start);
    if isempty(norm_ind)
        diff_vec = stim_series_exp{2,ii} - Trial_start;
        norm_ind = find(abs(diff_vec) ==min(abs(diff_vec)));
        norm_ind = norm_ind(1);
    end
    nr_points  = length(Avg_exp_Netw_resp{ii});

    plot_h(ii) = plot(stim_series_exp{1,ii}(1:nr_points)-stim_times(Trial_start),Avg_exp_Netw_resp{ii}./Avg_exp_Netw_resp{ii}(norm_ind),Markersign{ii},'LineWidth', 2,'Color','r')
    hold on;
    xlim([0 Time_window]);
    ylim([0 2.5]);
end
 set(gca,'Xtick',[]);
%make a legend
legend_h = legend({'1/5 Hz'; '1/50 Hz'});
set(legend_h,'Box','off');
set(gca,'Fontsize',14);
y_ticks      = [0 0.5 1 1.5];
y_tick_label = num2str(y_ticks');
set(gca,'Ytick',y_ticks','YTickLabel',y_tick_label);


%make an inlet axes showing the rate profile over the time of
%responsiveness calculation
paren_ax_pos      = get(gca,'Position');
inlet_axes_x      = paren_ax_pos(1);
inlet_axes_y      = paren_ax_pos(2)+(1-0.3)*paren_ax_pos(4);
inlet_axes_width  = (1/3)*paren_ax_pos(3);
inlet_axes_height = 0.3*paren_ax_pos(4);
inlet_ax_pos = [inlet_axes_x inlet_axes_y inlet_axes_width inlet_axes_height];

inlet_ax_h(1) = axes('position',inlet_ax_pos);

%calculate the array rate during the time of the responsiveness plot;
start_array = (stim_times(Trial_start) - Time_window/2)/3600;
end_array   = (stim_times(Trial_start) + 1.5*Time_window)/3600;
[bin_vec array_rate] = Superburst_array_rate(ls,start_array, end_array);
close(gcf);
axes(inlet_ax_h(1));
bar_h(1) = bar(bin_vec - stim_times(Trial_start),array_rate,'k');
hold on;
ind_start = find(abs(bin_vec - stim_times(Trial_start)) == min(abs(bin_vec - stim_times(Trial_start))));
ind_end   = find(abs(bin_vec - (stim_times(Trial_start)+Time_window)) == min(abs(bin_vec - (stim_times(Trial_start)+Time_window))));
bar_h(2) = bar(bin_vec(ind_start:ind_end) - stim_times(Trial_start),array_rate(ind_start:ind_end),'Facecolor','r','Edgecolor','r');
xlim([-Time_window/2 1.5*Time_window]);
ylabel('rate [Hz]');
xlabel('time [sec]');
set(inlet_ax_h(1),'YaxisLocation','right');
y_ticks = [0 100 ];
y_tick_label = num2str(y_ticks');
set(gca,'Ytick',y_ticks','YTickLabel',y_tick_label);








%%*******************
%%Do the same thing for a non-Superbursting period. This occurred in the
%%same dataset in the second stim period. A good period to show this is e.g
%%the time around 22816 sec, hr 6.3, where there are superburst free
%%periods, trial no 6429
Nr_trials                     = 500;
stim_times                    = stim_times_all(6450:6450+Nr_trials-1);

%%****
%%A copy of the code above


        %Remove artifacts
        %ls = Remove_artifact(ls,hw2cr([0:60]),stim_times,0,7);


        PRE_STIM  = 0;
        POST_STIM = 1
        %[StimRaster_Sparse_per2 nr_spikes_per2] = StimulusEffect_SPARSE(datname,ls,PRE_STIM,POST_STIM,stim_times,0);
        

        StimRaster_Sparse = StimRaster_Sparse_per2
        nr_spikes         = nr_spikes_per2;
        %define first of all artificial stim points, then create the real ones by
        %looking at the actual stimlation times;

        Stim_start = stim_times(1);
        Stim_end   = stim_times(end);

        %because this is a non-SB network, but with stim_in_silence, I
        %adjust the lowere calculated stim frequency. The derived IstimI
        %distribution matches the expected one with mean IstimI 5 sec
        Stim_intervals    = [4.5 50]; %this is in seconds
        Nr_diff_intervals = length(Stim_intervals);

        for ii=1:Nr_diff_intervals
            stim_series_opt{ii} = Stim_start:Stim_intervals(ii):Stim_end;
        end
        %the cell vector stim_series_opt defines for the different stim intervals, the
        %optimal case of stim series

        %for each stimseries, find an experimental counterpart that matches it
        %nicely.
        stim_series_exp =cell(2,Nr_diff_intervals);
        for ii=1:Nr_diff_intervals
            %look at each (defined) stim times
            for jj=1:length(stim_series_opt{ii})
                %find the index in stim_times that has the smallest distsnce to the
                %optimal stim time
                diff_vec     = stim_times - stim_series_opt{ii}(jj);
                stim_ind(jj) = find(abs(diff_vec) == min(abs(diff_vec)));
                if (jj>1 & stim_ind(jj-1) ==stim_ind(jj))
                    continue
                else
                    stim_series_exp{1,ii} = [stim_series_exp{1,ii}  stim_times(stim_ind(jj))];
                    stim_series_exp{2,ii} = [stim_series_exp{2,ii}  stim_ind(jj)];
                end
            end
            IstimI_exp{ii}      = diff(stim_series_exp{1,ii});
        end

        
        %define the 'network response'as the sum of the nr of elicited spikes for
        %ALL channels
        Netw_resp = sum(nr_spikes);

        %define a smoothing kernel, as a rectangular window, as in the Eytan paper,
        %over 5 'trials'
        Rect_width       = 5;
        averaging_kernel = 1/Rect_width*rectwin(Rect_width);

        %make the calculation of the (average) Network response for the different
        %choSosen stimulation trials with differnt IstimI. The avergae is however
        %always over 5 consecutive IstimIs

        for ii=1:Nr_diff_intervals

        Avg_exp_Netw_resp{ii} = conv(averaging_kernel,Netw_resp(stim_series_exp{2,ii}));
        rm_ind = [1:floor(Rect_width/2) length(Avg_exp_Netw_resp{ii})-floor(Rect_width/2)+1:length(Avg_exp_Netw_resp{ii})];
        Avg_exp_Netw_resp{ii}(rm_ind)=[];
        end
        %the convolution adds indices at the beginning and end, remove them


        %define the trial numbr where from the network response is plotted, the
        %temporal extend etc
        Trial_start = 93;
        Time_window = 600; %in sec;


        %plot the result, with respective timeaxis
        sub_h  = subplot(Nr_diff_intervals,1,2);
        curr_pos = get(gca,'Position')
        set(sub_h,'Position',[0.13 0.28 0.35 0.25]);

        for ii=1:Nr_diff_intervals
        %the respective stim time for the according istimi distribution
        norm_ind   = find(stim_series_exp{2,ii}==Trial_start);
        if isempty(norm_ind)
            diff_vec = stim_series_exp{2,ii} - Trial_start;
            norm_ind = find(abs(diff_vec) ==min(abs(diff_vec)));
            norm_ind = norm_ind(1);
        end
        nr_points  = length(Avg_exp_Netw_resp{ii});

        plot(stim_series_exp{1,ii}(1:nr_points)-stim_times(Trial_start),Avg_exp_Netw_resp{ii}./Avg_exp_Netw_resp{ii}(norm_ind),Markersign{ii},'LineWidth', 2,'Color',[0 0.5 0])
        hold on;
        xlim([0 Time_window]);
        ylim([0 2.5]);
        end
        xlabel('time [sec]','Fontsize',20)
        ylabel('change in network responsiveness','Fontsize',20);
        %make a legend
        legend_h = legend({'1/5 Hz'; '1/50 Hz'});
        set(legend_h,'Box','off');
        set(gca,'Fontsize',14);
        y_ticks      = [0 0.5 1 1.5];
        y_tick_label = num2str(y_ticks');
        set(gca,'Ytick',y_ticks','YTickLabel',y_tick_label);

        
        %make an inlet axes showing the rate profile over the time of
        %responsiveness calculation
        paren_ax_pos      = get(gca,'Position' );
        inlet_axes_x      = paren_ax_pos(1);
        inlet_axes_y      = paren_ax_pos(2)+(1-0.3)*paren_ax_pos(4);
        inlet_axes_width  = (1/3)*paren_ax_pos(3);
        inlet_axes_height = 0.3*paren_ax_pos(4);
        inlet_ax_pos = [inlet_axes_x inlet_axes_y inlet_axes_width inlet_axes_height];

        inlet_ax_h(2) = axes('position',inlet_ax_pos);

        %calculate the array rate during the time of the responsiveness plot;
        start_array = (stim_times(Trial_start) - Time_window/2)/3600;
        end_array   = (stim_times(Trial_start) + 1.5*Time_window)/3600;
        [bin_vec array_rate] = Superburst_array_rate(ls,start_array, end_array);
        close(gcf);
        axes(inlet_ax_h(2));
        bar_h(1) = bar(bin_vec - stim_times(Trial_start),array_rate,'k');
        hold on;
        ind_start = find(abs(bin_vec - stim_times(Trial_start)) == min(abs(bin_vec - stim_times(Trial_start))));
        ind_end   = find(abs(bin_vec - (stim_times(Trial_start)+Time_window)) == min(abs(bin_vec - (stim_times(Trial_start)+Time_window))));
        bar_h(2) = bar(bin_vec(ind_start:ind_end) - stim_times(Trial_start),array_rate(ind_start:ind_end),'Facecolor',[0 0.5 0],'Edgecolor',[0 0.5 0]);
        xlim([-Time_window/2 1.5*Time_window]);
        ylabel('rate [Hz]');
        xlabel('time [sec]');
        set(inlet_ax_h(2),'YaxisLocation','right')
        y_ticks = [0  100];
        y_tick_label = num2str(y_ticks');
        set(gca,'Ytick',y_ticks','YTickLabel',y_tick_label);




%%%Set the same axis of the inlet plots

set_maximum_axlimits(inlet_ax_h,'y')




%save the whole workspace
curr_path      = cd;
save_path      = 'C:\Program Files\MATLAB71\work';
save_file_name = 'Response_escapes.mat';
cd(save_path);
save(save_file_name);
cd(curr_path);



