
% train an encoder: Fisher vector
% return: the trained encoder
function [sigTrain, modelRF, success ] = ...
                    trainEncoderRF(bofTrain, labelsTrain, param)
    
    if ~iscell(bofTrain) 
        error('Format error of the 1st 2 parameters\n');
    end
     
    success = true;
    
    if iscell(bofTrain{1})
        bcell = true; bmat = false;
    elseif ismatrix(bofTrain{1})
        bcell = false; bmat = true;
    end
    
    nClasses = length(unique(labelsTrain));
    train_data  =   [];
    train_label =   [];
    nTrain  =   size(bofTrain,1);

    for i=1:nTrain
        if bcell
            train_data      = cat(1, train_data, cell2mat(bofTrain{i}));
        elseif bmat
            train_data      = cat(1, train_data, bofTrain{i});
        end
        nSubsequences      = size(bofTrain{i},1);
        train_label     = cat(1, train_label, labelsTrain(i)*ones(nSubsequences,1));
    end
   

    val_param = validateRFparam(param);
    NTrees  = val_param.NTrees;
    Method  = val_param.Method;
    nBins   = val_param.nbins;
    B = TreeBagger(NTrees,train_data, train_label, 'Method', Method);
    
    % encode each time series in a way similar to soft-assignment
    sigTrain = RFEncoding(B, bofTrain, nClasses, nBins);
    
    modelRF = validateRFmodel;
    modelRF.B = B;
    modelRF.nbins = nBins;
    modelRF.nclasses = nClasses;
%     modelRF.sigTrain = sigTrain;
%     modelRF.labelsTrain = labelsTrain;
    
    
  
end