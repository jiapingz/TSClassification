function signal = readucr(datasetIdx, trot, dataDir)
% inputs
%        idx - dataset index
%        trot - 'train' or 'test'
    narginchk(0,3);
    
    if nargin == 0
        datasetIdx = 1;
        trot = 'train';
     elseif nargin == 1
        trot = 'train';
     end
    
    if isempty(datasetIdx)
        datasetIdx = 1;
    end
    if ~exist('dataDir', 'var') || isempty(dataDir)
        dataDir = getRawDatasetsDirUCR;
    end
    datasetNames = getRawDatasetNamesUCR;
    nDatasets = numel(datasetNames);
    
    if datasetIdx > nDatasets || datasetIdx < 1
        fprintf(1, 'Please input a valid idx between [1 %d]\n', nDatasets);
    end
    
    if ispc
        sl = '\';
    else
        sl = '/';
    end
    
    fileName = strcat(datasetNames{datasetIdx}, ['_' upper(trot)]);
    if exist(strcat(dataDir, sl, datasetNames{datasetIdx}, sl, fileName), 'file')
        signal = load(strcat(dataDir, sl, datasetNames{datasetIdx}, sl, fileName));
    else
        err_msg = sprintf('Please download UCR datasets from ''http://www.cs.ucr.edu/~eamonn/time_series_data/'' and place them into the folder: %s', dataDir);
        error(err_msg);
    end
     
end