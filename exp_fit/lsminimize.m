function g = lsminimize(C,y,t)
g = sum((exp_model(t,C) - y).^2);