%05/02/07
%Introducing the "van Ooyen burst measure" as previously discussed
%in the group and now taken from the paper "A new measure for
%bursting"R.A.J. van Elburg, Arjen van Ooyen, Neurocomputing 58-60, p.
%497-502 (2004)


lower_lim=0;
upper_lim=7000;

for ch=0:63
    ch_ind   = find(ls.channel==ch & ls.time>lower_lim & ls.time<upper_lim);
    if (length(ch_ind)<10)
        B_two(ch+1)   = 0;
        B_twovar(ch+1)= 0;
        continue
    end
    ch_times = ls.time(ch_ind);
    %calculate the ISI with the fct diff
    ch_ISI   = diff(ch_times);
    %
    %B_two(ch+1)       = 1 - (mean(ch_ISI(2:end).*ch_ISI(1:end-1))/(mean(ch_ISI)^2));
    B_twovar(ch+1)    = (2*cov(ch_ISI) - cov(ch_ISI(2:end) + ch_ISI(1:end-1)))/(2*(mean(ch_ISI))^2);
    B_three(ch+1)     = (3*cov(ch_ISI) - cov(ch_ISI(3:end) + ch_ISI(1:end-2)))/(3*(mean(ch_ISI))^2); 
end



%generate a Poissonian spike train
train_length=10000;
poisson_rate=30;
poisson_train=zeros(1,train_length);
poisson_train(1)=0;
for i=2:train_length
    poisson_train(i)=poisson_train(i-1)+poissrnd(poisson_rate,1,1)/100;
end



    





    

