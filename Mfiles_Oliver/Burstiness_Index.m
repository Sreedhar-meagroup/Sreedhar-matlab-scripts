%CALCULATE  the burstiness index from potter et al for different datasets



datafiles_index{1}=1:8;
datafiles_index{2}=9:23;
datafiles_index{2}=15;
no_datasets(1)=length(datafiles_index{1});
no_datasets(2)=length(datafiles_index{2});
total_datasets=sum(no_datasets);
datasets{1,1}  = {datnames(datafiles_index{1}).name};  %this gives the cell datasets, which stores the filenames to calculate the BI from, these are the ones that have to be loaded withshort cutouts
datasets{1,2}  = {datnames(datafiles_index{2}).name};   %to be loaded with long cutouts
BI=cell(total_datasets,3);




for ds=1:no_datasets(1)
   datasets{1,1}{ds}
   ls=loadspike_noc_shortcutouts(datasets{1,1}{ds},2,25)             % here I need the shortcutouts file
   recording_time=ls.time(end);
   interval_length=60*5;
   no_intervals = ceil(recording_time/interval_length);
   f_fifteen=zeros(1,no_intervals);
    for int_no=1:no_intervals
        start_time=(int_no-1)*interval_length;
        end_time = int_no*interval_length;

        all_spikes_ind  = find(ls.time > start_time & ls.time < end_time & ls.channel<60);   %look in the respective interval and only on the electrode channels
        all_spikes_time = ls.time(all_spikes_ind);
        all_spikes_hist = hist(all_spikes_time,start_time:end_time);
        sorted_all_spikes_hist=sort(all_spikes_hist,'descend');
        f_fifteen_cut=0.15*interval_length;
        f_fifteen(int_no)=sum(sorted_all_spikes_hist(1:f_fifteen_cut))/sum(all_spikes_hist);
        BI{ds,2}(int_no)       = (f_fifteen(int_no)-0.15)/0.85;
        BI{ds,3}(int_no)       = start_time;
    end
    BI{ds,1}               = datasets{1,1}{ds};
   
  
end



for ds=1:no_datasets(2)
    ds_index=datafiles_index{2}(ds)
    datasets{1,2}{ds}
   ls=loadspike_noc_longcutouts(datasets{1,2}{ds},2,25)
   recording_time=ls.time(end);
   interval_length=60*5;
   no_intervals = ceil(recording_time/interval_length);
   f_fifteen=zeros(1,no_intervals);
    for int_no=1:no_intervals
        start_time=(int_no-1)*interval_length;
        end_time = int_no*interval_length;

        all_spikes_ind  = find(ls.time > start_time & ls.time < end_time & ls.channel<60);   %look in the respective interval and only on the electrode channels
        all_spikes_time = ls.time(all_spikes_ind);
        all_spikes_hist = hist(all_spikes_time,start_time:end_time);
        sorted_all_spikes_hist=sort(all_spikes_hist,'descend');
        f_fifteen_cut=0.15*interval_length;
        f_fifteen(int_no)=sum(sorted_all_spikes_hist(1:f_fifteen_cut))/sum(all_spikes_hist);
        BI{ds_index,2}(int_no)       = (f_fifteen(int_no)-0.15)/0.85;
        BI{ds_index,3}(int_no)       = start_time;
    end
    BI{ds_index,1}               = datasets{1,2}{ds};
   
  
end






fig_nr=1;
bifig(fig_nr)=figure;
plot_nrs=1:2;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);

    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index', 'FontSize', 12);
xlabel('time [hrs]' , 'FontSize', 12);
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,1}(plot_nrs)');


fig_nr=2
bifig(fig_nr)=figure;
plot_nrs=3:5;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);

    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index','FontSize', 12);
xlabel('time [hrs]','FontSize', 12 );
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,1}(plot_nrs)');

fig_nr=3
bifig(fig_nr)=figure;
plot_nrs=6:8;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);

    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index','FontSize', 12);
xlabel('time [hrs]','FontSize', 12 );
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,1}(plot_nrs)');








fig_nr=4
bifig(fig_nr)=figure;
plot_nrs=9:13;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);

    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index', 'FontSize', 12);
xlabel('time [hrs]' , 'FontSize', 12);
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,2}(plot_nrs-no_datasets(1))');


fig_nr=5;
bifig(fig_nr)=figure;
plot_nrs=14:19;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);

    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index','FontSize', 12);
xlabel('time [hrs]','FontSize', 12 );
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,2}(plot_nrs-no_datasets(1))');


fig_nr=6;
bifig(fig_nr)=figure;
plot_nrs=20:23;
for i=1:length(plot_nrs);
    plot_ct=plot_nrs(i);
    
    plot(BI{plot_ct,3}(1:end-1)/3600,BI{plot_ct,2}(1:end-1))
    hold all
end
ylabel('Burstiness Index','FontSize', 12);
xlabel('time [hrs]','FontSize', 12 );
title(['Burstiness Index for various datasets. BI in ',num2str(interval_length/60), ' min windows'], 'FontSize', 12); 
ax_handle(fig_nr)=get(bifig(fig_nr),'Children');
legend_handle(fig_nr)=legend(ax_handle(fig_nr),datasets{1,2}(plot_nrs-no_datasets(1))');


set(legend_handle(:),'Interpreter','none');
set(ax_handle,'YLim', [0 1])









%does the BI depend on the binsize as discussed in a labmeting?
%not sure, amke some statistical test

datname=datnames(15).name;
ls=loadspike_noc_longcutouts(datname,2,25);
bin_widths=[ 0.25 0.5 1 1.5 2 2.5 3];
BI=cell(length(bin_widths),3);
recording_time=ls.time(end);
   interval_length=60*5;
   no_intervals = ceil(recording_time/interval_length);
   f_fifteen=zeros(1,no_intervals);
   
for i=1:length(bin_widths);
   
   
    for int_no=1:no_intervals
        start_time=(int_no-1)*interval_length;
        end_time = int_no*interval_length;

        all_spikes_ind  = find(ls.time > start_time & ls.time < end_time & ls.channel<60);   %look in the respective interval and only on the electrode channels
        all_spikes_time = ls.time(all_spikes_ind);
        all_spikes_hist = hist(all_spikes_time,start_time:bin_widths(i):end_time);
        sorted_all_spikes_hist=sort(all_spikes_hist,'descend');
        f_fifteen_cut=0.15*interval_length/bin_widths(i);
        f_fifteen(int_no)=sum(sorted_all_spikes_hist(1:floor(f_fifteen_cut)))/sum(all_spikes_hist);
        BI{i,2}(int_no)       = (f_fifteen(int_no)-0.15)/0.85;
        BI{i,3}(int_no)       = start_time;
    end
        BI{i,1}               = datname;
   
  
end


figure;
for j=1:length(bin_widths)
    plot(BI{j,3}(1:end-1)/3600,BI{j,2}(1:end-1));
    hold all;
end;
ylabel('Burstiness Index','FontSize', 12);
xlabel('time [hrs]','FontSize', 12 );
title(['Burstiness Index for various binsizes. BI in ',num2str(interval_length/60), ' min windows, dataset: ', num2str(datname)], 'FontSize', 12, 'Interpreter','none'); 
ylim([0 1]);
ax_handle=get(gca,'Children');
legend_handle=legend(ax_handle,num2str(bin_widths'));







