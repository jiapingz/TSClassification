
function [labelsPredict, acc] =  classifierSVM(sigTrain, labelsTrain, ...
                                            sigTest, labelsTest, parasetting)
    % typical parameter setting
    % (1) parasetting = '-t 2 -c 10';
    % (2)               '-t 2 -c 1' ;
    % (3)               '-t 0 -c 10'; used in case of Fisher Vector
    %                                 encoding
    
    model = svmtrain(labelsTrain,  sigTrain ,  parasetting);
	[labelsPredict, accuracy, ~] = svmpredict(labelsTest, sigTest , model); 
    acc = accuracy(1);

end