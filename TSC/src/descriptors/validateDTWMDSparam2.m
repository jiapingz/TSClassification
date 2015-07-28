function val_param = validateDTWMDSparam2(param)

    if nargin == 0
        val_param = struct('seqlen', 60, ...
                           'stride', 2, ...
                           'sel',    10, ...
                           'nDims',  30);
        return;      
    end
    
    val_param  = param;
    
    if ~isfield(val_param, 'seqlen')
        val_param.seqlen = 60;
    end
    
    if ~isfield(val_param, 'sel')
        val_param.sel = 10;
    end
    
    if ~isfield(val_param, 'stride')
        val_param.stride = 2;
    end
    
    
    if ~isfield(val_param, 'nDims')
        val_param.nDims = 30;
    end
    
end