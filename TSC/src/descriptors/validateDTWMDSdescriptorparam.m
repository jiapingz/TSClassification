
function val_param = validateDTWMDSdescriptorparam(param)

    if nargin == 0 || ~isstruct(param)
        val_param = struct('seqlen', 60, ...
                           'stride', 2, ...
                           'sel', 10, ...
                           'nDims', 30);
        return;
    end

    val_param = validateDTWMDSparam2(param);
end