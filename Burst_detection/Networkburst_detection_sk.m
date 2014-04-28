
%The Network burst detection was transfered to a function, the algorithm is
%the same
%
%[bursting_channels_mea network_burst network_burst_onset] = Networkburst_detection(datname,ls,burst_detection,nr_bursting_ch)
%
%
%input:
% datname:                       the filenam
% 
% 
% ls:                            the usual list with the file information
% 
% 
% burst_detection                the cell array with the detected bursts
%                                and the relevant onformation
% 
% 
% 
% nr_bursting_ch                 defines how many channels are considered
%                                for the NB detection
% 
% 
% 
% 
% 
% 
% 
% output
%
%bursting_channels_mea          The channels that have the most bursts and
%                               for which the calculation are made
%
%
% 
%network_burst                 the cell array, with information for each
%                              network burst
%
% 
% 
%
%
%network_burst_onset           Stores the absolute onset times for each NB
%                              (column 2)
%                              and the respective channel (column 1)
%
%




function [bursting_channels_mea, network_burst, network_burst_onset, network_burst_ends] = Networkburst_detection_sk(datname,ls,burst_detection,nr_bursting_ch,varargin)


%set some variables that define a networkburst
 MIN_DELAY       = 0.075;         %is in sec
 MIN_DELAY_EXTRA = 0.15;           %ther may be one interval that is larger  than MIN_DELAY, but smaller than this value
 MIN_NO_ELEC     = 3;             %how many electrodes should at least be affected
 
if nargin>4
    nr_inputs = nargin;
    switch nr_inputs
        case 5
            MIN_DELAY        = varargin{1}
        case 6
            MIN_DELAY        = varargin{1}
            MIN_DELAY_EXTRA  = varargin{2}
        case 7
            MIN_DELAY        = varargin{1}
            MIN_DELAY_EXTRA  = varargin{2}
            MIN_NO_ELEC      = varargin{3}
    end
end


[bursting_channels_mea nr_bursts] = get_bursting_ch(burst_detection,nr_bursting_ch);
nr_bursting_ch                    = length(bursting_channels_mea);

bursting_channels                 = cr2hw(bursting_channels_mea)+1;
no_bursting_ch                    = length(bursting_channels);


%find the burst onsets
burst_onset=cell(1,no_bursting_ch);
for j =1:no_bursting_ch
    active_ch=bursting_channels(j);
    for k = 1:size([burst_detection{1,active_ch}],1 )
        burst_onset{1,j}{k,1} = burst_detection{1,active_ch}{k,3}(1);   %this is the burst onset for channel j, burst k
    end
end


%sort the burst onsets according to the time of appearance. first construct
%a vector with burst_onset time in column 1 and channel in column2, then
%sort this vector with sort
burst_onset_sort=[];
for j =1:no_bursting_ch
        active_ch         = bursting_channels(j);
        
        onset_sort(:,1)   = [burst_onset{1,j}{:,1}]';
        onset_sort(:,2)   = active_ch.*ones(length([burst_onset{1,j}]),1);  %BE CAREFUL, THIS CHANNEL NUMBERING IS HW CHANNEL +1
        onset_sort(:,3)   = 1:length([burst_onset{1,j}]);                    % this are just the number of appearance, important for later indexing                
        burst_onset_sort  = cat(1,burst_onset_sort, onset_sort);
        clear onset_sort;
end

