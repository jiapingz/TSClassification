%  parameter settings in our classification pipeline
% descriptor: DFT

%% ============ encoder, normalization & classifier setting ================ 
    bow = validateBoWparam;
     bow.K = 10:15:100; 

    encodersSetting = struct('method', 'BoW', ...
                             'param', bow);

    % (3~4) normalization                     
    normalizationSetting = struct('method', 'power', ...
                                  'param', struct('alpha', 1.0));
 
    classifiersSetting = struct('method', 'SVM', ...
                                'param',  '-t 2 -c 10');

%% ============   descriptor & sampling setting  ================
    params_uniform = struct('seqlen', 60, ...
                            'stride', 2, ...
                            'sel', 10, ...
                            'numLevels', 3);
 
    xscale = 0.1;
    seqlen = params_uniform.seqlen;
    stride = params_uniform.stride;
    sel = params_uniform.sel;
    
    samplingSetting = struct('method', 'hybrid', ...
                             'param',  struct('seqlen', seqlen, ...
                                              'stride', stride, ...
                                              'sel', sel));

    % (2) descriptor setting     
    dft = validateDFTdescriptorparam;
    dft.ratioKept = 0.8;

 
    descriptorsSetting = struct('method', 'DFT', ...
                                'param',  dft);  


    DatasetSetting = struct('sampling',       samplingSetting, ...
                          'descriptors',    descriptorsSetting, ...
                          'encoders',       encodersSetting, ...
                          'normalization',  normalizationSetting, ...
                          'classifiers',     classifiersSetting);
                      
	UCRsetting = DatasetSetting; 

                      
 

 