function [score errorResults]=isolationScore(spikeCluster, noiseCluster)


% compute isolation score between a cluster of spikes and a noise cluster
% alternatively, the noise cluster can be a different spike cluster

% spikecluster, noisecluster: MxN matrices where m observations and N dimensions

% score is the isolation score; score=1: perfect isolation; score=0 no isolation at all
% errorResults(1) = numSpikes;
% errorResults(2) = numNoise;
% errorResults(3) = falsePositives;
% errorResults(4) = falseNegatives;
% errorResults(5) = falsePositivesError;
% errorResults(6) = falseNegativesError;

%   method based on Joshua et al. 2007  "Quantifying the isolation quality of extracellularly recorded action potentials"
%   vlachos@bccn.uni-freiburg.de  (2008)

%% Parameters
lambda = 10;
per = 0.05;         %percentage of smallest cluster to be assigned as a knn value


%% Main part
total=vertcat(spikeCluster,noiseCluster);                %put spikes and noise spikes into one matrix
numSpikes = size(spikeCluster,1);
numNoise = size(noiseCluster,1);


distTotal = pdist(total);                                   %compute distance for total events (spikes+noise) 
distance = squareform(distTotal);                           %distance(i,j): the distance from event i to event j


if trace(distance)~=0
    warning('Diagonal is not zero'); %#ok<WNTAG>
end

distSpikes = distance(1:numSpikes, 1:numSpikes);             %distance within spike cluster
distNoise = distance(numSpikes+1:end,numSpikes+1:end);       %distance within noise cluster
distSN = distance(1:numSpikes,numSpikes+1:end);              %distance from spikes to noise
 
d0 = mean(mean(distSpikes));                                   %average distance within spike cluster
%if d0==0, d0=1;end

distSpikesExp = exp(-distSpikes*(lambda/d0));                  %exponential form of distance for spikes cluster
distSNExp = exp(-distSN*(lambda/d0));                          %exponential form of distance for spikes to noise

%subtract one from each row to set the distance for the same spike to zero;
sumSpikes = sum(distSpikesExp - eye(numSpikes));   
sumSN = sum(distSNExp,2)'; 


correctProbS = sumSpikes ./  (sumSpikes + sumSN);
score = mean(correctProbS);


%% Perform k-nearest neigbhours test to get an estimate of false positives and false negatives


[sortedDistance  sortedIndex ]  = sort(distance);

%set knn value to per% of the smallest cluster  
knn  = round(per*min(numSpikes, numNoise ));


kNeighboursIndex = sortedIndex(2:knn+1,:);  % Ignore first row - it is the self distance

%matrix temp contains 1s for distances to spike events and -1s for distances to noise events
temp  = ones(size(kNeighboursIndex));
noiseIndex = kNeighboursIndex > numSpikes;   
temp(noiseIndex) = -1;

%sum up the columns of the matrix
errors = sum(temp,1);       %always sum over the columns, even if temp has only one row

%negative values for spike events mean that most of the knn neigbours are noise events, that is false positives
%positve values for noise events mean that most of the knn neigbours are spike events, that is false negatives
falsePositives  =  nnz((errors(1:numSpikes))<0); 
falseNegatives =   nnz((errors(numSpikes+1:end))>0);
falsePositivesError = falsePositives / numSpikes;
falseNegativesError =  falseNegatives/ numSpikes;

errorResults(1) = numSpikes;
errorResults(2) = numNoise;
errorResults(3) = falsePositives;
errorResults(4) = falseNegatives;
errorResults(5) = falsePositivesError;
errorResults(6) = falseNegativesError;

fprintf('\nScore: %.4f \n',score)
fprintf('numSpikes: %d ,  numNoise: %d \n',numSpikes,numNoise)
fprintf('falsePositives: %d ,  falseNegatives: %d \n',falsePositives,falseNegatives)
fprintf('falsePositivesRatio: %.3f ,  falseNegativesRatio: %.3f \n',falsePositivesError,falseNegativesError)



