function g = srpfun(params,acor,ccor,t)
est_ccor = conv(acor,stdfun(t,params));
est_ccor = est_ccor(1:length(acor));
g = sum((ccor - est_ccor).^2);