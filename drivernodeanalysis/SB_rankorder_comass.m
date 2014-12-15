%% center of mass analysis
cmass = cell(1,length(NB_slices));
count = 1;
for ii = 1:1
    for jj = 1:5:length(chanList_brief{ii})
        [y(ii), x(ii)] = find(SB_meamat(:,:,1) == jj);
        cmass{ii}(count,:) = [mean(x),mean(y)];
        count = count+1;
    end
end