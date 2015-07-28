% demo of DTWMDS

% calculate DTWMDS descriptors 

%% (1) save path
global datapath;
global slash;

saveDir = datapath.DTWMDSdescriptorsDir;
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end   

%% (2) DTWMDS descriptor setting
 samplingSetting  = struct('method', 'hybrid', ...
                         'param',  struct('seqlen', 60, ...
                         'stride', 10, ...
                         'sel',    10));
                  
 DTWMDSparam = struct('nDims', 30, ...         
                          'nClusters', 20, ...     
                          'nIter', 10, ...       
                          'nIterLM', 10, ...    
                          'nRepresentative', 50);
                      
DTWMDSdescriptorParam = validateDTWMDSparam2;   
DTWMDSdescriptorParam.seqlen  = samplingSetting.param.seqlen;
DTWMDSdescriptorParam.stride  = samplingSetting.param.stride;
DTWMDSdescriptorParam.sel     = samplingSetting.param.sel;
DTWMDSdescriptorParam.nDims  = DTWMDSparam.nDims;
 
%% (3) compute DTWMDS descriptors 
%  -- training
%  -- test
UCRdatasets = getRawDatasetNamesUCR;
nDatasets = numel(UCRdatasets);

targetDatasetIdx = 13;  % this is the index of UCR datasets, change this
                        % index to process different dataset
fprintf(1, 'compute DTWMDS descriptors on dataset: %s\n', UCRdatasets{targetDatasetIdx});

subsaveDir = strcat(saveDir, slash, UCRdatasets{targetDatasetIdx});
if ~exist(subsaveDir, 'dir')
    mkdir(subsaveDir);
end
st = clock;
[DTWMDSvecsTrainCell, DTWMDSvecsTestCell, DTWMDSmodel, t_descriptor_train, t_descriptor_test] = ...
        calcDTWMDSucr(targetDatasetIdx, samplingSetting, DTWMDSparam);
et = clock;
t = etime(et, st);
descriptors = [DTWMDSvecsTrainCell; DTWMDSvecsTestCell];
fileName = generateDTWMDSdescriptorFileName(DTWMDSdescriptorParam);
save(strcat(subsaveDir, '/', [fileName '.mat']), 'descriptors');





