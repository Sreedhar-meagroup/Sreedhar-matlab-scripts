%% getting the ISI_N threshold
SpikeTimes = spks.time;
Steps = 10.^[-5:.05:1.5];
N = 10;
valleyMinimizer_ms = HistogramISIn(SpikeTimes, N, Steps);

%% the burst detection
Spike.T = SpikeTimes;
Spike.C = spks.channel;
ISI_N = valleyMinimizer_ms/1e3; % in seconds


[Burst Spike.N] = BurstDetectISIn( Spike, N, ISI_N );

%% Plot results 

figure;
subplot(2,1,1)
rasterplot_so(Spike.T,Spike.C,'b-');

figure, hold on 

% Order y-axis channels by firing rates 
% tmp = zeros( 1, max(Spike.C)-min(Spike.C) );
% for c = min(Spike.C):max(Spike.C) 
% tmp(c-min(Spike.C)+1) = length( find(Spike.C==c) ); 
% end 
% [tmp ID] = sort(tmp); 
% OrderedChannels = zeros( 1, max(Spike.C)-min(Spike.C) ); 
% for c = min(Spike.C):max(Spike.C) 
% OrderedChannels(c-min(Spike.C)+1) = find( ID==c-min(Spike.C)+1 ); 
% end 


% Raster plot 

 plot( Spike.T, Spike.C, 'k.') 
% plot( Spike.T, OrderedChannels(1+Spike.C), 'k.' ) 
% set( gca, 'ytick', (min(Spike.C):max(Spike.C))+1, 'yticklabel', ... 
% ID-min(ID)+min(Spike.C) ) % set yaxis to channel ID 

% Plot times when bursts were detected 
ID = find(Burst.T_end<max(Spike.T)); 
Detected = []; 
for ii=ID 
Detected = [ Detected Burst.T_start(ii) Burst.T_end(ii) NaN ]; 
end 
zoom xon;
plot( Detected, 65*ones(size(Detected)), 'r', 'linewidth', 4 ) 

xlabel 'Time [sec]' 
ylabel 'Channel'  

 

%%

%     ha = tight_subplot(2,1,[.01 .03],[.1 .01],[.01 .01]);

make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.05], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end


    figure();
    fig1ha(1) = subplot(2,1,1);
%     axes(ha(1));
    hold on;
    Xcoords = [mod_NB_onsets';mod_NB_onsets';NB_ends';NB_ends'];
    Ycoords = 61*repmat([0;1;1;0],size(NB_ends'));
    patch(Xcoords,Ycoords,'r','edgecolor','none','FaceAlpha',0.35);
    rasterplot_so(Spike.T,Spike.C,'b-');
    set(gca,'XTick',[]);
%     set(gca,'FontSize',12,'FontWeight','Bold');
    set( get(fig1ha(1),'YLabel'), 'String', sprintf('ISI threshold\nChannels'),'FontWeight','Bold');
        set(gca,'TickDir','Out');
    
    
    fig1ha(2) = subplot(2,1,2);
%     axes(ha(2));
    hold on
    Xcoords = [Burst.T_start;Burst.T_start;Burst.T_end;Burst.T_end];
    Ycoords = 61*repmat([0;1;1;0],size(Burst.T_end));
    patch(Xcoords,Ycoords,'g','edgecolor','none','FaceAlpha',0.35);
    
    rasterplot_so(Spike.T,Spike.C,'k-');
    set( get(fig1ha(2),'YLabel'), 'String', sprintf('ISI_{N=10} threshold\nChannels'),'FontWeight','Bold');
    set( get(fig1ha(2),'XLabel'), 'String', sprintf('Time [s]'),'FontWeight','Bold');
%     ID = find(Burst.T_end<max(Spike.T)); 
%     Detected = []; 
%     for ii=ID 
%         Detected = [ Detected Burst.T_start(ii) Burst.T_end(ii) NaN ]; 
%     end
%     plot( Detected, 65*ones(size(Detected)), 'r', 'linewidth', 4 );
%     axis tight;

    pan xon;
    zoom xon;
    linkaxes(fig1ha, 'x');
    set(gca,'TickDir','Out');