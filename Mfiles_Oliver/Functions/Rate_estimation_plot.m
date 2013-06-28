%plot for rate-estimation method

%originally working on 09_01_07_401_fonburst_fakestim

function Rate_estimation_plot(varargin)


if ~isempty(varargin)
    plot_handles = varargin{1}
else 
    plot_handles =[];
end
    
datname = '09_01_07_401_fbonburst_fakestim.spike'
ls = loadspike_seq_cutouts(datname,2,25,77187,77568)

begin_st  = 1007.5;
end_st    = 1010;
st_ind    = find(ls.time>begin_st & ls.time<end_st &ls.channel==46);

st        = ls.time(st_ind);
nr_spikes =length(st);



if ~isempty(varargin)
    axes(plot_handles(1))
else
    screen_size_fig();
    sub_h(1)=subplot(2,1,1);
end

for jj=1:length(st)
    spike_lines(jj)=line([st(jj)-begin_st st(jj)-begin_st],[0 1]);
    set(spike_lines(jj),'Color','k','Linewidth',3);
    hold on
end
xlim([0  end_st-begin_st])
ylim([0 2]);
title('rate estimation method','FontSize', 16)
set(gca,'Xtick',[],'Ytick',[]);



%5a binned version of the spike train

Bin_width  = 0.001 % is in sec
bin_vec    = [begin_st:Bin_width:end_st]-begin_st;
st_hist    = hist(st-begin_st,bin_vec);


kernel_sigma = 50;  %this should be in ms
triang_vec   = triang_kernel(kernel_sigma);
tr_length    = length(triang_vec);

%sub_h(2)=subplot(2,1,1)
for jj=1:length(st_hist)
    if(st_hist(jj)>0)
        spike_time  =  bin_vec(jj);
        x_vec       = [(spike_time-(tr_length/2-1)/1000):Bin_width:spike_time+(tr_length/2/1000)];
        plot(x_vec,2/max(triang_vec)*triang_vec,'k-.','Linewidth',2);
        hold on
    end
end
xlim([0 end_st-begin_st]);
ylim([0 3]);
set(gca,'Xtick',[],'Ytick',[]);
if isempty(varargin)
    text(0.1,2,'Kernel function','Color','k','Fontsize',22);
    text(0.1,1.5,'convolved with','Color','k','Fontsize',22);
    text(0.1,1,'spike times','Color','r','Fontsize',22)
end

st_rate      = conv(st_hist,triang_vec)/Bin_width;


kernel_overlap=floor(tr_length/2);
rm_ind=[1:kernel_overlap length(st_rate)-kernel_overlap+1:length(st_rate)];
st_rate(rm_ind)=[];

Rate_thresh = 40;
%x_vec= [bin_vec(1)-((kernel_overlap)/1000):Bin_width:bin_vec(end)+kernel_overlap/1000];
if ~isempty(varargin)
    axes(plot_handles(2))
else
   sub_h(3)=subplot(2,1,2);
end

plot(bin_vec,st_rate,'Linewidth',3,'Color','k')
hold on
thresh_line = line([bin_vec(1) bin_vec(end)],[Rate_thresh Rate_thresh]);
set(thresh_line,'Color','k','Linestyle','-.','Linewidth',3);
if isempty(varargin)
    text(0.1,42.9,'Trigger threshold','Fontsize',22,'Color','k')
    text(0.75,52,'Estimated rate','Fontsize',22,'Color','k');
end
ylabel('Rate [Hz]','FontSize', 12);
xlabel('Time [sec]','FontSize', 12);


%find the intersection between the threshold line and the estimated rate,
%i.e. the trigger time;
diff_vec   = st_rate  - Rate_thresh;
trigg_ind  = find(diff_vec >0);
%not the best implementation, but it works for this case. Taking the first
%crossing of the rate thresh
%trigg_line = line([bin_vec(trigg_ind(1)) bin_vec(trigg_ind(1))],[0 100]);
%set(trigg_line,'Color','r','Linewidth',3)

%plot a big black star as a marker
plot_h = plot(bin_vec(trigg_ind(1)),0,'^','Color','k','Markersize',15,'Markerfacecolor','k');














