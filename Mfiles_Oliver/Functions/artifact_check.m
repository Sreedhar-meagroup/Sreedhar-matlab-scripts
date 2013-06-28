% %write a function that plots all the cutouts for a givn channel in one
% %
% function artifact_check(ls,mea_channel,nr_cutouts,plot_boolean)
% 
% 
% 
% 
% 
%input:
% ls             =   name of the structure that holds the cutouts, this is usually loaded with loadspike_seq_cutouts
% mea_channel_nr =   mea channel for which cutouts should be plotted, can
%                    also be a vector of several channels
% nr_cutouts     =  how many cutouts to be plotted maximamly in ne figure
% plot_boolean      determines if plot output is desired in extra or not

function artifact_check(ls,mea_channel,nr_cutouts,plot_boolean)

nr_channels = length(mea_channel);
hw_channel  = cr2hw(mea_channel);
x_vec       = (-2+0.04):0.04:(3-0.04);


for kk=1:nr_channels
    ch_ind      = find(ls.channel==hw_channel(kk));
    
    
    all_pos_spikes = ch_ind(find(ls.context(50,ch_ind)>0));
    all_neg_spikes = ch_ind(find(ls.context(50,ch_ind)<0));
    
    if ~isempty(all_pos_spikes)
        mean_cutout_pos   = mean(ls.context(:,all_pos_spikes),2);
    end
    if ~isempty(all_neg_spikes)
        mean_cutout_neg  = mean(ls.context(:,all_neg_spikes),2);
    end

    total_nr_spikes=length(ch_ind);
    if total_nr_spikes<nr_cutouts
        disp(['only ', num2str(total_nr_spikes),' spikes on the resp. channel, plotting all those']);
        nr_cutouts = total_nr_spikes;
    end

if plot_boolean
    cutout_fig=screen_size_fig();
end
for ii=1:nr_cutouts
    %calculate the offset in a 1.5 msec window
    mean_offset(ii) =  mean(ls.context(1:37,ch_ind(ii)),1);
    plot(x_vec,ls.context(:,ch_ind(ii))-mean_offset(ii),'--','Color', [.8 .8 .8])
    hold on;
end


    %define the mean positive and negative offset
    mean_allpos_offset = mean(mean(ls.context(1:37,all_pos_spikes),2));
    mean_allneg_offset = mean(mean(ls.context(1:37,all_neg_spikes),2));
    %plot the mean cutout
    if ~isempty(all_pos_spikes)
        plot(x_vec,mean_cutout_pos-mean_allpos_offset,'g', 'LineWidth', 2);
    end
    if ~isempty(all_neg_spikes)
        plot(x_vec,mean_cutout_neg-mean_allneg_offset,'r', 'LineWidth', 2);
    end
    
    title({[num2str(nr_cutouts),' spike cutouts from channel ',num2str(mea_channel(kk)),' plotted in gray'];...
        ['mean cutout shape plotted in red']});
    xlabel('time [msec] ');
    
end
  
    
