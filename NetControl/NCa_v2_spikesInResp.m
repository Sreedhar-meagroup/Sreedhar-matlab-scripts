%% nSp diff cases
% arg1_bwerr = std(RecChannel_pre.nSpikesperBurst);
% arg2_bwerr = mean(RecChannel_pre.nSpikesperBurst);
% for ii = 1:nSessions
%     respL_n_swise{ii} = respLengths_n(session_vector(ii)+1:session_vector(ii+1));
%     arg1_bwerr(ii+1) = std(respL_n_swise{ii});
%     arg2_bwerr(ii+1) = mean(respL_n_swise{ii});
% end
% arg1_bwerr(end+1) = std(RecChannel_post.nSpikesperBurst);
% arg2_bwerr(end+1) = mean(RecChannel_post.nSpikesperBurst);
% 
% nSp_diffcases_h = figure();
%     barwitherr(arg1_bwerr,arg2_bwerr,'g','EdgeColor','None');
% if nSessions == 6
%     set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3','Post'});
% else
%     set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3',...
%         'Train4','Test4','Train5','Test5','Train6','Test6','Post'});
% end
% box off;
% set(gca,'FontSize',12);
% ylabel('No. of spikes');
% xticklabel_rotate;
% 

%%

preStim_burst = recSite_prestim_bursts(NetControlData);
preStim_Blengths = cellfun(@length, preStim_burst);

arg1_bwerr = zeros(nSessions+2,2);
arg2_bwerr = zeros(nSessions+2,2);
arg1_bwerr(1,1) = std(RecChannel_pre.nSpikesperBurst);
arg2_bwerr(1,1) = mean(RecChannel_pre.nSpikesperBurst);
% arg1_bwerr(1,2) = 0;
% arg2_bwerr(1,2) = 0;

for ii = 1:nSessions
    respL_n_swise{ii} = respLengths_n(session_vector(ii)+1:session_vector(ii+1));
    arg1_bwerr(ii+1,2) = std(respL_n_swise{ii});
    arg2_bwerr(ii+1,2) = mean(respL_n_swise{ii});
    arg1_bwerr(ii+1,1) = std(preStim_Blengths(session_vector(ii)+1:session_vector(ii+1)));
    arg2_bwerr(ii+1,1) = mean(preStim_Blengths(session_vector(ii)+1:session_vector(ii+1)));
end
arg1_bwerr(ii+2,1) = std(RecChannel_post.nSpikesperBurst);
arg2_bwerr(ii+2,1) = mean(RecChannel_post.nSpikesperBurst);
% arg1_bwerr(ii+2,2) = 0;
% arg2_bwerr(ii+2,2) = 0;

nSp_diffcases_h = figure();
barwitherr(arg1_bwerr,arg2_bwerr,1,'group','EdgeColor','None');
colormap cool
legend('Spontaneous','Evoked','Location','Best');
legend('boxoff');
axis tight;
set(gca,'TickDir','Out');
if nSessions == 6
    set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3','Post'});
else
    set(gca,'xticklabel',{'Pre','Train1','Test1','Train2','Test2','Train3','Test3',...
        'Train4','Test4','Train5','Test5','Train6','Test6','Post'});
end
box off;
set(gca,'FontSize',12);
ylabel('No. of spikes');
xticklabel_rotate([],45,[]);