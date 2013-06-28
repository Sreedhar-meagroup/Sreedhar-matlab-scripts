neurons_per_mm2=100;
r=30:5:100
for i=1:15
     radius=r(i);
     radius=radius/1000;
     nu=radius^2*pi*neurons_per_mm2
    for k=0:5
        p(i,k+1)=exp(-nu)*(nu^k)/factorial(k);
    end;
end
hfig=figure
plot(0:5,p(:,:))  %plots a set of lines with the radius as a parameter
%for i=1:length(r)
legend_h=get(hfig,'Children');
legend(legend_h,num2str(r'));
%end
title({['prob. for no. of neurons in a circular area of radius r'];['assuming discrete poisson process, rate-factor ',num2str(neurons_per_mm2),'neurons per mm^2']});
xlabel('no of neurons')
ylabel('probability')