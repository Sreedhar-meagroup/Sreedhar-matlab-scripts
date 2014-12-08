function params = cfpfit(t,y)
fun = @(params)cfpfun(params,y,t);

M = 1;
T = 1;
w = 10;
offset = 0;

params0 = [M,T,w,offset];
[params,~] = fminunc(fun,params0);