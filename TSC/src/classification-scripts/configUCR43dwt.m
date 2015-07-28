%  parameter settings in our classification pipeline
% descriptor: DWT

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
 
    
    dwt = validateDWTdescriptorparam;
    dwt.numLevels = params_uniform.numLevels;

    descriptorsSetting = struct('method', 'DWT', ...
                                'param',  dwt);  

    DatasetSetting = struct('sampling',       samplingSetting, ...
                          'descriptors',    descriptorsSetting, ...
                          'encoders',       encodersSetting, ...
                          'normalization',  normalizationSetting, ...
                          'classifiers',     classifiersSetting);
                      
    UCRsetting = DatasetSetting; 




 