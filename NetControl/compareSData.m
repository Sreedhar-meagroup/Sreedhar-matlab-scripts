%% Comparison of spontaneous activity before and afer the training and testing sessions
Spont = load('C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\NetControl\SBparameters.mat');
variables = fields(Spont);
CIDs = {'4346', '4350'};
sessions = {'s1', 's2'};
counter = 1;
figure();
suptitle('Parameters of spontaneous activity measured before training and testing sessions and after')
for ii = 1 : size(CIDs,2)
    for jj = 1 : size(sessions,2)
        dataset = [CIDs{ii},'_',sessions{jj}];
        if any(strcmp(variables, ['IBIs_',dataset,'_pre']))
            

            Grouped_data = [mean(eval(['Spont.IBIs_',dataset,'_pre'])), mean(eval(['Spont.nSpikesPerNB_',dataset,'_pre'])), mean(eval(['Spont.BDuration_s_',dataset,'_pre'])) ;...
                           mean(eval(['Spont.IBIs_',dataset,'_post'])), mean(eval(['Spont.nSpikesPerNB_',dataset,'_post'])), mean(eval(['Spont.BDuration_s_',dataset,'_post']))];
            norm_Grouped_data = Grouped_data./repmat(Grouped_data(1,:), size(Grouped_data,1),1);
            err_Grouped_data = [std(eval(['Spont.IBIs_',dataset,'_pre'])), std(eval(['Spont.nSpikesPerNB_',dataset,'_pre'])), std(eval(['Spont.BDuration_s_',dataset,'_pre'])) ;...
                               std(eval(['Spont.IBIs_',dataset,'_post'])), std(eval(['Spont.nSpikesPerNB_',dataset,'_post'])), std(eval(['Spont.BDuration_s_',dataset,'_post']))];
            norm_err_Grouped_data = err_Grouped_data./repmat(Grouped_data(1,:),size(Grouped_data,1),1);

    
            subplot(1,3,counter)
            h1 = barwitherr(norm_err_Grouped_data, norm_Grouped_data, 'grouped');
            hold on; axis square
            ylabel('Ratio');%,'FontSize',14);
            set(gca, 'XtickLabel', {'before', 'after'});% 'FontSize', 14);
            ylim([-1 5]);
            counter = counter + 1;
        end
    end
end
        

%% Comparison of spikes per channel per time during [presession-spont, training, testing, post-session spont.] in that order
spksPerCHPerTime = load('C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\NetControl\spksPerCHPerTime.mat');
spchpt(1,:) = struct2array(spksPerCHPerTime.s1_4346);
spchpt(2,:) = struct2array(spksPerCHPerTime.s2_4346);
spchpt(3,:) = struct2array(spksPerCHPerTime.s2_4350);

X = spchpt;
meansOfX = mean(X);
stdsOfX = std(X);
norm_meansOfX = meansOfX/meansOfX(1);
norm_stdsOfX = stdsOfX/meansOfX(1);
figure();
subplot(1,2,1)

h4 = barwitherr(norm_stdsOfX,norm_meansOfX);
box off;
title('Over all channels', 'FontSize', 12);
ylabel('Ratio', 'FontSize', 14);
set(gca,'tickDir','out');
set(h4,'FaceColor',[1,1,1]*0.5)
set(gca, 'XtickLabel', {'before session', 'training', 'testing', 'after session'}, 'FontSize', 14);
xticklabel_rotate([],45,[]);
% xticklabel_rotate;

%% Comparison of spikes per per time in the RECORDING channel during [presession-spont, training, testing, post-session spont.] in that order
spksRecCHPerTime = load('C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\NetControl\spksRecCHPerTime.mat');
spRecChpt(1,:) = struct2array(spksRecCHPerTime.Rec_s1_4346);
spRecChpt(2,:) = struct2array(spksRecCHPerTime.Rec_s2_4346);
spRecChpt(3,:) = struct2array(spksRecCHPerTime.Rec_s2_4350);

X = spRecChpt;
meansOfX = mean(X);
stdsOfX = std(X);
norm_meansOfX = meansOfX/meansOfX(1);
norm_stdsOfX = stdsOfX/meansOfX(1);
% figure();
subplot(1,2,2)
h4 = barwitherr(norm_stdsOfX,norm_meansOfX);
box off;
title('At the recording channel', 'FontSize', 12);
% ylabel('Ratio', 'FontSize', 14);
set(gca,'tickDir','out');
set(h4,'FaceColor',[1,1,1]*0.5)
set(gca, 'XtickLabel', {'before session', 'training', 'testing', 'after session'}, 'FontSize', 14);
 xticklabel_rotate([],45,[]);
% xticklabel_rotate;
suptitle('Normalized Spikes per time ');