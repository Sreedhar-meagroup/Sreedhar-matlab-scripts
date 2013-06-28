%%%function Spike_sequence_spontaneous_stimulation();
% 
%For comparison of the sequences in spontaneous bursting activity and  
%in the responses upon stimulation. Is there the same activation sequence? 
% 
%I have already some kind of information stored about sequences in bursts, namely the 
% "EL_position" return vector, which stores, for each given NB in the
% considered period, the sequence of activation AMONG the channels that
% were detected as having (enough) bursts. Usually those channels are
% stored in the  "b_ch_mea" vector. If a channel is not participating in a
% NB, it gets a NaN for its position.
%
% For stimulation periods, I also have a vector called EL_position,
% where I store the sequences of activation (i.e. first spike in a 50 msec
% window after stimulation) upon stimulation. This is done for all 60
% electrodes and for electrodes that are not responding, I also set a NaN.
% In the function MAKE_PSTH_8X8, I  have already calculated the mean
% position for each electrode in the sequence (making the mean over all
% trials where the channel is responding in a 50 msec window). 
% If I do a similar thing for the spontaneous activity, comparison could be
% done by means of the sequence position. (And therefore I don't have to
% rely on different timescale in spont burst activity and stimulation
% responses)
% 
%
% NOTE:
% The sorting of the channels can be done according to the position in ALL NBs, or only according to the position from NBs starting from the stim channel.
% Depending on how I want to have this, I need to comment and uncomment some lines of code. This is marked by 
% %**************************************************************************
% in the following code
%
% 
% 
% INPUT:
% datname:                     The name of the dataset
% 
% EL_position_spont:           The return value fro the function
%                              burst_sequence. In this matrix, I store for relevant channels, their
%                              position in each NB. If they don't participate, then they get a NaN. the
%                              relevant channels are usually those that are a return value from the
%                              NB_detection function (b_ch_mea)
% 
% b_ch_mea                     a vector of channels for which this analysis
%                              should be made, usually the return value from NB_detection
% 
% 
%Stim_ch:                      The channel that was stimulated in the period where I have the responses from 
% 
% 
% Mean_response_position       A 60X2 vector, which is calculated in
%                              MAKE_PSTH_8X8. It stores for each channel its mean position in the
%                              response and its number of responses 
% 
% Nr_stimtrials                The nr of stimulation trials in the stim
%                              period
% 
% 
%sort_string:                  A string which should be either 'ALL' or
%                              'Stim'. This defines if the channels in the spontaneous case should be
%                              sorted according to the average position from al NBs or only from those
%                              started at the stim ch
%
%
% function  Spike_sequence_spontaneous_stimulation(datname,EL_position_spont,b_ch_mea, Stim_ch, Mean_response_position,Nr_stimtrials)




function  Spike_sequence_spontaneous_stimulation(datname,EL_position_spont,b_ch_mea, Stim_ch, Mean_response_position,Nr_stimtrials,sort_string)

%find those NBs that actually start on the Stim channel

%the following gives the index of the stim channel in the b_ch_mea vector
stim_ch_ind = find(b_ch_mea==Stim_ch);

%with this, I can look in EL_position_spont which NBs in the considered
%period are started from the stim ch and store their indices
%It stores the corresponding columsn indices to the row index stim_ch_ind
%The condition for starting the NB is of course to have sequence nr. 1
NB_stim_ch_start_col_ind = find(EL_position_spont(stim_ch_ind,:) == 1);

% I can immedialtely calculate  a mean sequence Nr. for each channel in the
% b_ch_mea vector;
%I make the sum over all columns (NBs),a nd exclude of course NaNs
Mean_seq_pos(:,1) = nanmean(EL_position_spont(:,NB_stim_ch_start_col_ind),2);
%I also store the according channel nr
Mean_seq_pos(:,2) = b_ch_mea;

if strcmp(sort_string,'Stim')
    [Mean_seq_pos(:,1) sort_ind] = sort(Mean_seq_pos(:,1));
    Mean_seq_pos(:,2)            = Mean_seq_pos(sort_ind,2);
end
    

%%%%I can also extract the mean position when all NBs are considered
Mean_seq_pos_ALL(:,1)      = nanmean(EL_position_spont,2);
%Also store the resp. channel Nr
Mean_seq_pos_ALL(:,2)     = b_ch_mea;
%THE result will be prdered according to the sorting form the previous
%case, in order to compare the results

