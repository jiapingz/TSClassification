%  parameter settings in our classification pipeline
% descriptor: HOG1D + DTWMDS

%% ============ encoder, normalization & classifier setting ================
 
    fv = validateFVparam;
	fv.K = 10:15:100;
 
    % (1) encoder setting: fisher vector
    encodersSetting = struct('method', 'FV', ...
                             'param', fv);

    % (2) normalization                     
    normalizationSetting = struct('method', 'power', ...
                                  'param', struct('alpha', 1.0));

    % (3) classifier setting: linear kernel SVM
    classifiersSetting = struct('method', 'SVM', ...
                                'param',  '-t 0 -c 10');

%% ============   descriptor & sampling setting  ================
    params_uniform = struct('seqlen', 60, ...
                            'stride', 2, ...
                            'sel', 10, ...
                            'numLevels', 3);
 
    xscale = 0.1;
    seqlen = params_uniform.seqlen;
    stride = params_uniform.stride;
    sel = params_uniform.sel;
    nDims = ceil(seqlen/2);
    
    samplingSetting = struct('method', 'hybrid', ...
                             'param',  struct('seqlen', seqlen, ...
                                              'stride', stride, ...
                                              'sel', sel));
 
    hog = validateHOG1Dparam;
    hog.cells    = [1 round(seqlen/2)];
    hog.overlap = 0;
    hog.xscale  = xscale;    
    
    dtwmds = validateDTWMDSparam2;
    dtwmds.seqlen  = samplingSetting.param.seqlen;
    dtwmds.stride  = samplingSetting.param.stride;
    dtwmds.sel     = samplingSetting.param.sel;
    dtwmds.nDims  =  nDims; 

    hogdtwmds = validateHOG1DDTWMDSdescriptorparam;
    hogdtwmds.HOG1D = hog;
    hogdtwmds.DTWMDS = dtwmds; 

    descriptorsSetting = struct('method', 'HOG1DDTWMDS', ...
                                'param',  hogdtwmds);  

    DatasetSetting = struct('sampling',       samplingSetting, ...
                          'descriptors',    descriptorsSetting, ...
                          'encoders',       encodersSetting, ...
                          'normalization',  normalizationSetting, ...
                          'classifiers',     classifiersSetting);
                      
    UCRsetting = DatasetSetting; 


 