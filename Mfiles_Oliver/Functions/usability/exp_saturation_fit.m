%exp_saturation_fit, taken from the matlab help, as a start
%function [estimates, model] = exp_datafit(xdata, ydata)
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
% estimates:           two parameters A and lambda from the fit function
%                      y=A*(1 - exp(-lambda.x)), an exponential saturating
%                      function
%                      
%  model:               A function handle to the fitted function
%                       should be called with the estimated parameters to
%                       get a data fit
% 
% 
% 
%
function [estimates, model] = exp_saturation_fit(xdata, ydata)
% Call fminsearch with a random starting point.
start_point = rand(1, 2);
model       = @exp_sat_fun;
%old_opts    = optimset('fminsearch');
%new_opts    = optimset(old_opts,'MaxFunEvals',10000,'MaxIter',10000);
estimates   = fminsearch(model, start_point);
% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A * exp(-lambda * xdata) - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = exp_sat_fun(params)
        A           = params(1);
        lambda      = params(2);
        FittedCurve = A .*(1 - exp(-lambda * xdata));
        ErrorVector = FittedCurve - ydata;
        sse         = sum(ErrorVector .^ 2);
    end
end