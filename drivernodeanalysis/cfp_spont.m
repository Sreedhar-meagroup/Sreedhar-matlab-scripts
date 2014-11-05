    binsize = 0.5e-3; %0.5 ms bin
    nbins   = 10e-3/binsize;
    binvec = linspace(0,10e-3-binsize,nbins);
    spks = spon_data.Spikes;
    
for ii = 1:1
    
    spikepresence = histc(spks.time,binvec);
    nspikes = sum(spikepresence);
    
    
    
    