if strcmp(sort_string,'Stim');
%execute these lines if I wanna sort according to the position in the NBs
%started only from the later stim channel
    Mean_seq_pos_ALL(:,1)   = Mean_seq_pos_ALL(sort_ind,1);
    % %AND sort the channels according to the previous case, too
    Mean_seq_pos_ALL(:,2)   = Mean_seq_pos_ALL(sort_ind,2);
elseif strcmp(sort_string,'ALL');
   %I can alos sort according to the position w..r. to ALL NBs
   [Mean_seq_pos_ALL(:,1) sort_ind_ALL] = sort(Mean_seq_pos_ALL(:,1));
   Mean_seq_pos_ALL(:,2)                = Mean_seq_pos_ALL(sort_ind_ALL,2);
else
    disp('wrong input for string argument');
    return
end


%For information on the total nr. of NBs started from the stim channel, the extend to which the electrode
%participate in the NB etc, extract some features
Total_nr_NBs   = size(EL_position_spont,2);
%store also the nr of NBs which start from the (later) stimulated ch only
Nr_NBs_stim_ch = length(NB_stim_ch_start_col_ind);

%find for each El the Nr. NBs in which it is participating when the NB is started on the stim_ch 
[row_ind col_ind]         = find(~isnan(EL_position_spont(:,NB_stim_ch_start_col_ind)));
%find also for each electrode the Nr of NBs it participates among ALL NBs
[row_ind_all col_ind_all] = find(~isnan(EL_position_spont)); 
%store the chanenl nr in the first row
NB_participation(1,:)     = b_ch_mea;
%store the absolut Nr of NBs in which the el participate and which start on
%the stim ch in the 2nd row
NB_participation(2,:)     = hist(row_ind,1:length(b_ch_mea));
%Store the percentage in the 3rd row
NB_participation(3,:)     = NB_participation(2,:)/Nr_NBs_stim_ch*100;
%Store the percentage of participation in NBs with respect to ALL NBs (i.e.
%not only those started on the stim ch) in the 4th row
NB_participation(4,:)      = hist(row_ind_all,1:length(b_ch_mea))/Total_nr_NBs*100;

%%%I could now resort the entries in NB_participation in order to match the
%%%order of entries in Mean_seq_pos, where the channels are sorted
%%%according to increasing average sequence nr:
if strcmp(sort_string,'Stim');
    NB_participation = NB_participation(:,sort_ind);
else
    NB_participation = NB_participation(:,sort_ind_ALL);
end




%%%%%%%%%%
%%*************************************************************************
%Going over to the calculation of the Sequences in the response. They are
%actually already calculated in Mean_response_position, which however
%stores the positions for all 60 channels, I should extract only those for
%the channels considered above

