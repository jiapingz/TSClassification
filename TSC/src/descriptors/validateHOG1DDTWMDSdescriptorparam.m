function val_param = validateHOG1DDTWMDSdescriptorparam(param)
    
    if nargin == 0 || ~isstruct(param)
        val_param.HOG1D = validateHOG1Dparam;
        val_param.DTWMDS = validateDTWMDSdescriptorparam;
        return;
    end

    param_hog = param.HOG1D;
    param_dtwmds = param.DTWMDS;
    val_param_hog = validateHOG1Dparam(param_hog);
    val_param_dtwmds = validateDTWMDSdescriptorparam(param_dtwmds);
        
    val_param.HOG1D = val_param_hog;
    val_param.DTWMDS = val_param_dtwmds;
end