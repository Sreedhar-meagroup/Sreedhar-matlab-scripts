%% comparing ISI threshold and ISIN threshold
spontaneousData();
[NB_extrema, Burst] = sreedhar_ISIN_threshold(spks);

%% plotting
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end


    figure();
    
    fig1ha(1) = subplot(2,1,1);
    hold on;
    Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
    Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);
    rasterplot_so(spks.time,spks.channel,'b-');
    set(gca,'XTick',[]);
    set( get(fig1ha(1),'YLabel'), 'String', sprintf('ISI threshold (%d NBs)\nChannels',length(NB_ends)),'FontWeight','Bold');
    set(gca,'TickDir','Out');
    
    
    fig1ha(2) = subplot(2,1,2);
    hold on
    Xcoords = [Burst.T_start;Burst.T_start;Burst.T_end;Burst.T_end];
    Ycoords = 61*repmat([0;1;1;0],size(Burst.T_end));
    patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.35); 
    rasterplot_so(spks.time,spks.channel,'k-');
    set( get(fig1ha(2),'YLabel'), 'String', sprintf('ISI_{N=10} threshold (%d NBs)\nChannels',length(Burst.T_end)),'FontWeight','Bold');
    set( get(fig1ha(2),'XLabel'), 'String', sprintf('Time [s]'),'FontWeight','Bold');

    pan xon;
    zoom xon;
    linkaxes(fig1ha, 'x');
    set(gca,'TickDir','Out');
    
%% NB widths
dt = 50; % ms
NBwidths_ISIt_ms = 1e3*(NB_ends - mod_NB_onsets);
Steps1 = 10.^[2:0.1:log10(max(NBwidths_ISIt_ms))];
counts_ISIt = histc(NBwidths_ISIt_ms, Steps1);

NBwidths_ISINt_ms = 1e3*(Burst.T_end - Burst.T_start);
Steps2 = 10.^[2:0.1:log10(max(NBwidths_ISINt_ms))];
counts_ISINt = histc(NBwidths_ISINt_ms, Steps2);

nbw_h = figure();
subplot(1,2,1)
hold on;
plot(Steps1,counts_ISIt/length(NB_ends),'r-','LineWidth',2);
plot(Steps2,counts_ISINt/length(Burst.T_end),'g-','LineWidth',2);

set(gca,'xscale','log');
ylabel('Probability','FontSize',14);
xlabel('NB width [ms]','FontSize', 14);
set(gca, 'FontSize', 12);
set(gca, 'TickDir', 'Out');
% legend('ISI','ISI_N');
legend('boxoff');

myfun = @(x) size(x.time,2);
nSpikesPerNB_ISIt = cellfun(@(x) myfun(x),NB_slices);
nSpikesPerNB_ISINt = Burst.S;
Steps3 = 10.^[1:0.1:log10(max(nSpikesPerNB_ISIt))];
Steps4 = 10.^[1:0.1:log10(max(nSpikesPerNB_ISINt))];

counts_ISIt = histc(nSpikesPerNB_ISIt, Steps3);
counts_ISINt = histc(nSpikesPerNB_ISINt, Steps4);

subplot(1,2,2)
hold on;
plot(Steps3, counts_ISIt/length(NB_ends),'r-','LineWidth',2);
plot(Steps4, counts_ISINt/length(Burst.T_end),'g-','LineWidth',2);
set(gca,'xscale','log');
xlabel('spikes per NB','FontSize', 14);
set(gca, 'FontSize', 12);
set(gca, 'TickDir', 'Out');
legend('ISI','ISI_N');
legend('boxoff');

%% If same start, what is the end like
counter = 1;
for ii = 1:length(NB_ends)
    temp = find(Burst.T_start > mod_NB_onsets(ii)-1e-3 & Burst.T_start < mod_NB_onsets(ii)+1e-3);
    if ~isempty(temp)
        loc1(counter) = ii;
        loc2(counter) = temp;
        counter = counter+1;
    end
end

% figure(); hold on;
% plot(NB_ends(loc1)-mod_NB_onsets(loc1),'r','LineWidth',2);
% plot(Burst.T_end(loc2)-Burst.T_start(loc2),'g','LineWidth',2);
% set(gca,'Yscale','log');
% xlabel('Index','FontSize', 14);
% ylabel('Burst width [s]','FontSize', 14);
% axis tight;

dnbw_h = figure(); hold on;
plot((Burst.T_end(loc2)-Burst.T_start(loc2)) - (NB_ends(loc1)-mod_NB_onsets(loc1))','.');
xlabel('Index','FontSize', 14);
ylabel('\Delta Burst width [s]','FontSize', 14);


print(nbw_h, '-depsc', ['C:\Sreedhar\Lat_work\NetControl\misc\work_documentation\figures\burst_detection\',datRoot(1:11),'_NB_dists','.eps'])
print(dnbw_h, '-depsc', ['C:\Sreedhar\Lat_work\NetControl\misc\work_documentation\figures\burst_detection\',datRoot(1:11),'_deltaBW','.eps'])
