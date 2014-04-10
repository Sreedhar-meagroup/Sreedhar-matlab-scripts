Burst = temp1;
SpikeBurstNumber = temp2;
% Plot results 
figure; rasterplot_so(Spike.T,Spike.C,'b-');

figure, hold on 

% Order y-axis channels by firing rates 
tmp = zeros( 1, max(Spike.C)-min(Spike.C) ); 
for c = min(Spike.C):max(Spike.C) 
tmp(c-min(Spike.C)+1) = length( find(Spike.C==c) ); 
end 
[tmp ID] = sort(tmp); 
OrderedChannels = zeros( 1, max(Spike.C)-min(Spike.C) ); 
for c = min(Spike.C):max(Spike.C) 
OrderedChannels(c-min(Spike.C)+1) = find( ID==c-min(Spike.C)+1 ); 
end 


% Raster plot 

plot( Spike.T, OrderedChannels(1+Spike.C), 'k.' ) 
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

 