
function val_param = validateGKernelparam(param)
    if nargin == 0
        val_param = struct('windowsize', [100 100], ...
                           'cov', [25,0; 0, 25]);
        return;
    end
    
    val_param = param;
    if ~isfield(val_param, 'windowsize')
        val_param.mapsize = [100 100];
    end
    
    if ~isfield(val_param, 'cov')
        val_param.sigma = [25,0; 0, 25];
    end
end