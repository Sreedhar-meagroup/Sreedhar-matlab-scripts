% figure; hold on;
% for ii = 1:length(NB_slices)
%     if NB_slices{ii}.channel(1) == 50
%         plot(NB_slices{ii}.channel(1:5));
%     end
% end
% hold off;
% 
% %%
% prob_vecL1 = zeros(60,1);
% prob_vecL2 = zeros(60);
% % probability chart shall denote the probability that a channel is the first in a burst
% for ii = 1:size(NB_slices,1)
%     prob_vecL1(NB_slices{ii}.channel(1)+1) = prob_vecL1(NB_slices{ii}.channel(1)+1) + 1;
%     prob_vecL2(NB_slices{ii}.channel(2)+1,NB_slices{ii}.channel(1)+1) = prob_vecL2(NB_slices{ii}.channel(2)+1,NB_slices{ii}.channel(1)+1) + 1;
% end

%% burst participation metric
burst_part = zeros(60,1);
for ii = 1:length(NB_slices)
    burst_part(unique_us(NB_slices{ii}.channel)+1)= burst_part(unique_us(NB_slices{ii}.channel)+1) + 1;
end
%%
preB_silences = zeros(length(NB_slices),1);
