% training encoder: fisher vector
% return: the encoding model

function [sigTrain, modelFV, success] = trainEncoderFV(bofTrain, param)

    if ~iscell(bofTrain) 
        error('Format error of the 1st two inputs\n');
    end    
    success = true; 
    if iscell(bofTrain{1})
        bcell = true; bmat = false;
    elseif ismatrix(bofTrain{1})
        bcell = false; bmat = true;
    end
    
    train_data  =   [];
    nTrain  =   numel(bofTrain);

    for i=1:nTrain
        if bcell
            train_data  = cat(1, train_data, cell2mat(bofTrain{i}));
        elseif bmat
            train_data  = cat(1, train_data, bofTrain{i});
        end
    end


    val_param = validateFVparam(param);
    K = val_param.K;
    
	if size(train_data,1) < 3*K
        success = false;
        modelFV = [];
        return;
    end
    
    Regularize = val_param.Regularize;
    Replicates = val_param.Replicates;
    CovType    = val_param.CovType;

    GMModel = gmdistribution.fit(train_data, K, 'Regularize', Regularize, ...
                     'CovType', CovType,  'Replicates', Replicates);  
    mu          = GMModel.mu;
    covMats     = GMModel.Sigma;
    w           = GMModel.PComponents;

    fprintf(1, 'Encoding of training data...\n');
    [muSigTrain, covSigTrain] = FVEncoding(bofTrain, K, mu, covMats, w);   
    sigTrain    = [muSigTrain covSigTrain];

     
    modelFV = validateFVmodel;
    modelFV.GMModel = GMModel;
%     modelFV.sigTrain = sigTrain;
    
    
end