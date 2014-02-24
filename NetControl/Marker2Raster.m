function Marker2Raster(~,~,spks, stimTimes, mod_NB_onsets, NB_ends)
% Marker2Raster plots a raster 10 s pre and 5 s post a stimulus (chosen by
% the cursor) during a training or testing session.

    p = get(gca,'CurrentPoint');
    stimNo = round(p(1,1));
    psSil = p(1,2);
    disp(['Stimulus number: ',num2str(stimNo)]);
    disp(['Silence: ',num2str(psSil),'s']);
    plotTimeSlice(spks,stimTimes(stimNo)-10,stimTimes(stimNo)+5,'nb',mod_NB_onsets,NB_ends,'resp');
    hold on;
    plot(stimTimes(stimNo),0,'r^');
    hold off;
end