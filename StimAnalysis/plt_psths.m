function plt_psths(stim_data)
% PLT_PSTHS(stim_data) plots psths given stim_data structure generated in
% stimAnalysis_v4; as simple as that


stimSites  = stim_data.Electrode_details.stim_electrodes;
stimTimes  = stim_data.StimTimes;
nStimSites = length(stimSites);
spks       = stim_data.Spikes;
response_window = stim_data.Responses.response_window;
%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell in a cell structure.
% Layer 1 (outer cell) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x1 cell, each corresponding to a channel
% Layer 3 is a 50x1 cell, holding the periStim spike stamps corresponding to each of the 50 stimuli.

inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end
periStim = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            periStim{ii}{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes{ii}(jj)-0.05, inAChannel{kk}<stimTimes{ii}(jj)+response_window));
        end
    end
end

%%
% Binning, averaging and plotting all the PSTHs
listOfCounts_all = cell(1,nStimSites);
binSize = 5; % in ms
for ii = 1:nStimSites
    psth_h = genvarname(['psth_',num2str(ii)]);
    eval([psth_h '= figure();']);%, num2str(1+ii), ');']);
    handles(ii+1) = eval(psth_h);
    psth_sp_h = zeros(1,60); %psth subplot handles
    max_axlim = 0;
    for jj = 1:60
        bins = -50: binSize: response_window*1e3;
        count = 0;
        frMat = zeros(size(stimTimes{ii},2),length(bins));
        for kk = 1:size(stimTimes{ii},2)
            shiftedSp = periStim{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
                fr = zeros(size(bins));
                for mm = 1:length(bins)-1
                    fr(mm) = length(shiftedSp(and(shiftedSp>=bins(mm)*1e-3,shiftedSp<(bins(mm+1)*1e-3))));
                end
                count = count + 1;
                frMat(count,:) = fr;     
        end
        listOfCounts_all{1,ii}{jj,1} = count; 
        if count ==0, count=1; end
        
        %finding the right subplot position in a 6x10 array
        ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
        [row, col] = find(ch6x10_ch8x8_60 == jj);
        pos = 6*(row-1) + col;
        
        psth_sp_h(jj) = subplot(10,6,pos);
        shadedErrorBar(bins+binSize/2,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
        axis tight;
        line([0 0],[-0.5 max(1,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
        if jj == cr2hw(stimSites(ii))+1
            text(375,0.5,num2str(jj),'FontAngle','italic','Color',[1,0,0]);
        else
            text(375,0.5,num2str(jj),'FontAngle','italic');
        end
        
%         if ~or(mod(pos,6)==1,pos>54)
%             set(gca,'YTickLabel',[]);
%             set(gca,'XTickLabel',[]);
%         elseif pos>55
%             set(gca,'YTickLabel',[]);
%         elseif pos~=55
%             set(gca,'XTickLabel',[]);
%         end
        set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
        set(gcf,'WindowStyle','docked');

        if max(mean(frMat)+std(frMat)) > max_axlim
            max_axlim =  max(mean(frMat)+std(frMat));
        end
    end
%     linkaxes(psth_sp_h);
%     axis([-50 response_window*1e3 -0.5 max_axlim]);
    [ax1,h1]=suplabel('time[ms]');
    set(h1,'FontSize',16);
    [ax2,h2]=suplabel('Mean #spikes','y');
    set(h2,'FontSize',16);
    [ax4,h3]=suplabel(['PSTH (stimulation at ',num2str(stimSites(ii)),'^{cr} / ',num2str(cr2hw(stimSites(ii))+1),'^{hw+1})'],'t');
    set(h3,'FontSize',16);

end

