%17/01/07
%a statistic about all isis (on single channel) in the recording.
%with this, there a multiple peaks to be expected in the distributions,
%as samora has often observed. Make also a logarithmic binning of the isi
%width.

 %make a ls(ISI) distribution, as described in the paper by Selinger et. al

 
 for ch=0:59;
     spike_ind=find(ls.channel==ch);
     spike_times=ls.time(spike_ind);
     if ~isempty(spike_times);
     ISIs{ch+1}      = diff(spike_times);
     ln_ISIs{ch+1}   = log(ISIs{ch+1});
     nr_spikes(ch+1) = length(ln_ISIs{ch+1});
     end
 end
 
 
 ln_plot_bin=-7:0.2:3;
 x_tick_label = [0.001 0.01 0.1 1 10 50];
 x_tick       = log(x_tick_label);
 isi_distr=figure;
for ch=0:59
    [xposi,yposi] = hw2cr(ch);
    plotpos       = xposi+8*(yposi-1);
    hsub(ch+1)    = subplot(8,8,plotpos);
    if length(ISIs{ch+1}) > (2*ls.time(end)/(60)) %i.e. at least two spikes a minute on average
    ln_hist{ch+1}=[hist(ln_ISIs{ch+1},ln_plot_bin)];
    bar(ln_plot_bin,ln_hist{ch+1}/nr_spikes(ch+1));
    set(gca,'xtick', x_tick,'xticklabel',x_tick_label);
    title(['channel ', num2str(hw2cr(ch))]);
    else
        title(['channel ', num2str(hw2cr(ch))]);
        continue
    end
end
subplot(8,8,1);
  title({['ln(ISI) distribution , dataset: '];[num2str(datname)];['channel: ',num2str(hw2cr(60))]}, 'FontSize',12,'Interpreter', 'none') 
  subplot(8,8,57);
  xlabel('ISI [sec]');
  ylabel('probability');

  
  
selected_mea=[13 17 24 26 48 53 74 78]
%selectedchannels=[18 19 3 4 47 52]
selectedchannels=cr2hw(selected_mea);  %select channels based on Hardware specifications
channelcount=length(selectedchannels);
subplotsizecolumn=ceil(sqrt(channelcount));
subplotsizerow=ceil(channelcount/subplotsizecolumn);
selectedfig=figure;


time_plot_bin=exp(ln_plot_bin);
for jj=1:channelcount;
    sel_ch=selectedchannels(jj);
    ln_hist{jj}=[hist(ln_ISIs{sel_ch+1},ln_plot_bin)];
    sub_h=subplot(subplotsizecolumn,subplotsizerow,jj);
    if length(ISIs{sel_ch+1}) > (2*ls.time(end)/(60)) %i.e. at least two spikes a minute on average
    bar(ln_plot_bin,ln_hist{jj}/nr_spikes(sel_ch+1));
    set(gca,'xtick', x_tick,'xticklabel',x_tick_label);
    xlabel(' inter spike interval [sec]');
    ylabel('counts');
    title(['channel ', num2str(selected_mea(jj))]);
    else
        sub_h=subplot(subplotsizecolumn,subplotsizerow,jj);
        title(['channel ', num2str(hw2cr(sel_ch))]);
        continue
    end
end
subplot(subplotsizecolumn,subplotsizerow,1);
 title({['ln(ISI) distribution , dataset: '];[num2str(datname)];['channel: ',num2str(hw2cr(selected_mea(1)))]}, 'FontSize',12,'Interpreter', 'none') 
  xlabel('ISI [sec]');
  ylabel('probability');   
    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 





