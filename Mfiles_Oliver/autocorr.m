addpath('/scratch.local/Michael/matlab') % Pfad fuer MEABENCH-Funktionen
addpath('/scratch.local/Michael') % Pfad, wo meine Files liegen
addpath('/data/s8mipfiz/matlab')
addpath('/data/s8mipfiz')
%
datname='t_27_6a.spike'
%
ls=loadspike_noc(datname) % ohne Kontext


% autocorrelation

% Gewuenschten Abschnitt aus der Zeitachse in Bins einteilen,
% Spikes in jedem Bin zaehlen
%
startsekunde=6500
endsekunde=7500
binweite=250; % in samples
%
samplestep=0.00004;
oatime=ls.time(find(ls.channel<60)); % Daten ohne Analog-Kanaele. Im folgenden ls.time durch oatime ersetzt!
startsample=startsekunde/samplestep
endsample=endsekunde/samplestep
startindex=find(oatime>startsample,1)
endindex=find(oatime>endsample,1)
zeitfenster=oatime(startindex:endindex);
anzahlbins=round((endsample-startsample)/binweite)
binvector=zeros(1,anzahlbins);
for aktuellbin=1:anzahlbins
    linkerrand=startsample+(aktuellbin-1)*binweite;
    imbin=length(find(zeitfenster>=linkerrand & zeitfenster<(linkerrand+binweite)));
    binvector(aktuellbin)=binvector(aktuellbin)+imbin;
end
figure
xvec=samplestep*([startsample:binweite:(endsample-binweite)]);
plot(xvec,binvector(1:length(xvec)));
title(['Spikes gebint von ',num2str(startsample*samplestep),' bis ',num2str(endsample*samplestep), ' sec - Binbreite=',num2str(1000*samplestep*binweite),'ms']);
    
% Eigentliche Autocorrelation

taumax=100; % Laenge des autocorr Diagramms in Sekunden
maxbinverschieb=taumax/(binweite*samplestep); % Um max. so viele bins wird der Vektor verschoben
autocorr=zeros(1,maxbinverschieb); % Vektor, in dem die Werte landen
vsv=binvector(1:(length(binvector)-maxbinverschieb)); % Verschiebevektor, hinten kuerzer
for av=1:maxbinverschieb
    vgv=binvector(av:av+length(vsv)-1);
    autocorr(av)=sum(vsv.*vgv);
end
autocorr=autocorr/autocorr(1); % Normieren auf 1
figure
xvec=([0:(binweite*samplestep):taumax-binweite*samplestep]);
plot(xvec,autocorr)
xlabel('tau [s]')
title(['Autocorrelation von ',num2str(startsample*samplestep),' bis ',num2str(endsample*samplestep), ' sec - Binbreite=',num2str(1000*samplestep*binweite),'ms']);
