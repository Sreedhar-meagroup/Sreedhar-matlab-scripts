function seeContexts(choice,spikes)
figure();
if size(choice,2) == 1
    plotContexts(spikes,choice);
    title(['Timestamp: ',num2str(choice)]);
    xlabel('Time [ms]');
    ylabel('Voltage [\muV]');
else
    for ii = 1:size(choice,2)
        subplot(floor(sqrt(size(choice,2))),ceil(sqrt(size(choice,2))),ii);
        plotContexts(spikes, choice(ii));
    end
    [ax1,h1] = suplabel('Time [ms]');
    [ax2,h2] = suplabel('Voltage [\muV]','y');
end
end

function plotContexts(spikes,choice)
        peak = mean(spikes.context(50:51,choice));
        plot(spikes.context(:,choice));
        line([0 124],[0, 0],'Color','k');
        line(50*[1,1],[min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'color','k');
        line([37,37], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'linestyle',':','color','r');
        line([63,63], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'linestyle',':','color','r');
        line([45,45], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'linestyle','--','color','r');
        line([55,55], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'linestyle','--','color','r');
        line([25,25], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'color','k');
        line([75,75], [min(spikes.context(:,choice))-5, max(spikes.context(:,choice))+5],'color','k');

        line([0 124],[peak*.5, peak*.5],'LineStyle',':');
        line([0 124],[peak*.9, peak*.9],'LineStyle','--');
        line([0 124],spikes.thresh(choice)*ones(1,2));
        line([0 124],-spikes.thresh(choice)*ones(1,2));

        %set(gca,'Xticklabel',[]);
        set(gca,'XTick',0:25:125);
        set(gca,'XTicklabel',-2:3);
        xlabel(['timestamp: ',num2str(choice)]);
        axis tight;
end