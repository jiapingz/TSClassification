
function acc = classifyTSBaydogan(encoderTrain, encoderTest, bDimensions, ...
                                    labelsTrain, labelsTest, NTrees)
    
	nTrain  = length(labelsTrain);
    nTest   = length(labelsTest);
    
    trainData = [];
    testData = [];
    
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
    

    BagClassifier = TreeBagger(NTrees,trainData, labelsTrain, 'Method', 'classification');
    [labelsPred, ~] = predict(BagClassifier,testData);
    
    labels_prediction = zeros(size(labelsTest));
    for i=1:length(labelsTest)
        labels_prediction(i) = str2double(labelsPred{i});
    end
    
    % problematic !!!!!
    acc = sum(labels_prediction == labelsTest)/ length(labelsTest);
    
    
end