function params = srpfit(t,acor,ccor)
fun = @(params)srpfun(params,acor,ccor,t);

M = 1;
T = 1;
w = 0.1;
offset = 0;

params0 = [M,T,w,offset];
[params,~] = fminunc(fun,params0);