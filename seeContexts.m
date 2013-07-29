function ph = seeContexts(choice,spikes)
%[spks, selIdx, rejIdx] = cleanspikes(spikes);
%allIdx = 1:length(spikes.time);
% stimIdx = find(spikes.channel>=60);
% rejIdx = allIdx(and(~ismember(allIdx,stimIdx),~ismember(allIdx,selIdx)));
%rejCtxts = spikes.context(:,rejIdx);
%choice = 'man'; % oder 'random';
%     if strcmpi(choice,'man')
%         rchoice = hwmany;
%         hwmany = 1;
%     end
%for ii = 1:hwmany
%    if ~strcmpi(choice,'man')
%        rchoice =  round(1 + (length(rejIdx)-1)*rand(1));
%    end
%    rawctxt = rejCtxts(:,rchoice);
%     first = rawctxt(15:35);
%     last = rawctxt(40:60);
%     dc1 = mean(first);
%     dc2 = mean(last);
%     v1 = var(first);
%     v2 = var(last);
%     dc = (dc1*v2+dc2*v1)/(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
%    rejCtxts(:,rchoice) = rawctxt;
%    peak = mean(rejCtxts(50:51,rchoice));
peak = mean(spikes.context(50:51,choice));
%     if ~strcmpi(choice,'man')
%         subplot(3,5,ii)
%     else
ph = plot(spikes.context(:,choice));
%    end
    %axis tight
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
    xlabel(['Time [ms]; timestamp: ',num2str(choice)]);
    ylabel('Voltage [\muV]'); axis tight;
%end