% encode time series using fisher vector

% (1) first fit a gmm;
% (2) and then get the fisher vector

% (1) fit gmm

function [acc, powers] = svmFVEncoder(train_data, train_labels, ...
                                test_data, test_labels, FVencoder, normalization)
                            
    if ~exist('train_data', 'var') || isempty(train_data) || ~iscell(train_data)
        error('train_data should be a cell array\n');
    end
    
    if ~exist('test_data', 'var') || isempty(test_data) || ~iscell(test_data)
        error('test_data should be a cell array\n');
    end

    train_samples  =   [];
    nTrain  =   size(train_data,1);

    for i=1:nTrain
        train_samples = cat(1, train_samples, train_data{i});
    end

    % prune those features, whose values are constant, since constant numbers
    % don't satisfy gaussian distribution 
    %{
    nAttributes = size(train_data,2);
    for i=1:nAttributes
        iAttributeData = train_data(:,i);
        iAttributeData = iAttributeData - mean(iAttributeData);
        figure; 
        hist(iAttributeData);
    end
    %}
    FVencoder = validateFVparam(FVencoder);

    K       = FVencoder.K;
    reg     = FVencoder.Regularize;
    rep     = FVencoder.Replicates;
    covtype = FVencoder.CovType;

    GMModel = gmdistribution.fit(train_samples, K, 'Regularize', reg, ...
                                     'CovType', covtype,  'Replicates', rep);
%     GMModel = gmdistribution.fit(train_samples, K, 'Regularize', 0.01, ...
%                                      'CovType', 'diagonal',  'Replicates', 2);                                 
    mu          = GMModel.mu;
    covMats     = GMModel.Sigma;
    w           = GMModel.PComponents;

    fprintf(1, 'Encoding of training data...\n');
    [muSigTrain, covSigTrain] = FVEncoding(train_data, K, mu, covMats, w);

    fprintf(1, 'Encoding of test data...\n');
    [muSigTest, covSigTest]   = FVEncoding(test_data, K, mu, covMats, w);

    sigTrain    = [muSigTrain covSigTrain];
    sigTest     = [muSigTest covSigTest];

    switch normalization
        case 'l2'
            nsigTrain = sigTrain ./repmat(sqrt(sum(sigTrain.^2,2)),1,size(sigTrain,2));
            nsigTest = sigTest ./repmat(sqrt(sum(sigTest.^2,2)),1,size(sigTest,2));
        case 'l1'
            nsigTrain = sigTrain ./repmat(sum(abs(sigTrain),2),1,size(sigTrain,2));
            nsigTest = sigTest ./repmat(sum(abs(sigTest),2),1,size(sigTest,2));
        otherwise
            nsigTrain = sigTrian;
            nsigTest = sigTest;
    end
    
    % model = svmtrain(labelTrain, sigTrain,  '-t 0');
    % [predict_label, accuracy, dec_values] = svmpredict(labelTest, sigTest, model); 

    % in case of fisher vector encoding, linear kernel works well than RBF kernel
    acc = [];
    powers = 0.1:0.1:1.0;
    cnt = 1;
    for i=powers
        model = svmtrain(train_labels, sigTrain.^i,  '-t 0 -c 10'); 
        [predict_label, accuracy, dec_values] = svmpredict(test_labels, sigTest.^i, model); 
        acc(cnt) = accuracy(1);
        cnt = cnt + 1;
    end

end

