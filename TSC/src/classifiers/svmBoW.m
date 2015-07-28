% when train and test samples are represented as bag of words,
% SVM is used as a classifier

function [acc, powers] = svmBoW(train_data, train_labels, test_data, test_labels, ...
                                    bowEncoder, normalization)

    bowEncoder = validateBoWparam(bowEncoder);
%     K = 200;
    K = bowEncoder.K;
    [bowTrain, bowTest] = vectorQuantizationKMeans(train_data, test_data, K);

    switch normalization
        case 'l2'
            nbowTrain   = bowTrain./repmat(sqrt(sum(bowTrain.^2,2)),1,K);
            nbowTest    = bowTest./repmat(sqrt(sum(bowTest.^2,2)),1,K);
        case 'l1'
            nbowTrain   = bowTrain./repmat(sum(abs(bowTrain), 2),1,K);
            nbowTest    = bowTest./repmat(sum(abs(bowTest), 2),1,K);
        otherwise
            nbowTrain = bowTrain;
            nbowTest = bowTest;
    end
    %{        
    model = svmtrain(train_labels, bowTrain,  '-t 2 -c 10');
    [predict_label, accuracy, dec_values] = svmpredict(test_labels, bowTest, model); 
    %}

    % power transformation
    acc = [];
    powers = 0.1:0.1:1;
    cnt = 1;
    for i=powers
            model = svmtrain(train_labels,  bowTrain.^i ,  '-t 2 -c 10');
            [predict_label, accuracy, dec_values] = svmpredict(test_labels, bowTest.^i , model); 
            acc(cnt) = accuracy(1);
            cnt = cnt +1;
    end



end