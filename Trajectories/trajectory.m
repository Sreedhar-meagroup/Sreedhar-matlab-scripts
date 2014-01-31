%% trajectory in space
%131010_4346_StimEfficacy2.spike (26, 58, 60)
%130625_4205_StimEfficacy.spike (13, 25, 17), st:3
%131011_4350_stimEfficacy1 (36, 45, 48), st: 5
summed_effect = cell(5,1);
count = 1;
stimNo = 3;
for kk =  [10 15 20 25]; %
    h2 = figure();
    binSize = kk;
    binned = -50:binSize:500;
    c = colorGradient([0 0 0], [1 0 0],50);
    for jj = 1:50
        coords = zeros(3,length(binned));
        resps = [periStim{stimNo}{[13, 25, 17]}];
        for ii = 1:3
            shifted_ms = (resps{jj,ii}- stimTimes{stimNo}(jj))*1e3;
            [counts,timeVec] = hist(shifted_ms,binned);
%              counts(find(counts)) = 1; % counts could be anything
            coords(ii,:) = counts;
        end
        trialsmooth_mod;
        summed_effect{count}(:,:,jj) = sy;
    end
    count = count + 1;
    set(gca,'FontSize',14);
    title(['Trajectories with bin-size = ', num2str(kk),'ms'], 'FontSize',14);
     saveas(h2,['C:\Users\duarte\Desktop\fig_traj\130625_4205\trajFWHM8_',num2str(kk),'ms.eps'], 'psc2');
     close(h2);
end


