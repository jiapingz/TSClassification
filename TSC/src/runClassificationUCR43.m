
%% run classification on 43 UCR datasets using our method
clear all;
configPath;
global slash;
global datapath;

%% ============================================================== 
%   we provide configurations for three different descriptors:
%   HOG1D-DTWMDS, DWT & DFT
%   to run our pipeline under one descriptor, just uncomment the 
%   corresponding line below
%% ==============================================================
configUCR43hog1d_dtwmds;  % using our proposed descriptor: HOG1D + DTWMDS
% configUCR43dwt;         % using descriptor: DWT (discrete wavelet transform)
% configUCR43dft;         % using descriptor: DFT (discrete fourier transform)

% path information
datasets                 =  getRawDatasetNamesUCR;
nDatasets = numel(datasets);
formattedDatasetsDir     =  datapath.formattedDatasetsDir;
HOGscalesDir             =  datapath.HOGscalesDir;
classificationResSaveDir =  datapath.classificationResDir;


% classify each dataset
rng('shuffle');
idx = randperm(nDatasets);
 
for j=1:nDatasets
    i = idx(j);
    subsaveDir = strcat(classificationResSaveDir, slash, datasets{i});
    if ~exist(subsaveDir, 'dir')
        mkdir(subsaveDir);
    else
        continue;
    end

    % (1) load raw data 
    formattedDataFile = strcat(formattedDatasetsDir, slash, [datasets{i} '.mat']);
    if exist(formattedDataFile, 'file')
        load(formattedDataFile);
    else
        [data, labels, idxTrain, idxTest] = reformattingDatasetsUCR(i);
        save(formattedDataFile, 'data', 'labels', 'idxTrain', 'idxTest');        
    end

    % (2) load HOG1D scales    
    if ~exist(strcat(HOGscalesDir, slash, [datasets{i} '.mat']), 'file')
        fprintf(1, 'Please run script ''computeHOG1DscalesUCR43.m'' to compute HOG scales first\n');
        return;
    else
        load(strcat(HOGscalesDir, slash, [datasets{i} '.mat']));
    end
    
 	DescriptorSetting = UCRsetting.descriptors;
    if strcmp(DescriptorSetting.method, 'HOG1D')
        hog = DescriptorSetting.param;
        hog.xscale = scale;
        DescriptorSetting.param = hog;
    end

    if strcmp(DescriptorSetting.method, 'HOG1DDTWMDS')
        hogdtwmds = DescriptorSetting.param;
        hog = hogdtwmds.HOG1D;
        hog.xscale = scale;
        hogdtwmds.HOG1D = hog;
        DescriptorSetting.param = hogdtwmds;
    end
    UCRsetting.descriptors = DescriptorSetting;
    
    % (3) run classification using our pipeline
    TSCpipeline(datasets{i}, data, labels, idxTrain, idxTest, UCRsetting, subsaveDir);

end
 

