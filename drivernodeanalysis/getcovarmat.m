function covmat = getcovarmat(data,varargin)
% Function retunrs covariance matrix of multielectrode input data
% INPUT ARGS:
% data: Structure returned by functions spontaneousData() or stimulatedData()
% varargins: as parameter, value pairs:
% options: 'binsize' (s), 'winofint' (s), 'nblks', 'cutoff' (0<x<1)
%     examples:
%       spon_data = spontaneousData();
%       covmat = getcovmat(spon_data,'nblks',6)
%       covmat = getcovmat(spon_data,'binsize',5e-3)
% OUTPUT ARG:
% Structure with fields...
% covmat.filename      = <data filename>
% covmat.nBlocks       = <no: of blocks data has been chopped into>
% covmat.nSpPerBlk     = <no: of spikes per block>
% covmat.blkduration   = <duration of each block>
% covmat.covar         = <cell array of covmats of each block>
% covmat.binsize       = <binsize>
% covmat.winofinterest = <the max pairwise lag>
% covmat.nActiveEl     = <no: of electrodes active>
% covmat.remarks       = <optional; user may add later>
% -------------------------------------------------------------------------------------

% defaults (you can change these using varargin)
binsize  = 10e-3;
winofint = 0.5; % time window of interest
nblks    = 6;
cutoff   = 0.008; %an electrode considered active if atleast 0.8% of total spikes in data


if mod(nargin,2)
    pvpmod(varargin);
else
    disp('Check input arguments');
end

spks      = data.Spikes;
spks_blk  = cell(nblks,1);
nspperblk = cell(nblks,1);
covmat_blk= cell(nblks,1);
tstep     = round(spks.time(end)/nblks);
maxlag    = winofint/binsize;
activeEl  = [];
for ii = 0:59
    if length(find(spks.channel==ii))>cutoff*length(spks.time)
        activeEl = [activeEl, ii+1];
    end
end
nactiveel = length(activeEl);

for blk  = 1:nblks
    tstr = find(spks.time>(blk-1)*tstep+1,1,'first');
    tend = find(spks.time<blk*tstep,1,'last');
    
    spks_blk{blk}.time    = spks.time(tstr:tend); 
    spks_blk{blk}.channel = spks.channel(((blk-1)*tstep+1):blk*tstep);
    nspperblk{blk}        = length(spks_blk{blk}.time);
    
    inAChannel = cell(60,1);
    for ii = 0:59
       inAChannel{ii+1,1} = spks_blk{blk}.time(spks_blk{blk}.channel==ii);
    end  
    mintime = min(spks_blk{blk}.time);
    maxtime = max(spks_blk{blk}.time);
    binvec  = mintime:binsize:(maxtime-binsize);
    X = zeros(nactiveel,length(binvec));
    for ii = 1:nactiveel
        X(ii,:) = histc(inAChannel{activeEl(ii)},binvec);
    end 
   covmat_blk{blk} = computexcovmat(X,maxlag,nactiveel);
end


covmat.filename      = data.fileName;
covmat.nBlocks       = nblks;
covmat.nSpPerBlk     = nspperblk;
covmat.blkduration   = tstep;
covmat.covar         = covmat_blk;
covmat.binsize       = binsize;
covmat.winofinterest = winofint;
covmat.nActiveEl     = nactiveel;
covmat.remarks       = '';