%% Given below are three options to get landscape images (eps or pdf) properly
% option 1 ----------------------------------------------------------------
h=gcf;
set(h,'PaperPositionMode','auto'); 
set(h,'PaperOrientation','landscape');
set(h,'Position',[50 50 1200 800]);
print(gcf, '-depsc', 'art.eps')


% option 2 ----------------------------------------------------------------
h=gcf;
set(h,'PaperOrientation','landscape');
set(h,'PaperPosition', [1 1 28 19]);
print(gcf, '-dpdf', 'test4.pdf');

% option 3 ----------------------------------------------------------------
h=gcf;
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 1 1]);
print(gcf, '-dpdf', 'test3.pdf');

