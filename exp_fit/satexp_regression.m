function x = satexp_regression(t,y)
func = @(C)lsminimize(C,y,t);
C0 = [1, 1];
[x,fval] = fminunc(func, C0);
end