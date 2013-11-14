function f = exp_model(t,C)
f = C(1).*(1 - exp(-C(2).*t));
