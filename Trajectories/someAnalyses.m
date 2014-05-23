%% some analysis
load('C:\Sreedhar\Mat_work\Closed_loop\workspace_garage\ImportantVars.mat');
exp_sessions = fieldnames(ImportantVars);

counter = 1;
% figure(); hold on;
for ii = 1: numel(exp_sessions)
     if ii == 4 || ii == 8 || ii == 9, continue; end
    final_learned(counter) = ImportantVars.(exp_sessions{ii}).learnedTime_s(end);%-0.2;
    preSpont_NetPeaks(counter) = ImportantVars.(exp_sessions{ii}).preSpont.NetPeak(1)+0.5;
    postSpont_NetPeaks(counter) = ImportantVars.(exp_sessions{ii}).postSpont.NetPeak(1)+0.5;
    temp_net_pre = find(ImportantVars.(exp_sessions{ii}).preSpont.distData.timeVec>final_learned(counter),1,'first');
    temp_net_post = find(ImportantVars.(exp_sessions{ii}).postSpont.distData.timeVec>final_learned(counter),1,'first');
    temp_rc_pre = find(ImportantVars.(exp_sessions{ii}).preSpont.distData.timeVec_rc>final_learned(counter),1,'first');
    temp_rc_post = find(ImportantVars.(exp_sessions{ii}).postSpont.distData.timeVec_rc>final_learned(counter),1,'first');
    prob_interr_net_prepost(counter,1) = sum(ImportantVars.(exp_sessions{ii}).preSpont.distData.counts_norm(1:temp_net_pre));
    prob_interr_net_prepost(counter,2) = sum(ImportantVars.(exp_sessions{ii}).postSpont.distData.counts_norm(1:temp_net_post));
    prob_interr_rc_prepost(counter,1) = sum(ImportantVars.(exp_sessions{ii}).preSpont.distData.counts_norm_rc(1:temp_rc_pre));
    prob_interr_rc_prepost(counter,2) = sum(ImportantVars.(exp_sessions{ii}).postSpont.distData.counts_norm_rc(1:temp_rc_post));
    Emodel_para(counter,:) = ImportantVars.(exp_sessions{ii}).Emodel_para;
    counter = counter+1;
end

figure();

plot(prob_interr_net_prepost);%,prob_interr_net_prepost]
hold on
plot(postSpont_NetPeaks)
plot(final_learned,'r');
plot(Emodel_para(:,1)/50,'r--');


p = polyfit(Emodel_para(:,1),prob_interr_net_prepost(:,2),1);
pred = p(1)*Emodel_para(:,1) + p(2);
yresid = prob_interr_net_prepost(:,2) - pred;
SSresid = sum(yresid.^2);
SStotal = (length(prob_interr_net_prepost(:,2))-1) * var(prob_interr_net_prepost(:,2));
rsq = 1 - SSresid/SStotal;
figure()
plot(Emodel_para(:,1),prob_interr_net_prepost(:,2),'.','MarkerSize',15)
hold on
plot(Emodel_para(:,1),pred,'r','LineWidth',2);
text(40,0.1,['R^2 = ',sprintf('%0.2f',rsq)],'FontSize',12,'FontWeight','Bold');
box off;
set(gca,'FontSize',14)
xlabel('Exp model parameter, A');
ylabel('Learned disruption probability');