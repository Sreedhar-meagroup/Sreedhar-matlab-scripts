%25/04/07
%how to best arrange a specific number of plots in
% a subplot figure, if I wnat to count the figures alongthe rows
%     and not along the columns as matlab does it. Here is a solution:
    
    
    function [plot_pos subplot_r subplot_c]=get_subplot_position(nr_subplots);
    
    %this defines the shape of the subplot
    subplot_r  = ceil(sqrt(nr_subplots));
    subplot_c  = ceil(nr_subplots/subplot_r);
    
    plot_nrs_vec=1:nr_subplots;
    
    %this is the assignment for each plot nr to the columns in the subplot
    which_col  = (floor((plot_nrs_vec-1)/subplot_r)+1);
    
    %with this formula, I get the mapping of the subplot_nrs to the
    %position in the subplot
    %this is a nr_subplots long vector
    plot_pos = which_col + ((plot_nrs_vec-1)-(which_col-1)*subplot_r)*subplot_c;
    