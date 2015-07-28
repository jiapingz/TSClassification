% vector quantization: use k-means to get the vocabulary, and then use hard
% assignment to represent each activity as a histogram over vocabulary

function [bowTrain, bowTest] = vectorQuantizationKMeans(bofTrain, bofTest, K)
    nTrain  =   size(bofTrain,1);
    nTest   =   size(bofTest,1);
    
    idxTrain = [];
    bofeatsTrain = [];
    for i=1:nTrain
        idxTrain = cat(1, idxTrain, i*ones(size(bofTrain{i},1),1));
        if iscell(bofTrain{i})
            bofeatsTrain  = cat(1, bofeatsTrain, cell2mat(bofTrain{i}));
        elseif ismatrix(bofTrain{i})
            bofeatsTrain  = cat(1, bofeatsTrain, bofTrain{i});
        else
            error('unsupported format of the 1st input\n');
        end
    end
    
    fprintf(1,'K-means to get the vocabulary\n');
    [idx2CTrain,Centers] = ...
        kmeans(bofeatsTrain, K, 'emptyaction','singleton', 'replicates', 1);
    
    % bow of training samples
    idx2CTraining = cell(nTrain,1); 
    bowTrain = zeros(nTrain,K);
    for i=1:nTrain
        flag = idxTrain == i;
        idx2CTraining{i} = idx2CTrain(flag);
        [bowTrain(i,:), ~] = hist(idx2CTraining{i}, 1:K);
    end
    
    % bow of testing samples
    idx2CTesting = cell(nTest,1);
    bowTest = zeros(nTest,K);
    for i=1:nTest
        if iscell(bofTest{i})
            ibofTest = cell2mat(bofTest{i});
        elseif ismatrix(bofTest{i})
            ibofTest = bofTest{i};
        end
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
