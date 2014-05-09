function [qtab_mat, h] = plt_qtable(pname)
%Extrats qtable from log file and plots it
% INPUTS : Full path name of log file or cell array of pathnames
% OUTPUT : qtable in matrix format
% 24.02.2014-- fix the bug of saving the figure
   
    fid= fopen(pname,'r');
    qtab = textscan(fid,'%f %f %f','HeaderLines',15);
    qtab_mat = cell2mat(qtab);

    %% plotting and saving
    h = figure();
    plot(qtab_mat(:,1)*0.5,qtab_mat(:,2),'LineWidth',2,'color','g')
    hold on
    plot(qtab_mat(:,1)*0.5,qtab_mat(:,3),'LineWidth',2,'color','r')
    box off
    set(gca,'FontSize',14)
    xlabel('time [s]','FontSize' ,14)
    ylabel('Reward','FontSize',14)
    set(gca,'XGrid','on')
    legend('wait','stim','Location','Best');
    legend('boxoff');
    % saveas(gcf,'trained.eps', 'psc2')