%now re sort the onset times and also the channels in the 2nd column,
%this procedure was used previously, the 3rd column gives the burst number
%at the respective channel
[burst_onset_resort, sort_ind] = sort(burst_onset_sort,1,'ascend');
 burst_onset_resort(:,2)       = burst_onset_sort(sort_ind(:,1),2);
 burst_onset_resort(:,3)       = burst_onset_sort(sort_ind(:,1),3);

 burst_onset_sort=burst_onset_resort;
 clear burst_onset_resort;
 
 total_num_bursts  = length(burst_onset_sort);
 inter_burst_int   = zeros(total_num_bursts-1,2);
 for i = 1:total_num_bursts-1
     inter_burst_int(i,1)   = burst_onset_sort(i+1,1)-burst_onset_sort(i,1);
     inter_burst_int(i,2)   = burst_onset_sort(i,2);                            %the respective channel where the burst occurs
 end
 
 
 
 
 %indices are the indices in inter_burst_int, successive numbers indicate
 %successive burst (on diff. electrodes) with the given min_delay. E.g. 2
 %successive indices mean 3 successive bursts that have a delay smaller
 %than MIN_DELAY each, and where there may be even one interval larger than MIN_DELAY but smaller than MIN_DELAY_EXTRA
 
 
 indices_normal        = find(inter_burst_int(:,1)<MIN_DELAY);
 indices_extra         = find(inter_burst_int(:,1)<MIN_DELAY_EXTRA);
 %the set of different indices:
 setdiff_indices       = setdiff(indices_extra, indices_normal);
 %find those indices that are interspaced by only one index, i.e where
 %there are two inter_burst_int larger than MIN_DELAY, but smaller than
 %MIN_DELAY_EXTRA
 setdiff_indices_one_interspaced                  = find(diff(setdiff_indices)==1);
 %delete those indices
 setdiff_indices(setdiff_indices_one_interspaced) = [];
 %combine the found indices
 indices  = [indices_normal;setdiff_indices];
 indices  = sort(indices);

 
 k=1;
 no_network_bursts=0;
 network_burst=cell(1,5);
 while k < length(indices)-(MIN_NO_ELEC-2);
     if indices(k+MIN_NO_ELEC-2)-indices(k) == MIN_NO_ELEC-2  %if indices are interspaced by 1
         
         %mak the additionallast check if the beginning of this detected nb
         %is larger than the end of the last nb
           if no_network_bursts>1 &  burst_onset_sort(indices(k),1) < max(network_burst{no_network_bursts,5}) 
               %jump on to the next index check, don;t count this
               %"detected"nb as a real nb
               k=k+1;
               continue
           end
             %network burst start detected at index k
             no_network_bursts=no_network_bursts+1;
             last_index=k+MIN_NO_ELEC-2;
             while (indices(last_index+1)-indices(last_index) == 1 & last_index<length(indices)-1 )    %if the next indices are also interspaced by one
                 last_index=last_index+1;
             end
             %after this while loop, the index for the end of the burst is
             %last_index, the start for the next search is last_index+1, i.e.
             %set k=last_index for 1 before the end of the if loop
             %write some information
             network_burst{no_network_bursts,1} = burst_onset_sort(indices(k):indices(last_index)+1,2);  %this gives the involved channels, add 1 because now we are taking the index in burst_onset_sort, which gives absolute values rather than interval values
             network_burst{no_network_bursts,2} = burst_onset_sort(indices(k):indices(last_index)+1,1);  % this are the onset times for each channel
             network_burst{no_network_bursts,3} = inter_burst_int(indices(k:last_index),1);               %this gives the intervals between the diff. burts  onsets, of course this is one entry less than the others
             network_burst{no_network_bursts,4} = burst_onset_sort(indices(k):indices(last_index)+1,3);  % this give the burstnumber on each involved channel, can be used for later indexing

            nb_channels          = network_burst{no_network_bursts,1};                                   %this are the channels that compose the network burst
            nb_channels_burst_nr = network_burst{no_network_bursts,4};  %this are the burst nrs for indexing in burst detection for each cahnnel
            nb_end_times=zeros(1,length(nb_channels));
            for jj=1:length(nb_channels)
            nb_end_times(jj)     = burst_detection{1,nb_channels(jj)}{nb_channels_burst_nr(jj),3}(end);
            end
            network_burst{no_network_bursts,5} = nb_end_times';            %this gives the end times of the individual bursts that constitute the nb 
            

             k=last_index+1;  %go on by checking the next index

         else
             k=k+1;
     end
 end
 
 
 
 
 
 
 
 %%%%%%%
 %For plotting some results
 
 
