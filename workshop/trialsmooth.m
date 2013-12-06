minx = 1; 
maxx = 1000;
x = minx:maxx; % for discrete plots
fineness = 1/100; 
finex = minx:fineness:maxx;
dim = 2;
y = randi(2,dim,size(x,2))-1;

% y = [zeros(1,50), ones(1,50); zeros(1,30), ones(1,50), zeros(1,20);  zeros(1,30), ones(1,60), zeros(1,10)];
h1 =  figure;
for ii = 1:dim
    subplot(3,1,ii)
    stem(x,y(ii,:));
    ylim([-0.5, 1.5]);
end


FWHM = 4;
sig = FWHM/sqrt(8*log(2));
kerny = exp(-(finex-250).^2/(2*sig^2));
figure
plot(finex, kerny);

sy = zeros(size(y));
for ii = 1:dim
    for xi = x
      kerny_i = exp(-(x-xi).^2/(2*sig^2));
      kerny_i = kerny_i / sum(kerny_i);
      sy(ii,xi)  = sum(y(ii,:).*kerny_i);
    end
end

figure(h1)
for ii = 1:dim
    subplot(3,1,ii)
    hold on;
    plot(x,sy(ii,:),'r')
    ylim([-0.5, 1.5]);
end


c = colorGradient([0 0 1], [1 0 0],maxx);
figure()
hold on
for ii = 1:length(sy(1,:)) 
    plot(sy(1,ii),sy(2,ii),'.','MarkerSize',20,'Color',c(ii,:));
end
hold on
plot3(sy(1,:),sy(2,:),x,'--');
respMetric = mean(sqrt(sy(1,:).^2 + sy(2,:).^2))/sqrt(dim);

disp(['The normalized mean response metric = ', num2str(respMetric)]);