
function val_param = validatePowerparam(param)
    if nargin == 0 || isempty(param)
        val_param = struct('alpha', 1.0);
        return;
    end
    
    if ~isfield(param, 'alpha')
        val_param.alpha = 1.0;
    else
        val_param.alpha = 1.0;
    end

end