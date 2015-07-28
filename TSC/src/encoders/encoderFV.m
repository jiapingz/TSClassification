
function [sigTrain, sigTest, success, t_train ,t_test] = encoderFV(bofTrain, bofTest, param)

    if ~iscell(bofTrain) || ~iscell(bofTest)        
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
        sigTrain = [];
        sigTest = [];
        t_train = 0;
        t_test = 0;
        return;
    end
    
    Regularize = val_param.Regularize;
    Replicates = val_param.Replicates;
    CovType    = val_param.CovType;

    t1 = clock;
    GMModel = gmdistribution.fit(train_data, K, 'Regularize', Regularize, ...
                     'CovType', CovType,  'Replicates', Replicates);
    mu          = GMModel.mu;
    covMats     = GMModel.Sigma;
    w           = GMModel.PComponents;

    fprintf(1, 'Encoding of training data...\n');
    [muSigTrain, covSigTrain] = FVEncoding(bofTrain, K, mu, covMats, w);
    t2 = clock;
    t_train = etime(t2,t1);
    
    t1 = clock;
    fprintf(1, 'Encoding of test data...\n');
    [muSigTest, covSigTest]   = FVEncoding(bofTest, K, mu, covMats, w);
    t2 = clock;
    t_test = etime(t2,t1);
    
    sigTrain    = [muSigTrain covSigTrain];
    sigTest     = [muSigTest covSigTest];

    % l2 normalization
%     sigTrain = sigTrain ./repmat(sqrt(sum(sigTrain.^2,2)),1,size(sigTrain,2));
%     sigTest = sigTest ./repmat(sqrt(sum(sigTest.^2,2)),1,size(sigTest,2));

end