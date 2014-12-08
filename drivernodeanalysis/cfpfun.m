function g = cfpfun(params,y,t)
g = sum((stdfun(t,params) - y').^2);