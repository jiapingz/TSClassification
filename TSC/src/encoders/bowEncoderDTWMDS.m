% Encoding train & test time series by dynamic time warping
% (1) using multidimensional scaling to convert dissimilarity matrix of
% training sequence into vectors
% (2) using kmeans to cluster training vectors into K clusters;
% (3) encode training time series by bag of k-words
% (4) encode test time series by bag of words

% notes: only after we finished computing dynamic time warping distances,
% and after we use MDS to decompose DTW dissimilarity matrix into
% low-dimensional descriptors, can we call this function

% we pre-compute DTW distances & low-dimensional representations because of
% high computational complexity

% input:
% (4) kmeans clustering: nClusters = K
function [bowTrain, bowTest] = ...
            bowEncoderDTWMDS(pDTW, idxTrain, idxTest, idxSeqs, descriptorTrain, nClusters)
     
	nTStest     = length(idxTest);
    nTStrain    = length(idxTrain);
    
    %     
    idxTrainSeq = [];
    idxSeq2TS = [];
    for i=1:length(idxTrain)
        i_idx = idxTrain(i);
        idxTrainSeq = cat(1, idxTrainSeq, idxSeqs{i_idx}(:));
        idxSeq2TS   = cat(1, idxSeq2TS, i*ones(length(idxSeqs{i_idx}),1));
    end
    [idxTrainSeq, idx] = sort(idxTrainSeq, 'ascend');
    idxSeq2TS = idxSeq2TS(idx);
%     pDTWtrain = getpdist(pDTW, idxTrainSeq);
    
    
    % get index of test   
    idxTestSeq = [];
    cnt_test = zeros(length(idxTest),1);
    for i=1:length(idxTest)
        i_idx = idxTest(i);
        idxTestSeq = cat(1, idxTestSeq, idxSeqs{i_idx}(:));
        cnt_test(i) = length(idxSeqs{i_idx});       
    end
    cum_cnt_test = [0; cumsum(cnt_test)];
    
    idxMinTest2Train = zeros(size(idxTestSeq));
    for i=1:length(idxTestSeq)
        colEles     =   getColEntries(pDTW', idxTestSeq(i));
        colEles     =   colEles(idxTrainSeq);
        [~, idx]    =   min(colEles);
        idxMinTest2Train(i) = idxTrainSeq(idx);
    end
    
    idxMinTest2TrainCell = cell(nTStest,1);
    for i=1:nTStest
        idxMinTest2TrainCell{i} = idxMinTest2Train(cum_cnt_test(i)+1:cum_cnt_test(i+1));
    end
    
    % (3) kmeans to cluster vectors
	fprintf(1,'K-means to get the vocabulary\n');
    K = nClusters;
    [idx2C,~] = ...
        kmeans(descriptorTrain, K, 'emptyaction','singleton', 'replicates', 3);
    
%     clusters = cell(K,1);
%     vecs = cell(K,1);
%     for i=1:K
%         flag = idx2C == i;
%         clusters{i} = sequencesTrain(flag);
%         vecs{i} = descriptorTrain(flag,:);
%     end
%     mapSeq2Vec.seq = clusters;
%     mapSeq2Vec.vec = vecs;
    
	% (4) bow of training time series
    bowTrain = zeros(nTStrain,K);
    for i=1:nTStrain
        flag = idxSeq2TS == i;
        [bowTrain(i,:), ~] = hist(idx2C(flag), 1:K);
    end
    
    % (5) bow of test time series
    bowTest = zeros(nTStest,K);
    for i=1:nTStest
        i_idxMinTest2Train = idxMinTest2TrainCell{i};
        nSeqs = length(i_idxMinTest2Train);
        idx = zeros(nSeqs,1);
        for j=1:nSeqs
            idx(j) = find(idxTrainSeq == i_idxMinTest2Train(j));
        end
        [bowTest(i,:), ~] = hist(idx2C(idx), 1:K);
    end
    
    
   
end