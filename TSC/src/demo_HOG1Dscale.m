%% demo to search for a HOG1D scale

clear all;
configPath;
global datapath;
global slash;

saveDir = datapath.HOGscalesDir;
% compute HOG1D scales on UCR43

% get dataset information
UCRdir      = getRawDatasetsDirUCR;
UCRdatasets = getRawDatasetNamesUCR;
nDatasets   = numel(UCRdatasets);

%% ========================================================
% the target dataset index, change it to process 
% different datasets
targetDatasetIdx = 9; 
%% ========================================================
                    
fprintf(1,'Processing: %s ...\n', UCRdatasets{targetDatasetIdx});

 sName = strcat(UCRdatasets{targetDatasetIdx}, '.mat');

if exist(strcat(saveDir, slash, sName), 'file')
    fprintf(1, 'HOG1D scale on dataset ''%s'' has been computed already\n', UCRdatasets{targetDatasetIdx}); 
    return;
end
 
% read data from disk
% train
signals = readucr(targetDatasetIdx, 'train');
labelsTrain  = signals(:,1);
dataTrain    = signals(:,2:end);
cellTraindata = mat2cell(dataTrain, ones(1,size(dataTrain,1)), size(dataTrain,2));
scale = searchHOG1Dscale(cellTraindata);

save(strcat(saveDir, slash, sName), 'scale');

 