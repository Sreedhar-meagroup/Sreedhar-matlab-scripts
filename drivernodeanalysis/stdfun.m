function f = stdfun(t,params)
f = params(1)./(1+((t-params(2))/params(3)).^2) + params(4);
