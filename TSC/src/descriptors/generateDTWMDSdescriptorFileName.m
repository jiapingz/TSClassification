
function fileName =  generateDTWMDSdescriptorFileName(param)
    
    if nargin == 0
        val_param = validateDTWMDSdescriptorparam;
    else
        val_param = validateDTWMDSdescriptorparam(param);
    end
 
    
    fileName = sprintf('DTWMDS-seqlen-%d-stride-%d-sel-%d-nDims-%d', ...
            val_param.seqlen, val_param.stride, val_param.sel, val_param.nDims); 
    
end