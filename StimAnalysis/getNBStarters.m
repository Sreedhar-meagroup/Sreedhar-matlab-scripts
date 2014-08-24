function final_tally = getNBStarters(data)
NB_slices = data.NetworkBursts.NB_slices;
mod_NB_onsets = data.NetworkBursts.NB_extrema(:,1);
% final_tally = zeros(5,7);
final_tally = zeros(5,1);

%% Col 1. NB starters
NB_starters = cellfun(@(x) x.channel(1)+1, NB_slices);
temp1 = hist(NB_starters,1:60);
[temp2,temp3] = sort(temp1,'descend');
figure();
set(gca, 'FontSize',14);
bar(temp2(1:7),'EdgeColor', 'None');
set(gca,'XTickLabel',temp3(1:7));
xlabel({'Channels (in hw+1)'; ['[',num2str(hw2cr(temp3(1:7)-1)), ']  (in cr)']});
ylabel('No: of NBs initiated');
box off;
set(gca, 'TickDir', 'Out');

final_tally(:,1) = temp3(1:5);
%%
% %% Col 2. scores with the entire burst lengths divided into 3 sections (unique)
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     classA = 1:round(length(NB_slices{ii}.time)/3);
%     classB = classA(end)+1:round(2*length(NB_slices{ii}.time)/3);
%     classC = classB(end)+1:length(NB_slices{ii}.time);
%     %scores(NB_slices{ii}.channel(classA)+1) = scores(NB_slices{ii}.channel(classA)+1)+ 3;
%     scores(unique_us(NB_slices{ii}.channel(classA))+1) = scores(unique_us(NB_slices{ii}.channel(classA))+1)+ 3;
%     %scores(NB_slices{ii}.channel(classB)+1) = scores(NB_slices{ii}.channel(classB)+1)+ 2;
%     scores(unique_us(NB_slices{ii}.channel(classB))+1) = scores(unique_us(NB_slices{ii}.channel(classB))+1)+ 2;
%     %scores(NB_slices{ii}.channel(classC)+1) = scores(NB_slices{ii}.channel(classC)+1)+ 1;
%     scores(unique(NB_slices{ii}.channel(classC))+1) = scores(unique(NB_slices{ii}.channel(classC))+1)+ 1;
% end
% [~,b] = sort(scores,'descend');
% final_tally(:,2) = b(1:size(final_tally,1));
% 
% %% Col 3. scores considering the ranks of just the first 10 spikes of each NB (unique)
%  
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     %scores(NB_slices{ii}.channel(1:10)+1) = scores(NB_slices{ii}.channel(1:10)+1)+ [10:-1:1]';
%     temp_chan = unique_us(NB_slices{ii}.channel(1:10),'first',10);
%     scores(temp_chan+1) = scores(temp_chan+1)+ (length(temp_chan):-1:1)';
% end
% [~,b] = sort(scores,'descend');
% final_tally(:,3) = b(1:size(final_tally,1));
% 
% %% Col 4. scores looking at three 50 ms increments after NB start
% % 
% scores = zeros(60,1);
% for ii = 1: length(mod_NB_onsets)
%     %classA = NB_slices{ii}.channel(NB_slices{ii}.time<= mod_NB_onsets(ii)+50e-3);
%     classA = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time<= mod_NB_onsets(ii)+50e-3));
%     %classB = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+50e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+100e-3);
%     classB = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+50e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+100e-3));
%     %classC = NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+100e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+150e-3);
%     classC = unique_us(NB_slices{ii}.channel(NB_slices{ii}.time> mod_NB_onsets(ii)+100e-3 & NB_slices{ii}.time<= mod_NB_onsets(ii)+150e-3));
%     scores(classA+1) = scores(classA+1) + 3;
%     scores(classB+1) = scores(classB+1) + 2;
%     scores(classC+1) = scores(classC+1) + 1;
% end
% [~,b] = sort(scores,'descend');
% final_tally(:,4) = b(1:size(final_tally,1));
% 
% 
% %% Col 5 - 7. Occurence probability distribution
% 
% % Col 5. P(1)
% prob_chart = zeros(60,1); % probability chart shall denote the probability that a channel is the first in a burst
% for ii = 1:size(NB_slices,1)
%     prob_chart(NB_slices{ii}.channel(1)+1) = prob_chart(NB_slices{ii}.channel(1)+1) + 1;
% end
% prob_chart = prob_chart/size(NB_slices,1);
% [~,b] = sort(prob_chart,'descend');
% final_tally(:,5) = b(1:size(final_tally,1));
% 
% 
% % Col 6. P(3)
% prob_chart = zeros(60,1);
% for ii = 1:size(NB_slices,1)
%     ch_unique = unique_us(NB_slices{ii}.channel);
%     %ch_non_unique = NB_slices{ii}.channel;
%     temp = ismember([1:60]', ch_unique(1:3)+1);
%     %temp = ismember([1:60]', ch_non_unique(1:3)+1);
%     prob_chart = prob_chart + temp;
% end
% prob_chart = prob_chart/size(NB_slices,1);
% [~,b] = sort(prob_chart,'descend');
% final_tally(:,6) = b(1:size(final_tally,1));
% 
% 
% % Col 7. P(5)
% prob_chart = zeros(60,1);
% not_incl = [];
% for ii = 1:size(NB_slices,1)
%     ch_unique = unique_us(NB_slices{ii}.channel);
%     %ch_non_unique = NB_slices{ii}.channel;
%     if length(ch_unique)>=5
%     %if length(ch_non_unique>=5)
%         temp = ismember([1:60]', ch_unique(1:5)+1);
%         %temp = ismember([1:60]', ch_non_unique(1:5)+1);
%         prob_chart = prob_chart + temp;
%     else
%         not_incl(end+1) = ii;
%     end
% end
% prob_chart = prob_chart/(size(NB_slices,1)-numel(not_incl));
% [~,b] = sort(prob_chart,'descend');
% final_tally(:,7) = b(1:size(final_tally,1));
% 
% %% A distance matrix
% dist_matrix = zeros(size(final_tally,2));
% % distance as absolute value of difference in ranks
% % for ii = 1:size(final_tally,2)
% %     for jj = ii:size(final_tally,2)
% %         for kk = 1:size(final_tally,1)
% %             if ~isempty(find(final_tally(:,jj) == final_tally(kk,ii)))              
% %                 dist_matrix(ii,jj) = dist_matrix(ii,jj) + abs((kk - find(final_tally(:,jj) == final_tally(kk,ii))));
% %             else
% %                 dist_matrix(ii,jj) = dist_matrix(ii,jj) + abs((kk - size(final_tally,1)));
% %             end
% %         end
% %     end
% % end
% 
% % distance as Euclidean distance in a 5D space of rank differences
% for ii = 1:size(final_tally,2)
%     for jj = ii:size(final_tally,2)
%         for kk = 1:size(final_tally,1)
%             if ~isempty(find(final_tally(:,jj) == final_tally(kk,ii),1))              
%                 dist_matrix(ii,jj) = dist_matrix(ii,jj) + (kk - find(final_tally(:,jj) == final_tally(kk,ii)))^2;
%             else
%                 dist_matrix(ii,jj) = dist_matrix(ii,jj) + (kk - size(final_tally,1))^2; %size(final_tally,1)^2;
%             end
%         end
%     end
% end
% dist_matrix = dist_matrix + triu(dist_matrix)';
% dist_matrix = dist_matrix.^0.5./sqrt(125);
% figure; imagesc(dist_matrix); colorbar;
% 
% set(gca,'Xtick',1:7);
% set(gca,'Ytick',1:7);
% set(gca,'Xticklabel',{'Oliver''s scheme'; 'Dividing into thirds'; ...
%     'Ranks of first ten'; 'Three slabs'; 'P(1 spike)';'P(3 spikes)';'P(5 spikes)'},'FontSize',14);
% set(gca,'Yticklabel',{'Oliver''s scheme'; 'Dividing into thirds'; ...
%     'Ranks of first ten'; 'Three slabs'; 'P(1 spike)';'P(3 spikes)';'P(5 spikes)'},'FontSize',14);
% xticklabel_rotate;
% set(gca,'TickDir','Out');
% axis square;
% 
% 
% % export_fig('C:\Sreedhar\Lat_work\Closed_loop\misc\work_documentation\figures\test','-eps','-transparent')
% 
% % disp(['Oliver''s verdict: ', num2str(hw2cr(final_tally(:,1)-1)), ' (cr)'])
disp(['Your stimulate options!!! : ', num2str(hw2cr(final_tally(:,1)-1)), ' (cr)'])
