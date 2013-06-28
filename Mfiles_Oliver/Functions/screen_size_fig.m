%construct a figure window that has screen size;

%input:  none

%output: the figure handle

function screen_fig=screen_size_fig();

screen_fig = figure;
%set(screen_fig,'Position', [0 0 1600 1120]);
%since I recently wotk with a toolbar in windows that has double the
%height, some axes labels inmatkab plots are hidden, can be corrected by changing the
%position of the screen size figure
set(screen_fig,'Position',[-3 69 1600 1056])