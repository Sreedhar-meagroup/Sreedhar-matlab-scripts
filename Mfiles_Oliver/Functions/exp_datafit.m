%exp fit, taken from the matlab help, as a start
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
%                      y=A*exp(-lambda.x)
%                      
%  model:               A function handle to the fitted function
%                       should be called with the estimated parameters to
%                       get a data fit
% 
% 
% 
%
function [estimates, model] = exp_datafit(xdata, ydata)
% Call fminsearch with random starting points for the parameters.
start_point = rand(1, 2);
model = @expfun;
estimates = fminsearch(model, start_point);
% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A * exp(-lambda * xdata) - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = expfun(params)
        A = params(1);
        lambda = params(2);
        FittedCurve = A .* exp(-lambda * xdata);
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end