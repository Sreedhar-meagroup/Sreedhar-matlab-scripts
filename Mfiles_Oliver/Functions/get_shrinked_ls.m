%make an ls that has only the considered period of time in it,
%usefulw when having large datasets which use a lot of memory, however the
%analysis is only done on a particular part of the data.


function ls_back=get_shrinked_ls(ls_in, time_start, time_end)


period_ind      = find(ls_in.time >time_start*3600 & ls_in.time<time_end*3600);

ls_back.channel = ls_in.channel(period_ind);
ls_back.time    = ls_in.time(period_ind);

disp(' returning new ls-structure, the old one can be cleared to free up memory');
