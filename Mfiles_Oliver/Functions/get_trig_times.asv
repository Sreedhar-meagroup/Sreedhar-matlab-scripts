%for spontaneous activity or random stimulation data:
%make an offline rate estimation and a set a threshold to have similar
%trigger conditions as in the experiment with the single-trial rate
%estimation
%
%
%function [trigger_times trigger_vals]=get_trig_times(ls, trig_ch, start_time, end_time,thresh, min_separate);
%input:
% ls:                     usual list with spike information
% 
% trig_ch:                for which channel to calculate the rate and
%                         detect a threshold crossing, in MEA coord.
%     
% start_time, end_time:   start and end when to search for triggers (in hrs)
% 
% thresh:                 rate threshold when to detect a trigger (in Hz)
%
%min_separate:            minimum separation between two triggers, in sec


function [trigger_times trigger_vals]=get_trig_times(ls, trig_ch, start_time, end_time,thresh, min_separate);


%define the kernel function, the final kernel width is of course dependent
%on the sampling of the spike train, which will be 1 ms.
kernel_sigma  = 40;
kernel_width  = 2*sqrt(6)*kernel_sigma;
kernel_fct    = 2/(kernel_width)*triang(kernel_width);


hw_ch            = cr2hw(trig_ch);
ch_nrs           = length(hw_ch);

trigger_times=cell(1,ch_nrs);

for ch=1:ch_nrs
    spike_times_ch   = ls.time(find(ls.channel==hw_ch(ch) & ls.time>start_time*3600 & ls.time<end_time*3600));
    thresh_cross     = [];


    %sample the spike train
    sample_step   = 0.001;
    time_vec      = (start_time*3600):sample_step:(end_time*3600);
    spike_tr      = hist(spike_times_ch,time_vec);
    est_rate      = conv(spike_tr,kernel_fct);

    %to get an estimated rate in Hz
    est_rate      = est_rate/sample_step;

    %define the "differential"
    diff_rate     = diff(est_rate);


    %find those times that are above the threshold and have positive steepness
    high_val_ind=find(est_rate(1:end-1)>thresh & diff_rate>0);



    thresh_cross(1)   = high_val_ind(1);
    act_ind           = high_val_ind(1);
    nr_cross          = 1;

    %check the condition that each trigger should minimally separated by a
    %given time
    for jj=2:length(high_val_ind)
        act_separate=high_val_ind(jj)-act_ind;
        if act_separate > min_separate/sample_step
            nr_cross                =  nr_cross+1;
            act_ind                 = high_val_ind(jj);
            %thresh_cross(nr_cross)  = act_ind;
            thresh_cross(nr_cross,1)        = act_ind;
            thresh_cross(nr_cross,2)        = est_rate(act_ind);
        end
    end    

    %calculate the difference between the indices
    diff_ind=high_val_ind(find(diff(high_val_ind)>1)+1);



    %the vector thresh_cross holds the crossings of the condition, in
    %samplestep


    %trigger_times{ch} = thresh_cross*sample_step;
    trigger_times{ch} = thresh_cross(:,1)*sample_step;
    trigger_vals{ch}  = thresh_cross(:,2);
    %take care of different start times of calculation
    trigger_times{ch} = trigger_times{ch}+start_time*3600; 
end



%make a small plot of the result
plot_end = thresh_cross(10); 
figure;
plot([1:plot_end]*sample_step,est_rate(1:plot_end));
hold on;
line([thresh_cross(1:10)' thresh_cross(1:10)']*sample_step, [0 max(est_rate)]); 

title({['plotting the estimated rate and the first 10 detected threshold crossings for channel ', num2str(trig_ch(end))];...
     ['rate thresh =', num2str(thresh),' [Hz], kernel sigma = ',num2str(kernel_sigma*sample_step*1000) ' msec']});   
xlabel('time [sec]');
ylabel('rate [Hz]')






