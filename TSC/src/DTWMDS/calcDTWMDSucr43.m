% calculate DTWMDS descriptors on 43 UCR datasets

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
                         'stride', 2, ...
                         'sel',    10));
                  
 DTWMDSparam = struct('nDims', 30, ...         
                          'nClusters', 30, ...     
                          'nIter', 30, ...       
                          'nIterLM', 10, ...    
                          'nRepresentative', 60);
 
%% (3) compute DTWMDS descriptors 
%  -- training
%  -- test
UCRdatasets = getRawDatasetNamesUCR;
nDatasets = numel(UCRdatasets);


rng('shuffle');
rorder = randperm(nDatasets);

for d=1:nDatasets            
    subsaveDir = strcat(saveDir, slash, UCRdatasets{rorder(d)});
    if ~exist(subsaveDir, 'dir')
        mkdir(subsaveDir);
    else
        continue;
    end
    fprintf(1, 'compute DTWMDS descriptors on dataset: %s, %d/%d\n', UCRdatasets{rorder(d)}, d, nDatasets);            
    st = clock;
    [DTWMDSvecsTrainCell, DTWMDSvecsTestCell, DTWMDSmodel, t_descriptor_train, t_descriptor_test] = ...
            calcDTWMDSucr(rorder(d), samplingSetting, DTWMDSparam);
    et = clock;
    t = etime(et, st);
    descriptors = [DTWMDSvecsTrainCell; DTWMDSvecsTestCell];
    save(strcat(subsaveDir, '/', 'DTWMDS-descriptor.mat'), 'DTWMDSvecsTestCell', ...
                    'DTWMDSvecsTrainCell', 'descriptors', 'samplingSetting', 'DTWMDSparam', ...
                            't', 't_descriptor_train', 't_descriptor_test');
end





