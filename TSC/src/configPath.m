% run this configuration script first

global workDir;
workDir = pwd;
addpath(genpath(workDir));

global slash;
if ispc
    slash = '\';
else
    slash = '/';
end

global datapath;
datapath.rawDatasetsDir         = strcat(workDir, slash, 'datasets');
datapath.formattedDatasetsDir   = strcat(workDir, slash, 'results', slash, 'formattedDatasets');
datapath.HOGscalesDir           = strcat(workDir, slash, 'results', slash, 'HOGscales');
datapath.DTWMDSdescriptorsDir   = strcat(workDir, slash, 'results', slash, 'DTWMDSdescriptors');
datapath.classificationResDir   = strcat(workDir, slash, 'results', slash, 'classificationResults');

if ~exist(datapath.rawDatasetsDir, 'dir')
    mkdir(datapath.rawDatasetsDir);
end

if ~exist(datapath.formattedDatasetsDir, 'dir')
    mkdir(datapath.formattedDatasetsDir);
end

if ~exist(datapath.HOGscalesDir, 'dir')
    mkdir(datapath.HOGscalesDir);
end

if ~exist(datapath.DTWMDSdescriptorsDir, 'dir')
    mkdir(datapath.DTWMDSdescriptorsDir);
end

if ~exist(datapath.classificationResDir, 'dir')
    mkdir(datapath.classificationResDir);
end


 