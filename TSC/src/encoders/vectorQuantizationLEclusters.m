% vector quantization: use k-means to get the vocabulary, and then use hard
% assignment to represent each activity as a histogram over vocabulary

function [bowTrain, bowTest, entropies] = vectorQuantizationLEclusters(bofTrain, labelTrain, nClasses,...
                                             bofTest, K)
    nTrain  =   size(bofTrain,1);
    nTest   =   size(bofTest,1);
    
    idxTrain = [];
    bofeatsTrain = [];
    labelTrainMat = [];
    for i=1:nTrain
        idxTrain = [idxTrain; i*ones(size(bofTrain{i},1),1)];
        bofeatsTrain  = [bofeatsTrain; cell2mat(bofTrain{i})];
        labelTrainMat = [labelTrainMat; labelTrain(i)*ones(size(bofTrain{i},1),1)];
    end
    
    fprintf(1,'K-means to get the vocabulary\n');
    [idx2CTrain,Centers] = ...
        kmeans(bofeatsTrain, K, 'emptyaction','drop');
    
    K = length(unique(idx2CTrain));
    
    % compute entropy of each cluster
    entropies = zeros(K,1);
    for i=1:K
        i_idx = i == idx2CTrain;
        i_labels = labelTrainMat(i_idx,:);
        [nele, ~] = hist(i_labels, 1:nClasses);
        nele = nele/sum(nele);
        nele = nele(find(nele));
        entropies(i) = -sum(log2(nele).*nele);        
    end
    
    % bow of training samples
    idx2CTraining = cell(nTrain,1); 
    bowTrain = zeros(nTrain,K);
    for i=1:nTrain
        flag = idxTrain == i;
        idx2CTraining{i} = idx2CTrain(flag);
        [bowTrain(i,:), ~] = hist(idx2CTraining{i}, 1:K);
    end
    
    % baw of testing samples
    idx2CTesting = cell(nTest,1);
    bowTest = zeros(nTest,K);
    for i=1:nTest
        ibofTest = cell2mat(bofTest{i});
        nSeqs = size(bofTest{i},1);
        idxSeqs = zeros(nSeqs,1);
        for j=1:nSeqs
           [~, idxSeqs(j)] = ...
               min(sum((repmat(ibofTest(j,:), K,1) - Centers).^2, 2));
        end
        idx2CTesting{i} = idxSeqs;
        [bowTest(i,:), ~] = hist(idxSeqs,1:K);
    end
    
end
