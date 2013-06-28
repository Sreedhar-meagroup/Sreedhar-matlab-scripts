%function [estimates, model] = power_law_datafit(xdata, ydata)
%
%
%input:
% xdata:               vector of x-data values
% 
% 
% ydata:               vector of y-data values
% 


% output:
% 
% estimates:           two parameters C and D from the fit function
%                      y=C*x^D
%                      
%  model:               A function handle to the fitted function
%                       should be called with the estimated parameters to
%                       get a data fit
% 
% 
% 
%
function [estimates, model] = power_law_datafit(xdata, ydata)
% Call fminsearch with random starting points for the parameters.
start_point = rand(1, 2);
model = @powerlawfun;
estimates = fminsearch(model, start_point);
% powerlawfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for C*x^D - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = powerlawfun(params)
        C      = params(1);
        D      = params(2);
        FittedCurve = C*xdata.^D;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end