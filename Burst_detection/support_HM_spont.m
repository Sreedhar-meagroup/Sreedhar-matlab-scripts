% run spontaneousData prior to running this file
rankList = cell(length(NB_slices),1);
timeList = cell(length(NB_slices),1);
for ii = 1:length(NB_slices)
    rankList{ii} = unique_us(NB_slices{ii}.channel)+1;
    for jj = 1:size(rankList{ii},2)
        timeList{ii}(jj) = NB_slices{ii}.time(find(NB_slices{ii}.channel==rankList{ii}(jj)-1,1,'first'));
    end
end

