% Response distribution

respdist_h = figure();
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