%function set_maximum_axlimits(AX_handle,'option');
%
%this function sets the x,y, or x and y-axis limits to the same
%limits for all the axis in the vector AX_handle. The value hereby is the maximum value occurring 
%
%
%input:
%AX_handle:        A vector of axis handles
%
%option:           can be 'x', 'y', or 'xy'
%                 'x': set the limits of x-axes
%                 'y': set the limits of y-axes
%                 'xy': set the limits of x- and y-axes
function set_maximum_axlimits(AX_handle, option);
Nr_axis = length(AX_handle);

%extract the limuits
for ii=1:Nr_axis 
    X_limits(ii,:) = get(AX_handle(ii),'Xlim');
    Y_limits(ii,:) = get(AX_handle(ii),'Ylim');
end

%find the maximum  (and minimum) limits
MAX_xlim = max(X_limits(:,2));
MIN_xlim = min(X_limits(:,1));

MAX_ylim = max(Y_limits(:,2));
MIN_ylim = min(Y_limits(:,1));


switch option
    case 'x'
        set(AX_handle(:), 'Xlim',[MIN_xlim MAX_xlim]);
    case 'y'
         set(AX_handle(:), 'Ylim',[MIN_ylim MAX_ylim]);
    case 'xy'
         set(AX_handle(:), 'Xlim',[MIN_xlim MAX_xlim], 'Ylim',[MIN_ylim MAX_ylim] );
end