Mean_response_position = Mean_response_position(cr2hw(b_ch_mea)+1,:);
%add the channel notation to the new first row
Mean_response_position = cat(2,b_ch_mea',Mean_response_position);


if strcmp(sort_string,'Stim');
    Mean_response_position = Mean_response_position(sort_ind,:);
else 
    %I can also sort according to the position of ALL NBS
    Mean_response_position = Mean_response_position(sort_ind_ALL,:);
end


%I should look if the stim ch has accidentally a detected response (and
%therfore position_) and then delete this one and set the "position'for the
%stim ch to 0
stim_ch_ind = find(Mean_response_position(:,1)==Stim_ch);
if strcmp(sort_string,'Stim')
    %%%%If I sort for the NBs starting from the stim channel, I have to set
    %%%%the 'position' of the stim channel in the stim case to 1 and put
    %%%%tit at the beginning of the array
    if stim_ch_ind
        Mean_response_position(stim_ch_ind,:)=[];
        %set the position for the stim ch to 1 and put this at the beginning of the
        %vector. the nr. of responses could of course also be the nr. of trials,
        %but for simplicity, because this is the stim_channel, Iset it to 0
        Mean_response_position = cat(1,[Stim_ch 1 Nr_stimtrials ],Mean_response_position);
    end
    
else  %if I sort according ro ALL NBs, I also set the position to 1 but don't put it at the beginning of the array, because 
%     in the case where all NBs are considered it must not necessarily be that the stim ch starts the most NBs. In the ptehr case this
%     is per definition so.
    if stim_ch_ind
        Mean_response_position(stim_ch_ind,:) = [Stim_ch 1 Nr_stimtrials];
    end
    
end



%store the percentage of responding trials in the 4th column
Mean_response_position(:,4) = Mean_response_position(:,3)/Nr_stimtrials*100;
%When I have done all this, I can sort the sequence position the same way I
%have ordered the previous cases, with the index vector sort_ind


Seq_pos_plot = screen_size_fig();
%%%%Plot the positions sorted w.r. to the NBs starting from the stim
%%%%channel
if strcmp(sort_string,'Stim');
    bar(1:length(Mean_seq_pos),[Mean_seq_pos(:,1) Mean_response_position(:,2) ],1.5);
    %%%OR sort w.r. to the position in ALL NBs
else
    bar(1:length(Mean_seq_pos),[Mean_seq_pos_ALL(:,1) Mean_response_position(:,2) ],1.5);
end

bar_axis = gca;
y_limits = get(bar_axis,'ylim');

%plot also the bars for the average position in the responses
%bar(1:length(Mean_seq_pos),Mean_response_position(:,2),0.75,'r')
%plot above each bar, the percentage of participation in NBs as a text
%string
for ii = 1:length(Mean_seq_pos)
    text_string_stim_ch{ii} = [num2str(ceil(NB_participation(3,ii)*10)/10),' %'];
    
    %**********************************************************************
    text_string_ALL{ii}     = [num2str(ceil(NB_participation(4,ii)*10)/10),' %'];
    %**********************************************************************
    
    text_string_stim{ii}    = [num2str(ceil(Mean_response_position(ii,4)*10)/10), '%'];
end



%%%make some test to the plot
if strcmp(sort_string,'Stim');
    text_handle_NB_part = text([1:length(Mean_seq_pos)]-0.3,-1.2*ones(1,length(Mean_seq_pos)),text_string_stim_ch);
    text(1-0.25,y_limits(2)-0.7,'Upper Number is indicating the % of participation in NBs w.r. to NBs starting from the stim channel.');
    set(text_handle_NB_part(:),'FontSize', 8);
    set(bar_axis,'xtick',1:length(Mean_seq_pos),'XtickLabel',[Mean_seq_pos(:,2)]);

else
    text_handle_ALL     = text([1:length(Mean_seq_pos)]-0.3,-1.2*ones(1,length(Mean_seq_pos)),text_string_ALL);
    text(1-0.25,y_limits(2)-0.7,'Upper Number is indicating the % of participation in NBs w.r. to ALL NBs.');
    set(text_handle_ALL(:), 'Fontsize', 8);
    set(bar_axis,'xtick',1:length(Mean_seq_pos),'XtickLabel',[Mean_seq_pos_ALL(:,2)]);
end


text_handle_stim    = text([1:length(Mean_seq_pos)],-1.5*ones(1,length(Mean_seq_pos)),text_string_stim);
text(1-0.25,y_limits(2)-1.4,'Lower Number is indicating the % of responding trials w.r. to all stimulation trials.');
set(text_handle_stim(:),'FontSize', 8);

xlabel('Electrode Nr. (MEA-style)');
ylabel('Average position nr.');
if strcmp(sort_string,'Stim')
    title({['datname: ', num2str(datname)];['Average Sequence position; Taking the position in all NBs which start at the later stimulated channel ', num2str(Stim_ch),' (blue bars)'];...
       [ 'Taking the position in the responses upon stimulation on ch ', num2str(Stim_ch),' (red bars)'];...
       ['There were ', num2str(Nr_NBs_stim_ch),' NBs starting at the stim channel and ', num2str(Nr_stimtrials), ' stimulation trials']},'Interpreter', 'none')
else
    title({['datname: ', num2str(datname)];['Average Sequence position; Taking the position from all NBs (blue bars)'];...
       [ 'Taking the position in the responses upon stimulation on ch ', num2str(Stim_ch),' (red bars)'];...
       ['There were ', num2str(Nr_NBs_stim_ch),' NBs starting at the stim channel and ', num2str(Nr_stimtrials), ' stimulation trials']},'Interpreter', 'none')
end


%%%%%It happens that there are probably channels that only participate in a
%%%%%fraction of the NBs (ay <5%) and therfore a statistical measure of
%%%%%their position is not feasible. Therfore, in a 2nd step, make a
%%%%%further preselection of the selected channels.


disp('Channels with low percentage of particiaption (eg in NBs) should be removed')
ch_input = input('Give the channels that should be removed from the analysis (hit return if no change on channels: ')

if ch_input
    [b_ch_mea_new channel_ind] = setdiff(b_ch_mea,ch_input);

    disp('The indices for the new channels are (use for index in EL_position and b_ch_mea): ');
    channel_ind

    %%close the cureent (old) figure;
    close(gcf);
    
   
else return
end




















