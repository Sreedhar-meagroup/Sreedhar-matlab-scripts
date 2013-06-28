%a Discrete Fourier Transformation (DFT) to analyze the raw signal
% The Frequency resolution is determined by the size of the measurement
% window, namelsy \delta_f=1/(T_measure) wit t_measure=size of measurement
% window. The maximal detectable frequency is limited by the sampling
% frequency (Nyqvist theorem). f_max = 1/2*f_sample. E.G. with a sampling
% frequency of f_sample = 25kHz, we can detect signals upto 12.5 kHz
addpath('C:\Meabench\Data\Stimulus')% Here are the data files
addpath('C:\Program Files\Matlab71\work\mfiles') %here are Michaels mfiles 
addpath('C:\Program Files\Matlab71\work\Meabench\matlab') %here are Meabenchs internal mfiles
addpath('C:\Meabench\Data') %here are the raw data files
%
rawdataname='Noisenocable.raw';
range=2; % a user settable factor for conversion from digital steps to electrode uV, possible is 0,1,2,3 see mfile loadraw
Y=loadraw(rawdataname,range);

SAMPLEFREQ=25000;
windowlength=10;  %this is the measurement window, in secs
frequencyresolution=1/windowlength;  %the frequencyresolution depends on the measurement window
maxfrequency=2000;  %maximum frequency which should be plotted
frequencybins=0:frequencyresolution:maxfrequency;

windowstart=2*SAMPLEFREQ;  %position in the raw data (index) where the window starts
windowend=windowstart+windowlength*SAMPLEFREQ; %the end of the window (index)
indices=(windowstart:windowend)+1;
frequencies=0:frequencyresolution:maxfrequency;

%hwel=33 %choose an electrode (hardware)
%hfig1=figure;
hfig2=figure;
for hwel=0:63;
%     hwel
    % figure(hfig1);
     rawdata=Y(hwel+1,indices)-mean(Y(hwel+1,indices));%i.e. we cut ourt our window from the original raw data
      % we substract the mean to get rid of a DC offset, which would lead to an a frequencyamplitude at f=0Hz;
     [xposi,yposi]=hw2cr(hwel);
 plotpos=xposi+8*(yposi-1);
%hsub=subplot(8,8,plotpos);
% plot(0:1/SAMPLEFREQ:windowlength,rawdata)
% title(['channel ', num2str(hw2cr(hwel)),' (',num2str(hwel),')']);
% ylim([-50 50]);
% xlim([0 windowlength])

 figure(hfig2);
 FT=fft(rawdata); %The resulting FFT amplitude is A*n/2, where A is the original amplitude and n is the number of FFT points. 
% %This is true only if the number of FFT points is greater than or equal to the number of data samples. If the number of FFT 
% %points is less, the FFT amplitude is lower than the original amplitude by the above amount.
% 
 FTpower=FT.*conj(FT)/length(indices);  %FTpower has the same length as the rawdata vector, but the second part of the vector is redundant. The first half
%                                        %gives the frequecny amplitude, with
%                                        %the freqresolution given above and
%                                        %the maximum freq as the Nyqvist
%                                        %frequency
hsub=subplot(8,8,plotpos);
plot(frequencybins,FTpower(1:length(frequencybins)))
ylim([0 2500]);
title(['channel ', num2str(hw2cr(hwel)),' (',num2str(hwel),')']);
end;

figure(hfig2);  %labeling for FFT plot
subplot(8,8,1)
xlabel('frequency [Hz]');
ylabel('rel. power');
title({['Power Spectrum for ', rawdataname];[];[]; ['channel 11 (60)']});

% figure(hfig1); %labeling for raw data plot
% subplot(8,8,1)
% xlabel('time [sec]');
% ylabel('Voltage uV');
% title({['Recording: ',rawdataname]; [];['channel 11 (60)']});


