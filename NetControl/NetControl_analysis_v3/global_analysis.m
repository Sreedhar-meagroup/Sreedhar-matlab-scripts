load('C:\Sreedhar\Mat_work\Closed_loop\workspace_garage\GlobalData_E6_onlySpontaneous.mat')

exp_sessions = fieldnames(GlobalData);
counter = 1 ;
myfun = @(x) size(x.time,2);
for ii = 1: numel(exp_sessions)
     if ii == 4 || ii == 8 || ii == 9, continue; end
%     final_learned(counter) = ImportantVars.(exp_sessions{ii}).learnedTime_s(end);%-0.2;
    Emodel_para(counter,:) = GlobalData.(exp_sessions{ii}).Emodel_para;
    meanrecChSp(counter) = mean(GlobalData.(exp_sessions{ii}).SpontaneousData.Post.RecChannelBursts.nSpikesperBurst);
    stdrecChSp(counter)= std(GlobalData.(exp_sessions{ii}).SpontaneousData.Post.RecChannelBursts.nSpikesperBurst);  
    nSpPerNB = cellfun(@(x) myfun(x),GlobalData.(exp_sessions{ii}).SpontaneousData.Post.NetworkBursts.NB_slices);
    meanNBSp(counter) = mean(nSpPerNB);
    stdNBSp(counter) = std(nSpPerNB);
    counter = counter+1;
end

%% rec channel bursts

p = polyfit(Emodel_para(2:end,1),meanrecChSp(2:end)',1);
pred = p(1)*Emodel_para(2:end,1) + p(2);
yresid = meanrecChSp(2:end)' - pred;
SSresid = sum(yresid.^2);
SStotal = (length(meanrecChSp(2:end))-1) * var(meanrecChSp(2:end));
rsq = 1 - SSresid/SStotal;

figure();
plot(Emodel_para(2:end,1),meanrecChSp(2:end),'.','MarkerSize',15);
set(gca,'FontSize',14)
set(gca, 'TickDir','Out')
xlabel('Model parameter A');
ylabel('Mean #spikes in SBs(only RC)');
box off;
hold on
plot(Emodel_para(2:end,1),pred,'r','LineWidth',2);
text(40,7,['R^2 = ',sprintf('%0.2f',rsq)],'FontSize',12,'FontWeight','Bold');



%% network bursts
p = polyfit(Emodel_para(1:end,1),meanNBSp(1:end)',1);
pred = p(1)*Emodel_para(1:end,1) + p(2);
yresid = meanNBSp(1:end)' - pred;
SSresid = sum(yresid.^2);
SStotal = (length(meanNBSp(1:end))-1) * var(meanNBSp(1:end));
rsq = 1 - SSresid/SStotal;

figure();
plot(Emodel_para(1:end,1),meanNBSp(1:end),'.','MarkerSize',15);
set(gca,'FontSize',14)
set(gca, 'TickDir','Out')
xlabel('Model parameter A');
ylabel('Mean #spikes in SBs (Network)');
box off;
hold on
plot(Emodel_para(1:end,1),pred,'r','LineWidth',2);
text(40,45,['R^2 = ',sprintf('%0.2f',rsq)],'FontSize',12,'FontWeight','Bold');
