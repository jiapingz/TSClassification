% vector quantization: use k-means to get the vocabulary, and then use hard
% assignment to represent each activity as a histogram over vocabulary

function [symbolsTrain, symbolsTest] = symbolizationKMeans2(seqTrain, seqTest, K)
    nTrain  =   size(seqTrain,1);
    nTest   =   size(seqTest,1);
    
    idxTrain = [];
    bofeatsTrain = [];
    for i=1:nTrain
        idxTrain = cat(1, idxTrain, i*ones(size(seqTrain{i},1),1));
        if iscell(seqTrain{i})
            bofeatsTrain  = cat(1, bofeatsTrain, cell2mat(seqTrain{i}));
        elseif ismatrix(seqTrain{i})
            bofeatsTrain  = cat(1, bofeatsTrain, seqTrain{i});
        else
            error('unsupported format of the 1st input\n');
        end
    end
    
    fprintf(1,'K-means to get the vocabulary\n');
    [idx2CTrain,Centers] = ...
        kmeans(bofeatsTrain, K, 'emptyaction','singleton', 'replicates', 1);
    
    % bow of training samples
    idx2CTraining = cell(nTrain,1); 
    symbolsTrain = cell(nTrain,1);
    for i=1:nTrain
        flag = idxTrain == i;
        idx2CTraining{i} = idx2CTrain(flag);
        symbolsTrain{i} =  idx2CTraining{i}; 
    end
    
    % bow of testing samples
    idx2CTesting = cell(nTest,1);
    symbolsTest = cell(nTest,1);
    for i=1:nTest
        if iscell(seqTest{i})
            ibofTest = cell2mat(seqTest{i});
        elseif ismatrix(seqTest{i})
            ibofTest = seqTest{i};
        end
        nSeqs = size(seqTest{i},1);
        idxSeqs = zeros(nSeqs,1);
        for j=1:nSeqs
           [~, idxSeqs(j)] = ...
               min(sum((repmat(ibofTest(j,:), K,1) - Centers).^2, 2));
        end
        idx2CTesting{i} = idxSeqs;
        symbolsTest{i}  = idxSeqs; 
    end
    
end