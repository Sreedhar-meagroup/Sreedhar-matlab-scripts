%plots PSTH diagrams for all 8x8 channels or for selected ones, binwidth
%and psth window can be set
%15/10/06 changed the plot command to a stairs plot and center the values
%around the middle of the bin. as recently suggested bu Uli, this was not the
%case yet for the diagrams on the berlin poster


%samplestep=0.00004;  %i.e 40 us


% PSTH fuer einzelne Kanaele
%UNITLENGTH=25;  % number samples per ms

abstaende=diff(ls.time(find(ls.channel==61))); % Nur zur Info: Abstaende der Stimuli
stimpositionen=find(ls.channel==61); % suche, wo in Kanal Analog1 Stimuli auftauchen
stimzeitpunkte=ls.time(stimpositionen); % Das sind die Zeiten aller Stimuli
TRIALS=length(stimzeitpunkte);

ersterstimulus=2;
letzterstimulus=TRIALS;
reichweite=2.5 % Halbe Breite des PSTH-Fensters in Samplesteps
binweite=0.01;  %in seconds

hfig=figure;
psthvector=zeros(64,2*reichweite/binweite); % In diesen Vector wird hineinsummiert

for kan=0:63
    kan
    anzahlresponses=zeros(1,letzterstimulus);
    kontrollzaehler=zeros(1,letzterstimulus);
    kanalindex=find(ls.channel==kan & ls.time>stimzeitpunkte(1)-reichweite & ls.time<stimzeitpunkte(end)+reichweite);
    kanalzeiten=ls.time(kanalindex);
    
for aktuellstimnr=ersterstimulus:letzterstimulus
 
    aktuellzeit=stimzeitpunkte(aktuellstimnr);
    aktuellresponse=find(kanalzeiten>=(aktuellzeit-reichweite) & kanalzeiten<(aktuellzeit+reichweite));
    responsezeiten=kanalzeiten(aktuellresponse); % Das sind die Zeiten aller Responses innerhalb des PSTH-Fensters
    anzahlresponses(aktuellstimnr)=length(aktuellresponse); % Nur zur Info: Anzahl der Responses im aktuellen Fenster
    %
    % jetzt wird das psth-Fenster abgegrast:
    for binpos=1:length(psthvector)
        linkerrand=aktuellzeit-reichweite+(binpos-1)*binweite;
        imbin=length(find(responsezeiten>=linkerrand & responsezeiten<(linkerrand+binweite))); % Anzahl der Responses im Bin
        psthvector(kan+1,binpos)=psthvector(kan+1,binpos)+imbin; % Hier werden die Treffer aufsummiert
        kontrollzaehler(aktuellstimnr)=kontrollzaehler(aktuellstimnr)+imbin; % summiert zur Kontrolle die Responses im aktuellen Fenster
    end
    % weiter mit naechstem Stimulus
end
    xvec=([-reichweite:binweite:reichweite-binweite])+binweite/2;    % this is done to draw the values around the bin center

    [xposi,yposi]=hw2cr(kan);
    plotpos=xposi+8*(yposi-1);
    hsub=subplot(8,8,plotpos);
    stairs(xvec,psthvector(kan+1,1:length(xvec)));    % use the stairs fct, is probably better than the normal plot command since it does not plot diagonal connection lines between values
    title(['channel ',num2str(hw2cr(kan))]);
    
end
hchil=get(hfig,'Children');
set(hchil(:),'Xlim',[-reichweite reichweite],'YLim',[0 (max(max(psthvector(1:60,:))))]); % automatisch
%set(hchil(:),'YLim',[0 20]); % manuell

hsub=subplot(8,8,1);
htit=title({[datname];['PSTH, sumation for stimuli ',num2str(ersterstimulus),' to ',num2str(letzterstimulus), ' - bin width=',num2str(binweite*1000),'ms'];[ ];['channel ',num2str(hw2cr(60))]}, 'Interpreter','none');




%PSTHs for selected channels separately
selected_mea=[25 72 84] %]
selectedchannels=cr2hw(selected_mea);  %select channels based on Hardware specifications
channelcount=length(selectedchannels);
subplotsizecolumn=ceil(channelcount);
subplotsizerow=ceil(channelcount/subplotsizecolumn);
selectedfig=figure;

%to nomalize the PSTH on rate {hz} in a  trial
norm_fact=binweite*(letzterstimulus-ersterstimulus+1);
for i=1:channelcount;
    kan=selectedchannels(i);
    selectedhsub(i)=subplot(subplotsizecolumn, subplotsizerow,i);% a figure handle for every subplot
    plot(xvec,psthvector(kan+1,1:length(xvec))/norm_fact);
    title([' channel ',num2str(hw2cr(kan))], 'FontSize', 14);
    xlabel('time r.t. stimulus [sec]', 'FontSize',14);
    ylabel('rate in trial [Hz]', 'Fontsize',14);
end;
   selectedchil=get(selectedfig,'Children');

hsub=subplot(subplotsizecolumn,subplotsizerow,1);
htit=title({[datname];['Stimulation  for ',num2str(TRIALS),' trials'] ;['PSTH, bin width = ', num2str(binweite*1000), ' ms' ];['channel ',num2str(selected_mea(1))]},'Interpreter','none','Fontsize',14);



