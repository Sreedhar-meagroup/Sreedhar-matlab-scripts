%% Analyzing raw data dents in MEABench

data = loadraw('140311_4513_raw.raw',2);
ch = 25; % hw+1
% slicing by window width
window1e3 = data(ch,1:10*25e3) - 683;
window500 = data(ch,15*25e3:25*25e3) - 683;
window200 = data(ch,30*25e3:40*25e3) - 683;
figure();
figha(1) = subplot(311);
title('1000 ms window'); hold on;
plot(linspace(1,10,length(window1e3)),window1e3);
box off;
figha(2) = subplot(312);
title('500 ms window'); hold on;
plot(linspace(1,10,length(window500)),window500);
box off;
figha(3) = subplot(313);
title('250 ms window'); hold on;
plot(linspace(1,10,length(window200)),window200);
box off;
linkaxes(figha,'x');
zoom xon;
pan xon;
suplabel('time [s]')
suplabel('Voltage [\mu V]','y');
