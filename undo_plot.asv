function undo_plot(h, n)
% UNDO_PLOT Undo last 'n' plotting operations.
%Thanks jonathansk, csail@mit.edu
if nargin == 1 
  n = 1;
end
	
if n < 1
  error('Can''t undo < 1 plotting operation!');
end
	
figure(h);
children = get(gca, 'children');
	
for i = 1 : n
  delete(children(i));
end