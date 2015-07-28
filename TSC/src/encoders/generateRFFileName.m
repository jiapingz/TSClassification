
function fileName = generateRFFileName(param)
    if nargin == 0
        val_param = validateRFparam;
    else
        val_param = validateRFparam(param);
    end
    
    fileName = sprintf('RF-NTrees-%d-nBins-%d', val_param.NTrees, val_param.nbins);
    
end