network_burst_onset    = zeros(no_network_bursts-1,2);
network_burst_ends     = zeros(no_network_bursts-1,1);
inter_netw_burst_int   = zeros(1,no_network_bursts-1);
inter_netw_burst_gap   = zeros(1,no_network_bursts-1);

 for i=1:size(network_burst,1)-1 % changed length() to size([],1)
     network_burst_onset(i,1) =  network_burst{i,1}(1);                %the  channel that starts in the networkburst
     network_burst_onset(i,2) =  network_burst{i,2}(1);                % the time when the netwburst starts
    
     inter_netw_burst_int(i)  =  (network_burst{i+1,2}(1) - network_burst{i,2}(1));  %give this in seconds, the interval from the beginning to the end
     which_channel_ends       =  network_burst{i,1}(end);
     which_burst_nr_ends      =  network_burst{i,4}(end);
     network_burst_ends(i,1)  =  max(network_burst{i,5});            %the end time of the network burst
     inter_netw_burst_gap(i)  =  network_burst{i+1,2}(1) - burst_detection{1,which_channel_ends}{which_burst_nr_ends,3}(end); 
 end
%  %plot a histogram of the network burst interval distribution
%  inter_netwburst_int_fig=figure;
%  netw_burst_hist=hist(inter_netw_burst_int,0:1:max(inter_netw_burst_int));
%  bar(0:1:max(inter_netw_burst_int), netw_burst_hist);
%  title({['dataset: ',datname,', recording length: ',num2str(recording_length_hrs),', start at ',num2str(starttime_hrs) ' hrs'];...
%         ['Distribution of Inter_network_burst intervals'];[' total of ', num2str(length([network_burst])),' network bursts']},'FontSize',12,'Interpreter','none');
%     xlabel(['Inter Network Burst Interval [sec]'],'Fontsize',12);
%     ylabel(['occurrences'], 'Fontsize',12);



%plot a figure with some raster but also some lines indicating network
%burst onset

% %raster_nb_onset_figure=screen_size_fig();
% raster_nb_onset_figure=figure();
% subplot(3,1,2:3)
% %set(gcf,'Renderer','OpenGL');
% start_plot    =  ls.time(1);
% %end_plot      =  start_plot+5400;
% end_plot = ls.time(end);
% sequence_ind  = find(ls.time>=start_plot & ls.time<=end_plot);
% plot(ls.time(sequence_ind),ls.channel(sequence_ind)+1,'ok','markersize',2,'markerfacecolor','k');
% 
% nb_onset_ind      = find(network_burst_onset(:,2) > start_plot & network_burst_onset(:,2) < end_plot);
% nb_end_ind        = find(network_burst_ends(:,1) > start_plot & network_burst_ends(:,1) < end_plot);
% 
% %onset times of NB in the plot
% nb_onset_marker_times  = network_burst_onset(nb_onset_ind,2);
% nb_onset_marker_lines  = line([nb_onset_marker_times' ; nb_onset_marker_times'],[-1 64]);
% %end times of NB in the plot
% nb_end_marker_times  = network_burst_ends(nb_end_ind,1);
% nb_end_marker_lines  = line([nb_end_marker_times' ; nb_end_marker_times'],[-1 64]);
% 
% %set the markers in different color
%  set(nb_onset_marker_lines(:),'Color','r');
%  set(nb_end_marker_lines(:),'Color','b');
% 
% %  Xcoords = [nb_onset_marker_times';nb_onset_marker_times';nb_end_marker_times';nb_end_marker_times'];
% %  Ycoords = 60*repmat([0;1;1;0],size(nb_onset_marker_times'));
% %  patch(Xcoords,Ycoords, 'r', 'EdgeColor','none', 'FaceAlpha',0.2);
% 
% ylim([0 61]);
% xlim([start_plot end_plot]);
% set(gca,'TickDir','Out');
% xlabel('time [sec]');
% ylabel('(hw) electrode');
% title({['datname: ', num2str(datname)];['raster plot and detected network bursts (red lines indicating onsets)'];...
%     ['Shown is an example for ', num2str(end_plot),'s of recording']},'Interpreter', 'none')
