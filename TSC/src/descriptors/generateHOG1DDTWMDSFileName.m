% generate descriptor filename for HOG1D-DTWMDS descriptor
function fileName = generateHOG1DDTWMDSFileName(param)
    if nargin == 0
        val_param = validateHOG1DDTWMDSdescriptorparam;
    else
        val_param = validateHOG1DDTWMDSdescriptorparam(param); 
    end
    
    if ~isfield(val_param, 'HOG1D')
        param_hog = validateHOG1Dparam;
    else
        param_hog = val_param.HOG1D;
    end
    
    if ~isfield(val_param, 'DTWMDS')
        param_dtwmds = validateDTWMDSdescriptorparam;
    else
        param_dtwmds = val_param.DTWMDS;
    end
        
    fileName_hog    = generateHOG1DFileName(param_hog);
    fileName_dtwmds = generateDTWMDSdescriptorFileName(param_dtwmds);
    
    fileName = sprintf('HOG1DDTWMDS-%s-%s', fileName_hog, fileName_dtwmds);
end