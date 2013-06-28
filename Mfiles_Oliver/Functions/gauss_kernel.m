% %this fct returns  gauss-distributed values
% 
% input:
% x:     vector with values on x_axis
% nu:    mean value
% sigma: as in the gauss-distriburion, width of the curve
% 

% output: 
% y: y_values
% 

function y = gauss_kernel(x,nu,sigma)
normalization_factor = 1/(sigma*sqrt(2*pi));
y = normalization_factor*exp(-1/2*((x-nu)./sigma).^2);