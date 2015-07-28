
function fileName = generateFVFileName(param)
    if nargin == 0
        val_param = validateFVparam;
    else
        val_param = validateFVparam(param);
    end    
    fileName = sprintf('FV-K-%d-regularize-%g', val_param.K, val_param.Regularize);    
    
end