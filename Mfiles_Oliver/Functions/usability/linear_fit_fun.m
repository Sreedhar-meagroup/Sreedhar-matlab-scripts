function [estimates, model] = linear_fit_fun(xdata, ydata)
% Call fminsearch with a random starting point.
start_point = rand(1, 2);
model = @linear_fit;
estimates = fminsearch(model, start_point);
% linear_fit accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*xdata+B - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = linear_fit(params)
        A = params(1);
        B = params(2);
        FittedCurve = A .* xdata + B;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end