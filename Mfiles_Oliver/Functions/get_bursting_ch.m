%25_04_07
%write a function that automatically choose the x_most bursting channels,
%i.e with the most bursts on it
%function [bursting_ch_mea, nr_of_bursts]=get_bursting_ch(burst_detection,nr_ch)

function [bursting_ch_mea, nr_of_bursts]=get_bursting_ch(burst_detection,nr_ch)

for ii=1:length(burst_detection)
    burst_nr(ii,1)  = size(burst_detection{1,ii},1);
    burst_nr(ii,2)  = ii;
end

all_active_ind = find(burst_nr(:,1)>0);
burst_nr       = burst_nr(all_active_ind,:);
%check if there are as many bursting channels as desired
if length(find(burst_nr(:,1)>0)) < nr_ch
    disp(' Not so many bursting channels available, returning only the ones bursting' );
    nr_ch = length(burst_nr);
end

[burst_sorted sort_index]  = sort(burst_nr,1,'descend');
burst_sorted(:,2)          = burst_nr(sort_index(:,1),2);



[bursting_ch_mea mea_sort_ind] = sort(hw2cr(burst_sorted(1:nr_ch,2)-1));
nr_of_bursts          = burst_sorted(1:nr_ch,1)';
nr_of_bursts(1:nr_ch) = nr_of_bursts(mea_sort_ind);