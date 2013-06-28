%17/01/07
%file that plots for the dataset 09_01_07_fbonburst and
%...fbonburst_fakestim some comparison plots between stim and non stim case
%consider the bursts around the trigger, which are probably the most
%influenced by the stimulation

%stimulusraster must be loaded
%also the burst_detection

%this mfile analyses tne burst around a trigger, the
%plots are for datasets without stimulation and  with
%stimulation. Therfore, it is slightly uncomfortable to run
% some mfiles (includingthe first part of this one) for a dataset without
% stimulation and then with stimulation and renaming the necessary arrays
% for the stim case to '..._stim' because thats what the plot command
% currently want.

TRIG_WINDOW=0.1;

bursting_channels=[];
for i = 1:length(burst_detection)
    if ~isempty(burst_detection{1,i})
        bursting_channels=cat(2,bursting_channels,i);
    end
end

bursting_channels_mea=[13 17 24 26 48 53 78];
bursting_channels=cr2hw(bursting_channels_mea)+1;
no_bursting_ch=length(bursting_channels);



%find the bursts around the trigger
trig_ind    = find(ls.channel==60);
trig_times  = ls.time(trig_ind);
trig_num    = length(trig_times);

%initialize the arrays
burst_around_trig      = cell(no_bursting_ch,trig_num);
b_length_after_trig    = cell(no_bursting_ch,trig_num);
b_length_after_trig_ma = cell(no_bursting_ch,trig_num);


for b_ch=1:no_bursting_ch
    burst_ch = bursting_channels(b_ch)
    for trig_ct=1:trig_num  %cycle through all triggers
        found=0;
        
        for burst_ct=1:size([burst_detection{1,burst_ch}],1)  %cycle through all bursts, size along the rows, i.e how many bursts
            if (find( burst_detection{1,burst_ch}{burst_ct,3} > trig_times(trig_ct) & ( burst_detection{1,burst_ch}{burst_ct,3}  < (trig_times(trig_ct)+TRIG_WINDOW))  ) > 0)  %i.e. if there are spike in a window around a trigger
               burst_around_trig{b_ch,trig_ct} = burst_ct;  %this stores the burst index which has a
               b_length_after_trig{b_ch, trig_ct} = burst_detection{1,burst_ch}{burst_ct,3}(end) - trig_times(trig_ct);
               found=1;
               break;   %breaks from the burst_ct for loop
            end
        end
        if ~found
            burst_around_trig{b_ch,trig_ct}   = NaN;
            b_length_after_trig{b_ch,trig_ct} = 0;
        end
      
    end %of the trig_ct loop 
end  %of the b_ch loop



%make a 'moving average'of the burst length after the trigger
% i.e giving an avergae burst length by averaging with j triggers before 
%and with j triggers after the respective one
AVERAGE_W=20;
for b_ch=1:no_bursting_ch
    for i=1:trig_num
        if i < AVERAGE_W+1
            b_length_after_trig_ma{b_ch,i }  = 1/(2*AVERAGE_W+1)*((AVERAGE_W+1)*b_length_after_trig{b_ch,i} + sum([b_length_after_trig{b_ch,(i+1):(i+AVERAGE_W+1)}]));
        elseif i > trig_num -(AVERAGE_W+1)
              b_length_after_trig_ma{b_ch,i} = 1/(2*AVERAGE_W+1)*(sum([b_length_after_trig{b_ch,(i-AVERAGE_W):i-1}]) + (AVERAGE_W+1)*b_length_after_trig{b_ch,i} );
        else
             b_length_after_trig_ma{b_ch,i}  = 1/(2*AVERAGE_W+1)*sum([b_length_after_trig{b_ch,i-AVERAGE_W:i+AVERAGE_W}]);
        end
    end
end



%plot some of the results
for b_ch=1:no_bursting_ch
    fig_h(b_ch)=figure;
    
    subplot(2,3,1)
     for trial=1:trig_num
         plot(stimulusraster(bursting_channels(b_ch),1:noofspikes(bursting_channels(b_ch),trial),trial),trial*ones(noofspikes(bursting_channels(b_ch),trial),1),'*k','MarkerSize',2);
         hold on
     end;
         xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
         ylabel('trial no.', 'Fontsize', 14);  
         set(gca,'YLim',[0 trig_num]); % manuell
         set(gca,'XLim',[XDATAPRE/4 XDATAPOST]); 
         set(gca,'FontSize',14);
         title({['dataset: ', datname];['channel ', num2str(bursting_channels_mea(b_ch))]}, 'Interpreter', 'none');
     
     subplot(2,3,2);
     barh([b_length_after_trig{b_ch,:}])
     xlabel('burst length after trigger [sec]','FontSize',14);
     ylabel('trial no.','Fontsize', 14);  
     set(gca,'YLim',[0 trig_num]);
     set(gca, 'XLim',[0 XDATAPOST]);
     set(gca,'FontSize',14);
     
     
     subplot(2,3,3)
     plot([b_length_after_trig_ma{b_ch,:}],1:length(b_length_after_trig_ma))
     set(gca,'YLim',[0 trig_num]);
     set(gca, 'XLim',[0 XDATAPOST]);
     xlabel({['moving averaged (+-',num2str(AVERAGE_W),')'];['burst length after trigger [sec]']},'FontSize',14);
     ylabel('trial no.','Fontsize', 14);  
     set(gca,'FontSize',14);
end 

     
     %for the cases with stimulation, generate the arrays, rename them to
     %'..._stim'
     %i.e, stimulusraster and b_length_after_trig, datname,
     %noofspikes
     subplot(2,3,4)
     for trial=1:trig_num
         plot(stimulusraster_stim(bursting_channels(b_ch),1:noofspikes_stim(bursting_channels(b_ch),trial),trial),trial*ones(noofspikes_stim(bursting_channels(b_ch),trial),1),'*k','MarkerSize',2);
         hold on
     end;
         xlabel('time r. t. stimulus [sec]', 'FontSize', 14);
         ylabel('trial no.', 'Fontsize', 14);  
         set(gca,'YLim',[0 trig_num]); % manuell
         set(gca,'XLim',[XDATAPRE/4 XDATAPOST]); 
         set(gca,'FontSize',14);
         title({['dataset: ', datname_stim];['channel ', num2str(bursting_channels_mea(b_ch))]}, 'Interpreter', 'none');
     
     subplot(2,3,5);
     barh([b_length_after_trig_stim{b_ch,:}])
     xlabel('burst length after trigger [sec]','FontSize',14);
     ylabel('trial no.','Fontsize', 14);  
     set(gca,'YLim',[0 trig_num]);
     set(gca, 'XLim',[0 XDATAPOST]);
     set(gca,'FontSize',14);
     
     subplot(2,3,6)
     plot([b_length_after_trig_ma_stim{b_ch,:}],1:length(b_length_after_trig_ma_stim))
     set(gca,'YLim',[0 trig_num]);
     set(gca, 'XLim',[0 XDATAPOST]);
      xlabel({['moving averaged (+-',num2str(AVERAGE_W),')'];['burst length after trigger [sec]']},'FontSize',14);
     ylabel('trial no.','Fontsize', 14);  
     set(gca,'FontSize',14);
     
end
     
     
   


     

        
        
        
            
          
            
     
     
     
     
     
     
     
     
    
    
    
    
    
    


