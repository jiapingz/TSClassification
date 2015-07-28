% Encoding train & test time series by dynamic time warping
% (1) using multidimensional scaling to convert dissimilarity matrix of
% training sequence into vectors
% (2) using kmeans to cluster training vectors into K clusters;
% (3) encode training time series by bag of k-words
% (4) encode test time series by bag of words

% input:
% (1) seqTrain(cell): sampled sequences from each train time series
% (2) seqTest(cell): sampled sequences from each test time series
% (3) dimsMDS: using MDS to convert dissimilarity matrix to 'dimsMDS'-D
% vectors
% (4) kmeans clustering: nClusters = K
function [bowTrain, bowTest, mapSeq2Vec] = ...
            bowEncoderDTW(seqTrain, seqTest, dimsMDS, nClusters)
    if nargin ~= 4
        error('Make sure to input 4 parameters\n');
    end
    
    nTSTrain    = size(seqTrain,1);
    nTSTest     = size(seqTest,1);
    
    % (1) concatenate sequences from different time series together
    sequencesTrain = {};
    idxTrain = [];
    for i=1:nTSTrain
        sequencesTrain = [sequencesTrain; seqTrain{i}];
        idxTrain = [idxTrain; i*ones(size(seqTrain{i},1),1)];
    end
    
    % (2) using MDS to convert dissimilarity matrix into vectors
%     dVec = dDTW(sequencesTrain);
    
    % load descriptors
    load('/lab/jiaping/projects/google-glass-project/results/0826/MDSdescriptors.mat');
    
%     desSequencesTrain =  DTW2vec(sequencesTrain, dimsMDS);
    desSequencesTrain = descriptors;
    
    % (3) kmeans to cluster vectors
	fprintf(1,'K-means to get the vocabulary\n');
    K = nClusters;
    [idx2C,Centers] = ...
        kmeans(desSequencesTrain, K, 'emptyaction','singleton', 'replicates', 3);
    
    clusters = cell(K,1);
    vecs = cell(K,1);
    for i=1:K
        flag = idx2C == i;
        clusters{i} = sequencesTrain(flag);
        vecs{i} = desSequencesTrain(flag,:);
    end
    mapSeq2Vec.seq = clusters;
    mapSeq2Vec.vec = vecs;
    
	% (4) bow of training time series
    bowTrain = zeros(nTSTrain,K);
    for i=1:nTSTrain
        flag = idxTrain == i;
        [bowTrain(i,:), ~] = hist(idx2C(flag), 1:K);
    end
    
    % (5) bow of test time series
    bowTest =bowEncoderDTWtest(clusters, seqTest);
   
end