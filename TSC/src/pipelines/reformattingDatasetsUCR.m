
function [ data, labels, idxTrain, idxTest] = reformattingDatasetsUCR(datasetIdx)
% read data 
% and re-format it as the format usable by our pipeline
        traindata = readucr(datasetIdx, 'train');
        testdata = readucr(datasetIdx, 'test'); 
        trainData = traindata(:,2:end);
        trainLabels = traindata(:,1);

        testData = testdata(:,2:end);
        testLabels = testdata(:,1);

        tmp_data = [trainData; testData];
        labels = [trainLabels; testLabels];

        idxTrain = 1:length(trainLabels);
        idxTest  = (length(trainLabels)+1):length(labels);

        nSamples = length(labels);

        data = cell(nSamples,1);

        for j=1:nSamples
            tmp = cell(1,1);
            tmp{1} = tmp_data(j,:)';
            data{j} = tmp;        
        end   
     
end