%write a function that plots  cutouts from all channels  in one
%figure

%input:
% ls             =   name of the structure that holds the cutouts, this is usually loaded with loadspike_seq_cutouts
% nr_cutouts     =  how many cutouts to be plotted maximamly in the figure
% for each channel

%output:
%a figure with the cutouts for the most active channels

function artifact_check_8X8(datname,ls,max_nr_cutouts)


x_vec      = (-2+0.04):0.04:(3-0.04);
cutout_fig=screen_size_fig();
hold on;
for hw_channel=0:63
    ch_ind          = find(ls.channel==hw_channel);
    total_nr_spikes =length(ch_ind);
    
    [cpos,rpos]           = hw2cr(hw_channel);
    plotpos               = cpos+8*(rpos-1);
    
    if total_nr_spikes > 1/10*max_nr_cutouts
        
        %determine if I have max_nr_cutouts or less
        if total_nr_spikes < max_nr_cutouts
            nr_cutouts = total_nr_spikes;
        else 
            nr_cutouts = max_nr_cutouts;
        end

        hsub(hw_channel+1)    = subplot(8,8,plotpos);
        plot(x_vec,ls.context(:,ch_ind(1:nr_cutouts)),'--','Color', [.8 .8 .8])
        hold on;

        pos_ind=find(ls.context(50,ch_ind(1:nr_cutouts))>0);
        neg_ind=find(ls.context(50,ch_ind(1:nr_cutouts))<0);
        
        if length(pos_ind) > 1/4*nr_cutouts & length(neg_ind) > 1/4*nr_cutouts
            pos_mean_cutout=mean(ls.context(:,ch_ind(pos_ind)),2);
            neg_mean_cutout=mean(ls.context(:,ch_ind(neg_ind)),2);
            plot(x_vec,pos_mean_cutout,'r', 'LineWidth', 2);
            hold on;
            plot(x_vec,neg_mean_cutout,'b', 'LineWidth', 2);
        else
            mean_cutout=mean(ls.context(:,ch_ind(1:nr_cutouts)),2);
            plot(x_vec,mean_cutout,'k', 'LineWidth', 2);
        end
            
        title(['ch ', num2str(hw2cr(hw_channel)),', ',num2str(nr_cutouts),' cutouts']);
         
    else
        hsub(hw_channel+1)    = subplot(8,8,plotpos);
        title(['ch ', num2str(hw2cr(hw_channel))]);
    end
   xlim([-2 3])
end
subplot(8,8,1)
    title({['datname: ', num2str(datname)];['(maximally) ',num2str(max_nr_cutouts),' spike cutouts for all channels (in gray)'];...
        ['mean cutout shape plotted in black'];['in red and blue if there are enough pos and neg. spikes']},'Interpreter', 'none');
    xlabel('time [msec] ');


    
