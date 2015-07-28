% compare three different kinds of encoding methods
% bag of words, random forest and Fisher vector
% our method can only handle different univariate time series

% need modification: clean up!!!
function accVec =  compareEncodingTS(descriptors, labels, ...
                                                    idxTrain, idxTest)
    
    if ~iscell(descriptors) || ~iscell(descriptors{1})
        error('The 1st parameter should be in format of cell\n');
    end
    
    if numel(descriptors{1} ~= 1)
       error('We can only handle univariate time series now\n'); 
    end
    
    nSamples = numel(descriptors);
    stdDescriptors = cell(nSamples,1);
    
    % convert into standard format
    % a cell array, and each cell contains a cell array, whose entries are
    % elements of encodings of subsequences
    for i=1:nSamples
        stdDescriptors{i} = descriptors{i}{1};
    end
    
    bofTrain   = stdDescriptors(idxTrain);
    bofTest    = stdDescriptors(idxTest);
    labelTrain = labels(idxTrain);
    labelTest  = labels(idxTest);
    
    
    nClasses = size(length(unique(labels)),1);
    train_data  =   [];
    train_label =   [];
    nTrain  =   size(bofTrain,1);

    for i=1:nTrain
        train_data      = [train_data; cell2mat(bofTrain{i})];
        nSequences      = size(bofTrain{i},1);
        train_label     = [train_label; labelTrain(i)*ones(nSequences,1)];
    end
   
   accVec = zeros(1,3);
 
%%  (1) bag of words encoding
        Ksequences = 10:10:150;
        accuracies = zeros(size(Ksequences));
        for k=1:length(Ksequences)
            K = Ksequences(k);
            [bowTrain, bowTest] = vectorQuantizationKMeans(bofTrain, bofTest, K);
           % power transformation
            acc = [];
            cnt = 1;
             for i=0.1:0.1:1
                    model = svmtrain(labelTrain,  bowTrain.^i ,  '-t 2 -c 10');
                    [predict_label, accuracy, dec_values] = svmpredict(labelTest, bowTest.^i , model); 
                    acc(cnt) = accuracy(1);
                    cnt = cnt +1;
             end
             accuracies(k) = max(acc);
        end
        accVec(1) = max(accuracies);        
    %% random forest encoding
        nTreeSequences = 10:10:150;
        accuracies = zeros(size(nTreeSequences));
        for t=1:length(nTreeSequences)
            NTrees = nTreeSequences(t);
            B = TreeBagger(NTrees,train_data, train_label, 'Method', 'classification');
            nBins = 5;
            % encode each time series in a way similar to soft-assignment
            descriptorsTrain    =   RFEncoder(B, bofTrain, nClasses, nBins);
            % encoding test samples
            descriptorsTest     =   RFEncoder(B, bofTest, nClasses, nBins);

            acc = [];
            cnt = 1;
            for i=0.1:0.1:1.0
                model = svmtrain(labelTrain, descriptorsTrain.^i,  '-t 2');
                [predict_label, accuracy, dec_values] = svmpredict(labelTest, descriptorsTest.^i, model); 
                acc(cnt) = accuracy(1);
                cnt = cnt + 1;
            end
            accuracies(t) = max(acc);
        end
        accVec(2) = max(accuracies);

       %% fisher vector encoding
        KSequences = 10:10:150;
        accuracies = zeros(size(KSequences));
        for k=1:length(KSequences)
            K = KSequences(k);
            GMModel = gmdistribution.fit(train_data, K, 'Regularize', 0.01, ...
                             'CovType', 'diagonal',  'Replicates', 2);
            mu          = GMModel.mu;
            covMats     = GMModel.Sigma;
            w           = GMModel.PComponents;

            fprintf(1, 'Encoding of training data...\n');
            [muSigTrain, covSigTrain] = FVEncoding(bofTrain, K, mu, covMats, w);

            fprintf(1, 'Encoding of test data...\n');
            [muSigTest, covSigTest]   = FVEncoding(bofTest, K, mu, covMats, w);

            sigTrain    = [muSigTrain covSigTrain];
            sigTest     = [muSigTest covSigTest];

            sigTrain = sigTrain ./repmat(sqrt(sum(sigTrain.^2,2)),1,size(sigTrain,2));
            sigTest = sigTest ./repmat(sqrt(sum(sigTest.^2,2)),1,size(sigTest,2));

            acc = [];
            cnt = 1;
            for i=0.1:0.1:1.0
                model = svmtrain(labelTrain, sigTrain.^i,  '-t 0');
                [predict_label, accuracy, dec_values] = svmpredict(labelTest, sigTest.^i, model); 
                acc(cnt) = accuracy(1);
                cnt = cnt + 1;
            end
            accuracies(k) = max(acc);                        
        end
       accVec(3) = max(accuracies);
 
end

