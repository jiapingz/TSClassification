% first use random forest to create a bag of features

%% (1) ==== create vocabulary by supervised random forest =======
function [acc, powers] = svmRFEncoder(nClasses, train_data, train_labels, test_data, test_labels, ...
                        RFencoder, normalization)
                    
    if ~exist('train_data', 'var') || isempty(train_data) || ~iscell(train_data)
        error('train_data should be a cell array\n');
    end
    
    if ~exist('test_data', 'var') || isempty(test_data) || ~iscell(test_data)
        error('test_data should be a cell array\n');
    end

    traindata  =   [];
    trainlabels =   [];
%     nClasses = size(activityNames,1);
    nTrain  =   size(train_data,1);

    for i=1:nTrain
        if iscell(train_data{i})
            traindata   = cat(1, traindata, cell2mat(train_data{i}));
        elseif ismatrix(train_data{i})
            traindata = cat(1,traindata, train_data{i});
        else
            error('unsupported format of the 1st input\n');
        end
        
        nSequences  = size(train_data{i},1);
        trainlabels	= cat(1, trainlabels, train_labels(i)*ones(nSequences,1));
    end

    % build a random forest classifier
%     NTrees = 30;
    RFencoder = validateRFparam(RFencoder);
    NTrees  = RFencoder.NTrees;
    nBins   = RFencoder.nbins;
    method  = RFencoder.Method;
    B = TreeBagger(NTrees,traindata, trainlabels, 'Method', method);

%     nBins = 5;
    % encode each time series in a way similar to soft-assignment
    descriptorsTrain = RFEncoding(B, train_data, nClasses, nBins);
    % encoding test samples
    descriptorsTest = RFEncoding(B, test_data, nClasses, nBins);
    
    
    switch normalization
        case 'l2'
            descriptorsTrain = descriptorsTrain ./repmat(sqrt(sum(descriptorsTrain.^2,2)),1,size(descriptorsTrain,2));
            descriptorsTest = descriptorsTest ./repmat(sqrt(sum(descriptorsTest.^2,2)),1,size(descriptorsTest,2));
        case 'l1'
            descriptorsTrain = descriptorsTrain ./repmat(sum(abs(descriptorsTrain),2),1,size(descriptorsTrain,2));
            descriptorsTest = descriptorsTest ./repmat(sum(abs(descriptorsTest),2),1,size(descriptorsTest,2));
        otherwise
    end


    %% (2) ===== bag-of-words are the input featues, using SVM as the 
    % classifier ===============================
    acc = [];
    powers = 0.1:0.1:1.0;
    cnt = 1;
    for i=powers
        model = svmtrain(train_labels, descriptorsTrain.^i,  '-t 2 -c 10');
        [predict_label, accuracy, dec_values] = svmpredict(test_labels, descriptorsTest.^i, model ); 
        acc(cnt) = accuracy(1);
        cnt = cnt + 1;
    end


end

