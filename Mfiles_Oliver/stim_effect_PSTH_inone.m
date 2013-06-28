%plot stimulus effect and psth on one figure, for one channel


selected_mea=[13 17 24 26 48 53 78]
selectedchannels=cr2hw(selected_mea);  %select channels based on Hardware specifications
channelcount=length(selectedchannels);
subplotsizecolumn=2;
subplotsizerow=1;


for i = 1: channelcount
    figure_handle(i)=figure;
    sub_handle(1)=subplot(2,1,1);
     for trial=1:TRIALS
         plot(stimulusraster(selectedchannels(i)+1,1:noofspikes(selectedchannels(i)+1,trial),trial),trial*ones(noofspikes(selectedchannels(i)+1,trial),1),'*k','MarkerSize',2);
         hold on
     end;
         xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
         ylabel('trial no.', 'Fontsize', 14);  
         set(sub_handle(1),'YLim',[0 TRIALS]); % manuell
         set(sub_handle(1),'XLim',[XDATAPRE XDATAPOST]); 
         set(sub_handle(1),'FontSize',14);
        
     sub_handle(2)=subplot(2,1,2)
          kan=selectedchannels(i);
          plot(xvec,psthvector(kan+1,1:length(xvec)));
          title(['PSTH, bin width = ', num2str(binweite*1000), ' ms'], 'FontSize', 14);
          xlabel('time r.t. stimulus [sec]', 'FontSize',14);
          ylabel('count', 'Fontsize',14);
          set(sub_handle(2),'FontSize',14);
          subplot(2,1,1);
          title({[datname];['Stimulation  for ',num2str(TRIALS),' trials with a feedback condition'];['channel ', num2str(selected_mea(i))]}, 'FontSize',14,'Interpreter', 'none');
end
