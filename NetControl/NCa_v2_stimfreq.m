% another satellite to NCa_v2


%% Stimulus frequency distribution
% IstimI_session = diff(stimTimes(session_vector(1)+1:session_vector(2)));
% timeVec = 0:max(IstimI_session);
% counts = histc(IstimI_session,timeVec);
% figure();
% bar(timeVec,counts,'histc');
max_yval = 0;
for ii = 1:nSessions
    IstimI_session = diff(stimTimes(session_vector(ii)+1:session_vector(ii+1)));
    timeVec = 0:max(IstimI_session);
    counts = histc(IstimI_session,timeVec);
    stimdist_h(ii) = subplot(3,2,ii);
    plot(timeVec,counts/sum(counts),'k-','LineWidth',2);
    axis tight;
    if mod(ii,2)
        title(['Training:',num2str(ii-fix(ii/2))]);
    else
        title(['Testing:',num2str(ii-fix(ii/2))]);
    end
    grid on;
    if max(counts/sum(counts)) > max_yval
        max_yval = max(counts/sum(counts));
    end
end

% max_xval = max(diff(stimTimes));
% linkaxes(stimdist_h);
% xlim([0,max_xval]);
% ylim([0,max_yval]);
[ax1,h1]=suplabel('IstimI [s]');
[ax2,h2]=suplabel('probability','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);


%% IstimI evolution

for ii = 1:nSessions
    IstimI_session = [NaN, diff(stimTimes(session_vector(ii)+1:session_vector(ii+1)))];
    timeVec = session_vector(ii)+1:session_vector(ii+1);
    stimevol_h(ii) = subplot(3,2,ii);
    plot(timeVec,IstimI_session,'k.'); box off;
    axis tight;
    if mod(ii,2)
        title(['Training:',num2str(ii-fix(ii/2))]);
    else
        title(['Testing:',num2str(ii-fix(ii/2))]);
    end
    
    if max(counts/sum(counts)) > max_yval
        max_yval = max(counts/sum(counts));
    end
end
[ax1,h1]=suplabel('stim no.');
[ax2,h2]=suplabel('IstimI [s]','y');
set(h1,'FontSize',12);
set(h2,'FontSize',12);

%% Binned evolution
binSize = 100;
timeVec = 0:binSize:max(stimTimes);
counts = histc(stimTimes,timeVec);
figure();
bar_h = bar(timeVec,counts/binSize,'histc'); hold on;
plot(stimTimes(session_vector(2:end-1)), max(counts/binSize)*ones(size(stimTimes(session_vector(2:end-1)))),'r^');
box off;
set(bar_h,'EdgeColor','w','FaceColor','k');
axis tight;
xlabel('Time [s]','FontSize',14);
ylabel('Stimulus frequency','FontSize',14);
