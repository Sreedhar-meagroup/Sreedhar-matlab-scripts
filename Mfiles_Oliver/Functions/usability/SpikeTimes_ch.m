%function SpikeTimes_ch
%returns the spiek times of ch CH (MEA), between time START and END (in sec),spiek information from structure ls
function [spike_times] = SpikeTimes_ch(ls,START,END,CH)
   spike_times = ls.time(find(ls.time>START & ls.time<END & ls.channel==cr2hw(CH)));

