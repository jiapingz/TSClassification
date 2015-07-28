
function fileName = generateBoWFileName(param)
    
    if nargin == 0
        val_param = validateBoWparam;
    else
        val_param = validateBoWparam(param);
    end
    
    fileName = sprintf('BoW-K-%d', val_param.K);    
end