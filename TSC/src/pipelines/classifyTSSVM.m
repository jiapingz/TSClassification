% this funtion can handle both univariate and multivariate time series
function [acc, predict_labels] =  classifyTSSVM(encoderTrain, encoderTest, bDimensions, labelsTrain, labelsTest)
    
    nTrain  = length(labelsTrain);
    nTest   = length(labelsTest);
    
    trainData = [];
    testData = [];
    
    % for multivariate time series, representations of different dimensions 
    % are concatenated to a long vector
    for i=1:nTrain
        tmp = encoderTrain{i};
        tmp = tmp(bDimensions);
        trainData = cat(1, trainData, cell2mat(tmp));        
    end
    
    for i=1:nTest
        tmp = encoderTest{i};
        tmp = tmp(bDimensions);
        testData = cat(1, testData, cell2mat(tmp));
    end

    
	acc = [];
    predicts = [];
    powers = 0.1:0.1:1;
    cnt = 1;
    for i=powers
            model = svmtrain(labelsTrain,  trainData.^i ,  '-t 2 -c 10');
            [predict_label, accuracy, dec_values] = svmpredict(labelsTest, testData.^i , model); 
            acc(cnt) = accuracy(1);
            cnt = cnt +1;
            predicts = cat(2, predicts, predict_label);
    end

    [acc, idx] = max(acc);
    predict_labels = predicts(:, idx);

end
