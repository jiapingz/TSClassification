% train encoder: bag of words
% return: a trained bow

function [sigTrain, modelBoW,  success] = trainEncoderBoW(bofTrain, K)

    narginchk(2,2);
    success = true;
    nTrain  =   numel(bofTrain);
     
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
        modelBoW = [];
        return;
    end
    
    fprintf(1,'K-means to get the vocabulary\n');
    [idx2CTrain,Centers] = ...
        kmeans(bofeatsTrain, K, 'emptyaction','singleton', 'replicates', 3);
    
        % bow of training samples
    idx2CTraining = cell(nTrain,1); 
    sigTrain = zeros(nTrain,K);
    for i=1:nTrain
        flag = idxTrain == i;
        idx2CTraining{i} = idx2CTrain(flag);
        [sigTrain(i,:), ~] = hist(idx2CTraining{i}, 1:K);
    end

    modelBoW = validateBoWmodel;
    modelBoW.clusterCenters = Centers;
%     modelBoW.sigTrain = sigTrain;
    
end
