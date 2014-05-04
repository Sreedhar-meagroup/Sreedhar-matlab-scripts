%% for 6 session recordings response distributions
% if nSessions == 6
    resp_dist_h = figure();
    dist_h = zeros(1,nSessions);
    max_yval = 0;
    for ii = 1:nSessions
        num = hist(respLengths_n(session_vector(ii)+1:session_vector(ii+1)),0:max(respLengths_n));
        dist_h(ii) = subplot(nSessions/2,2,ii);
        plot(0:max(respLengths_n),num/nStimuliInEachSession(ii),'k-','LineWidth',2);
        if mod(ii,2)
            title(['Training:',num2str(ii-fix(ii/2))]);
        else
            title(['Testing:',num2str(ii-fix(ii/2))]);
        end
        grid on;
        if max(num/nStimuliInEachSession(ii)) > max_yval
            max_yval = max(num/nStimuliInEachSession(ii));
        end
    end


    max_xval = max(respLengths_n);
    linkaxes(dist_h);
    xlim([0,max_xval]);
    ylim([0,max_yval]);
    [ax1,h1]=suplabel('Response length');
    [ax2,h2]=suplabel('probability','y');
    set(h1,'FontSize',12);
    set(h2,'FontSize',12);

% for 12 sessions recordings
% % else
%     resp_dist_h = figure();
%     session_vector = [1;cumsum(nStimuliInEachSession)];
%     dist_h = zeros(1,nSessions/2);
%     max_yval = 0;
%     count = 1;
%     for ii = 1:2:nSessions
%         num1 = hist(respLengths_n(session_vector(ii):session_vector(ii+1)),0:max(respLengths_n));
%         num2 = hist(respLengths_n(session_vector(ii+1):session_vector(ii+2)),0:max(respLengths_n));
%         dist_h(count) = subplot(nSessions/2,2,count);
%         plot(0:max(respLengths_n),num1/nStimuliInEachSession(ii),'k-','LineWidth',2);
%         hold on
%         plot(0:max(respLengths_n),num2/nStimuliInEachSession(ii),'r-','LineWidth',2);
%         grid on;
%         if max(num2/nStimuliInEachSession(ii)) > max_yval
%             max_yval = max(num2/nStimuliInEachSession(ii));
%         end
%         count = count + 1;
%     end
% 
% 
%     max_xval = max(respLengths_n);
%     linkaxes(dist_h);
%     xlim([0,max_xval]);
%     ylim([0,max_yval]);
%     [ax1,h1]=suplabel('Response length');
%     [ax2,h2]=suplabel('probability','y');
%     set(h1,'FontSize',12);
%     set(h2,'FontSize',12);
% end