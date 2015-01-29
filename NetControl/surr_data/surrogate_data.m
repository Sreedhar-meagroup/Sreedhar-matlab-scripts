nsb = 1e5;
h = 5;
dt = 0.5;

% IBI distribution (in s)
m = 4;
v = 2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
ibis = lognrnd(mu,sigma,1,nsb);


% %nsp global dist
% m = 85;
% v = 500;
% mu = log((m^2)/sqrt(v+m^2));
% sigma = sqrt(log(v/(m^2)+1));
% nsp_glob = lognrnd(mu,sigma,1,nsb);


%nsp single chan dist
nch = 1;
m = 10;
v = 10;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
nsp_single = round(lognrnd(mu,sigma,nch,nsb));


%SB width in seconds 
% slope ~ 3.4ms/spike
nbws = nsp_single.*3.4*1e-3;


%SB ends in seconds
nbends = cumsum(ibis) + nbws;

%SB starts in seconds
nbstarts = nbends - nbws; 

%stimulation times relative to a SB(0-5s in 0.5s steps)
stimtimes = (randi(11,1,nsb-h)-1).*dt;

x  = conv(nsp_single,ones(1,h));
k1 = mean(x(h:end));
k2 =0.2;
A = 15;
lambda = 1.25;
resp = zeros(1,nsb-h);
states = -ones(6,length(ibis));
states(2:end,h) = nsp_single(1:h)';
for sb = h:length(ibis)-1 
    st = sb-h+1;
    if nbends(sb) + stimtimes(st) < nbstarts(sb+1)
        stimstatus(st) = true;
        recfn = A*(1-exp(-lambda*stimtimes(st)));
        histfn = (sum(nsp_single(st:sb)) - k1)*k2;
        noise = 0;%round(1.5*randn);
        resp(st) = round(recfn+histfn+noise);
    else
        stimstatus(st) = false;
        resp(st) = nan;
    end
    states(3:end,sb) = states(2:end-1,sb-1);
    states(2,sb)     = nsp_single(sb);
end
resp(resp<0) = 0;
states(3:end,sb+1) = states(2:end-1,sb);
states(2,sb+1)     = nsp_single(sb+1);
states(1,h+1:end) = resp;

% trimming the stim times and responses to weed out missed opportunities
stimtimes_trim = stimtimes(stimstatus);
resp_trim = resp(stimstatus);
[sortedSil, indices] = sort(stimtimes_trim);
respOfSortedSil =  resp_trim(indices);
bplot_h = plt_respLength(sortedSil,respOfSortedSil,dt,'nspikes');
median_values = cell2mat(get(bplot_h(3,:),'YData'));
time = (0:length(median_values)-1)*dt;
emodel_para = satexp_regression(time', median_values);
emodel = exp_model(time',emodel_para);
hold on;
plot(emodel,'r','LineWidth',2);
legend(['{\it', sprintf('%.2f',emodel_para(1)),' (1 - e^{-',sprintf('%.2f',emodel_para(2)),' t} )}'],'location','best');
legend('boxoff');


%distribution of spikes in a burst
% t = 0:.001:0.999;
% y1 = exp(-((t-.15)/.075).^2)/.12;
% y2 = exp((-(t-.6).^2)/.2^2)/.3;
% y = (y1+y2)/sum(y1+y2);
% figure; plot(t,y);
% 
% count = 1;
% for ii = 1:length(ibis)
%     for part = 1:4
%         ind1 = (part-1)/4*length(t)+1;
%         ind2 = part/4*length(t);
%         nspinpart = round(sum(y(ind1:ind2))*nsp_single(ii));
%         tstep = nbws(ii)/(4*nspinpart);
%         for jj = 1:nspinpart
%          spikes.time(count) = nbends(ii)-nbws(ii)+jj*tstep;
%          count = count+1;
%         end
%     end
% end

