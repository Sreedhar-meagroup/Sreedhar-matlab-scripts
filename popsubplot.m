function popsubplot(ah, fh, varargin)
% POPSUBPLOT - copies a subplot into a full figure
% POPSUBPLOT(ah, fh) copies the object <ah> into the 
% figure <fh> if this exists. If it doesn't a new one
% is created. <fh> is optional. Instead of a handle 
% <fh> may be a name of a figure.
%
% The function can be called, for example, by setting
% the 'WindowButtonDownFcn' of a figure containing the
% subplots to 'popsubplots(gca)'. Note that this setting
% will be erased by any 'zoom' command.
%
% U. Egert 6/98

marksizegui = 1;

% this loop looks for modifications of the default values by parameter/value pairs
pvpmod(varargin);

if strcmp(get(ah, 'type'), 'axes')
   if exist('fh') 
      if ischar(fh)
         a = setgcf(fh);
      else
         a = figure(fh);
      end;
   else
      a = setgcf('popsubplot figure');
   end;
   clf
   bh = copyobj(ah, a);
   set(bh, 'units', 'normalized', 'position', [.1 .1 .8 .8]);
   set(bh, 'buttondownfcn','');
else
   disp([mfilename ':: please select an AXES object'])
end;

if marksizegui
   chmarksizegui(a);
end;

oph = [findobj(a, 'label', 'Options'); findobj(a, 'label', '&Options')];
if isempty(oph)
    oph = uimenu('parent', a, ...
        'label', '&Options', ...
        'tag', 'optionsmenu');
end;
mph = uimenu('parent', oph, ...
    'label', 'rename figure', ...
    'tag', 'rename figure', ...
    'callback', 'popsubplotctrl(''renamefig'',gcbf);');
mph = uimenu('parent', oph, ...
    'label', 'adjust axis', ...
    'tag', 'adjust axis', ...
    'callback', 'popsubplotctrl(''adj_axis'',gcbf);');

addpscprintmenu(a);

return;