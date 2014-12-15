function data_out = perimeananalysis(data_in, plotID,tag)


spcounts = data_in.spcounts;
stimTimes = data_in.stimdetails.stimTimes;
stimInd = data_in.stimdetails.stimInd;


%% section 1: Indicator function

overmean = find(spcounts>mean(spcounts));
undermean = find(spcounts<mean(spcounts));
overmeanphstd = find(spcounts>mean(spcounts)+0.5*std(spcounts));
undermeanmhstd = find(spcounts<mean(spcounts)-0.5*std(spcounts));
overmeanpstd = find(spcounts>mean(spcounts)+std(spcounts));
undermeanmstd = find(spcounts<mean(spcounts)-std(spcounts));

%% plots 1 
if strcmpi(plotID,'1')||strcmpi(plotID,'all')
figure;
subplot(3,1,1)
plot(overmean,ones(size(overmean)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on; 
plot(undermean,zeros(size(undermean)),'rv','MarkerSize',7,'MarkerFaceColor','r');

box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim index, n')
% ylabel('I(n)');
title(['IF around mean: ',tag],'Interpreter','Latex');
legend('supra','infra');


subplot(3,1,2)
plot(overmeanphstd,ones(size(overmeanphstd)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on; 
plot(undermeanmhstd,zeros(size(undermeanmhstd)),'rv','MarkerSize',7,'MarkerFaceColor','r');

box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim index, n')
ylabel('I(n)');
title(['IF around mean $\pm \frac{1}{2}$ std: ',tag],'Interpreter','Latex');
% legend('supra','infra');


subplot(3,1,3)
plot(overmeanpstd,ones(size(overmeanpstd)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on; 
plot(undermeanmstd,zeros(size(undermeanmstd)),'rv','MarkerSize',7,'MarkerFaceColor','r');

box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('Stim index, n')
% ylabel('I(n)');
title(['IF around mean $\pm$ std: ',tag],'Interpreter','LaTeX');
% legend('supra','infra');

end

%% plots1t; with time as x axis
if strcmpi(plotID,'1t')|| strcmpi(plotID,'all')
figure;
subplot(3,1,1)
plot(stimTimes{stimInd}(overmean),ones(size(overmean)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on; 
plot(stimTimes{stimInd}(undermean),zeros(size(undermean)),'rv','MarkerSize',7,'MarkerFaceColor','r');
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim index, n')
% ylabel('I(n)');
title(['IF around mean: ',tag],'Interpreter','Latex');
legend('supra','infra');


subplot(3,1,2)
plot(stimTimes{stimInd}(overmeanphstd), ones(size(overmeanphstd)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on;
plot(stimTimes{stimInd}(undermeanmhstd), zeros(size(undermeanmhstd)),'rv','MarkerSize',7,'MarkerFaceColor','r'); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim ind')
ylabel('I(n)');
title(['IF around mean $\pm \frac{1}{2}$ std: ',tag],'Interpreter','Latex');
% legend('supra','infra');

subplot(3,1,3)
plot(stimTimes{stimInd}(overmeanpstd), 0.35+ones(size(overmeanpstd)),'g^','MarkerSize',7,'MarkerFaceColor','g'); hold on;
plot(stimTimes{stimInd}(undermeanmstd), zeros(size(undermeanmstd)),'rv','MarkerSize',7,'MarkerFaceColor','r'); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('Time [s]')
% ylabel('Density');
% legend('supra','infra');
title(['IF around mean $\pm$ std: ',tag],'Interpreter','LaTeX');
end

%% section 2: Distribution of \Delta stimindices

overmean_dist = hist(diff(overmean),min(diff(overmean))-5:max(diff(overmean))+5);
overmean_dist = overmean_dist/sum(overmean_dist);
undermean_dist = hist(diff(undermean),min(diff(undermean))-5:max(diff(undermean))+5);
undermean_dist = undermean_dist/sum(undermean_dist);
overmeanphstd_dist = hist(diff(overmeanphstd),min(diff(overmeanphstd))-5:max(diff(overmeanphstd))+5);
overmeanphstd_dist = overmeanphstd_dist/sum(overmeanphstd_dist);
undermeanmhstd_dist = hist(diff(undermeanmhstd),min(diff(undermeanmhstd))-5:max(diff(undermeanmhstd))+5);
undermeanmhstd_dist = undermeanmhstd_dist/sum(undermeanmhstd_dist);
overmeanpstd_dist = hist(diff(overmeanpstd),min(diff(overmeanpstd))-5:max(diff(overmeanpstd))+5);
overmeanpstd_dist = overmeanpstd_dist/sum(overmeanpstd_dist);
undermeanmstd_dist = hist(diff(undermeanmstd),min(diff(undermeanmstd))-5:max(diff(undermeanmstd))+5);
undermeanmstd_dist = undermeanmstd_dist/sum(undermeanmstd_dist);

%% plots 2
if strcmpi(plotID,'2')|| strcmpi(plotID,'all')
figure;
subplot(3,1,1)
plot(smooth(overmean_dist,10,'lowess'),'g','LineWidth',2); hold on;
plot(smooth(undermean_dist,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('\Delta Stim ind')
% ylabel('p');
title(['Distribution of $\Delta$ indices dist around mean: ',tag],'Interpreter','Latex');
legend('supra','infra');

subplot(3,1,2)
plot(smooth(overmeanphstd_dist,10,'lowess'),'g','LineWidth',2); hold on;
plot(smooth(undermeanmhstd_dist,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('\Delta Stim ind')
ylabel('p');
title('Around mean $\pm \frac{1}{2}$ std','Interpreter','Latex');
% legend('supra','infra');

subplot(3,1,3)
plot(smooth(overmeanpstd_dist,10,'lowess'),'g','LineWidth',2); hold on;
plot(smooth(undermeanmstd_dist,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('\Delta Stim ind')
% ylabel('p');
title('Around mean $\pm$ std','Interpreter','Latex');
% legend('supra','infra');
end

%% section 3: Dynamics of the density of the indicator function 
binsize = 3;
[overmean_density, temp1] = hist(overmean,1:binsize:length(stimTimes{stimInd}));
[undermean_density, temp2] = hist(undermean,1:binsize:length(stimTimes{stimInd}));
[overmeanphstd_density, temp3] = hist(overmeanphstd,1:binsize:length(stimTimes{stimInd}));
[undermeanmhstd_density, temp4] = hist(undermeanmhstd,1:binsize:length(stimTimes{stimInd}));
[overmeanpstd_density, temp5] = hist(overmeanpstd,1:binsize:length(stimTimes{stimInd}));
[undermeanmstd_density, temp6] = hist(undermeanmstd,1:binsize:length(stimTimes{stimInd}));


%% plots3
if strcmpi(plotID,'3')|| strcmpi(plotID,'all')
figure;
subplot(3,1,1)
plot(temp1, smooth(overmean_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(temp2, smooth(undermean_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim ind')
% ylabel('Density');
title(['Around mean: ',tag]);
legend('supra','infra');


subplot(3,1,2)
plot(temp3, smooth(overmeanphstd_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(temp4, smooth(undermeanmhstd_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim ind')
ylabel('Density');
title('Around mean $\pm \frac{1}{2}$ std','Interpreter','Latex');
% legend('supra','infra');

subplot(3,1,3)
plot(temp5, smooth(overmeanpstd_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(temp6, smooth(undermeanmstd_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('Stim ind')
% ylabel('Density');
title('Around mean \pm std');
% legend('supra','infra');
end



%% plots3t; with time as x axis
if strcmpi(plotID,'3t')|| strcmpi(plotID,'all')
figure;
subplot(3,1,1)
plot(stimTimes{stimInd}(temp1), smooth(overmean_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(stimTimes{stimInd}(temp2), smooth(undermean_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim ind')
% ylabel('Density');
title(['Around mean: ',tag],'Interpreter','Latex');
legend('supra','infra');


subplot(3,1,2)
plot(stimTimes{stimInd}(temp3), smooth(overmeanphstd_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(stimTimes{stimInd}(temp4), smooth(undermeanmhstd_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
% xlabel('Stim ind')
ylabel('Density');
title('Around mean $\pm \frac{1}{2}$ std','Interpreter','Latex');
% legend('supra','infra');

subplot(3,1,3)
plot(stimTimes{stimInd}(temp5), smooth(overmeanpstd_density,10,'lowess'),'g','LineWidth',2); hold on;
plot(stimTimes{stimInd}(temp6), smooth(undermeanmstd_density,10,'lowess'),'r','LineWidth',2); hold off;
box off;
set(gca,'tickDir','Out');
set(gca,'FontSize',14);
xlabel('Time [s]')
% ylabel('Density');
title('Around mean $\pm$ std','Interpreter','Latex');
% legend('supra','infra');
end
%% Preparing data out
data_out.Indicatorfun.overmean = overmean;
data_out.Indicatorfun.undermean = undermean;
data_out.Indicatorfun.overmeanphstd = overmeanphstd;
data_out.Indicatorfun.undermeanmhstd = undermeanmhstd;
data_out.Indicatorfun.overmeanpstd = overmeanpstd;
data_out.Indicatorfun.undermeanmstd = undermeanmstd;
data_out.plt3t_times = stimTimes{stimInd}(temp5);
data_out.plt3t_yval = smooth(overmeanpstd_density,10,'lowess');
