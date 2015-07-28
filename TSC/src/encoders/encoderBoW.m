% vector quantization: use k-means to get the vocabulary, and then use hard
% assignment to represent each activity as a histogram over vocabulary

% applicable cases:
% (1) univariate time series;
% (2) local descriptors are row vectors
% (3) local descriptors from the same time series can be orgnized in either
%     cell or matrix, row by row
function [bowTrain, bowTest, success] = encoderBoW(bofTrain, bofTest, K)
    error(nargchk(3,3,nargin));
    success = true;
    nTrain  =   numel(bofTrain);
    nTest   =   numel(bofTest);
    
    if iscell(bofTrain{1})
        bcell = true; bmat = false;
    elseif ismatrix(bofTrain{1})
        bcell = false; bmat = true;
    else
        error('Format error for the 1st two parameters\n');
    end
    
    idxTrain = [];
    bofeatsTrain = [];
    for i=1:nTrain
        idxTrain     = cat(1, idxTrain, i*ones(size(bofTrain{i},1),1));
        if bcell
            bofeatsTrain = cat(1, bofeatsTrain, cell2mat(bofTrain{i}));
        elseif bmat
            bofeatsTrain = cat(1, bofeatsTrain, bofTrain{i});
        end
    end
    
    if size(bofeatsTrain,1) < 3*K
        success = false;
        bowTrain = [];
        bowTest = [];
        return;
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
    
    % baw of testing samples
    idx2CTesting = cell(nTest,1);
    bowTest = zeros(nTest,K);
    for i=1:nTest
        if bcell
            ibofTest = cell2mat(bofTest{i});
        elseif bmat
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
