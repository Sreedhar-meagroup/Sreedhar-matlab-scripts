
minx = 1; 
maxx = 1000;
% x = minx:maxx; % for discrete plots
x = 1:length(timeVec);
fineness = 1/100; 
finex = minx:fineness:maxx;
dim = 3;
% y = randi(2,dim,size(x,2))-1;
% y = [zeros(1,50), ones(1,50); zeros(1,30), ones(1,50), zeros(1,20);  zeros(1,30), ones(1,60), zeros(1,10)];
y = coords;

% figure to plot the stems
% h1 =  figure;
% figure
% for ii = 1:dim
%     figh(ii) = subplot(3,1,ii);
%     stem(x,y(ii,:));
% %     ylim([-0.5, 1.5]);
% end


FWHM = 8;
sig = FWHM/sqrt(8*log(2));
% kerny = exp(-(finex-250).^2/(2*sig^2));
% figure
% plot(finex, kerny);

sy = zeros(size(y));
for ii = 1:dim
    for xi = x
      kerny_i = exp(-(x-xi).^2/(2*sig^2));
%       a(xi) = sum(kerny_i);
      kerny_i = kerny_i / sum(kerny_i);  
      sy(ii,xi)  = sum(y(ii,:).*kerny_i);
    end
end

% figure(h1)
% for ii = 1:dim
%     subplot(3,1,ii)
%     hold on;
%     plot(x,sy(ii,:),'r')
%     ylim([-0.5, 1.5]);
% end
% linkaxes(figh, 'x');


% Normalizing the sy
% for ii = 1:dim
% %     if max(sy(ii,:))
%         sy(ii,:) = sy(ii,:)/max(sy(ii,:));
% %     end
% end


% c = colorGradient([0 0 1], [1 0 0],length(x));
% h2 = figure();
figure(h2);
hold on
% for ii = 1:length(sy(1,:)) 
%     plot3(sy(1,ii),sy(2,ii),sy(3,ii),'.','MarkerSize',3,'Color',c(ii,:));
% end
% hold on
% view(3);grid on;
plot3(sy(1,:),sy(2,:),sy(3,:),'color',c(jj,:),'LineWidth',2); view(3); grid on ;
% plot3(sy(1,:),sy(2,:),x); view(2); grid on;


respMetric = mean(sqrt(sy(1,:).^2 + sy(2,:).^2))/sqrt(dim);
respMetric_raw = mean(sqrt(y(1,:).^2 + y(2,:).^2))/sqrt(dim);

% disp(['The normalized mean response metric = ', num2str(respMetric)]);