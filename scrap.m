% -------------------------------------------------------------------------------------
% Purpose: Collection of random code snippets.
% Author: Sreedhar S Kumar
% Date: 24.06.2013
%--------------------------------------------------------------------------------------
% MATLAB Version 7.12.0.635 (R2011a)
% MATLAB License Number: 97144
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% MATLAB                                                Version 7.12       (R2011a)
% Simulink                                              Version 7.7        (R2011a)
% Data Acquisition Toolbox                              Version 2.18       (R2011a)
% Fixed-Point Toolbox                                   Version 3.3        (R2011a)
% Image Processing Toolbox                              Version 7.2        (R2011a)
% MATLAB Compiler                                       Version 4.15       (R2011a)
% Neural Network Toolbox                                Version 7.0.1      (R2011a)
% Parallel Computing Toolbox                            Version 5.1        (R2011a)
% Signal Processing Toolbox                             Version 6.15       (R2011a)
% Statistics Toolbox                                    Version 7.5        (R2011a)
% Wavelet Toolbox                                       Version 4.7        (R2011a)
%--------------------------------------------------------------------------------------
%% This code snippet was to check if the deadtime condition has been succesfully enforced by the tweaked meabench source code
flag=0; 
for ii=0:59
inachannel=sp_aft2.time(sp_aft2.channel==ii);
if min(diff(inachannel))<=2e-3
    disp('ALERT');
    flag=1;
    break
end
end
if ~flag
disp('That''s good news.')
end

%% To generate sorted histogram of channels initiating n/w bursts
datName = '130612_4225_spontaneous.spike';
spikes=loadspike(datName,2,25);
burst_detection = burstDetAllCh_sk(spikes);
[bursting_channels_mea, network_burst, network_burst_onset] = Networkburst_detection(datName,spikes,burst_detection,10);
close all
[Delay_hist_fig nr_starts, EL_return] = NB_sequences(datName,network_burst, 0,1,bursting_channels_mea);

%% to generate figure of NB initiation alone (+sum of cfp) with HW channels (1-60)
% figure(2)
%subplot(1,2,1)
datRoot = {'130311_4105', '130311_4106', '130311_4108', '130312_4096', '130313_4107', '130313_4104'};
for count = 1:size(datRoot,2)
    dat_NBs = [datRoot{count},'_NBStarts.mat'];
    load(dat_NBs);
    bar(EL_array,nr_starts(sort_ind))
    set(gca,'XTick',1:length(sort_ind),'xtickLabel',num2str(active_EL(EL_array((sort_ind)))'+1));
    xlabel(' electrode' )
    ylabel(' Nr. of NB starts' );
    title(['total of ', num2str(nr_NB),' NBs detected'])
    load([datRoot{count},'_cfp.mat']);
    [sum_cfp, idx_cfp] = sort(sum(cfprobability),'descend');
    firstTen = sum_cfp(1:10);
    firstTen_norm = firstTen*nr_starts(sort_ind(1))/firstTen(1);
    hold on
    plot(firstTen_norm,'.-r', 'LineWidth',2,'MarkerSize',18);
    fpath = 'C:\Sreedhar\Lat_work\Closed_loop\misc';
    saveas(gcf, fullfile(fpath,[datRoot{count},'_NBs']), 'epsc');
    close all, clearvars -except datRoot count
end
%% simple raster
for ii=0:59
    inachannel=spikes.time(spikes.channel==ii);
    plot(inachannel,ones(1,size(inachannel,2))*ii,'.','linewidth',1)
    hold on
    clear inachannel
end
hold off
%% gathering culprits_starts into a variable
culpritsl5_starts = zeros(size(culpritsl5_log,1),1);
for ii = 1:length(culprits2_log)
    culpritsl5_starts(ii,1) = culpritsl5_log{ii,2}(1);
end
% all_starts = zeros(size(network_burst,1),1);
% for ii = 1:length(network_burst)
%     all_starts(ii,1) = network_burst{ii,2}(1);
% end
lgths = zeros(size(network_burst,1),1);
for ii = 1:length(network_burst)
    lgths(ii,1) = size(network_burst{ii,1},1);
end
%% Example of removing some ticks and labels
x = 0:.01:20;
y = sin(x);
plot(x,y)
set(gca,'Xtick',0:pi/2:x(end));
blah = num2cell(0:pi/2:x(end));
for ii = 1:size(blah,2)
    if mod(ii,2) ~= 0        
    blah{ii} = '';
    else
        if ii>2
            blah{ii} = [num2str(ii-1),'\frac{pi}{2}'];
        else
            blah{ii} = '\frac{pi}{2}';
        end
    end
end
set(gca,'Xticklabel',blah);
line([0,x(end)],[0 0],'Color','k');
%% Waterfall plot for NAMASEN
data = '4';
cnt = 1;
for ii=0:59
    fid = fopen(['PEDOT_data-',data,'_filt0001_',num2str(hw2cr(ii)),'.dat']);
    if fid>0
        final{cnt} = textscan(fid,'%f %f','headerLines',2);
        fclose(fid);
        cnt = cnt + 1;
    end 
end
Z = zeros(length(final),length(final{1}{1}));
X = final{1}{1};
for ii=1:length(final)
Z(ii,:) = final{ii}{2};
end
Y = 1:length(final);
% h = waterfall (X,Y,Z);
% CD = get (h, 'CData');
% CD(1,:) = nan;
% CD(end-2:end,:) = nan;
% set (h, 'CData', CD);


A = Z;
A(A>0)=0;
A=abs(A);
surf(X,Y,A); shading interp
xlabel('Time (s)')
ylabel('Channel#')
zlabel('Voltage (\muV)')
