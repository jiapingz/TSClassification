% validate fisher vector encoding parameter setting

function val_encoder = validateFVparam(encoder)
    if nargin == 0
%         val_encoder.method = 'FV';
        val_encoder = struct('K', 20, ...
                                    'Regularize', 0.01, ...
                                    'Replicates', 2, ...
                                    'CovType', 'diagonal'); % default setting
        return;
    end
    
%     val_encoder.method = 'FV';
    
 
    val_encoder = encoder;
    if ~isfield(val_encoder, 'K')
        val_encoder.K = 20;
    end

    if ~isfield(val_encoder, 'CovType')
        val_encoder.CovType = 'diagonal';
    end

    if ~isfield(val_encoder, 'Regularize')
        val_encoder.Regularize = 0.01;
    end

    if ~isfield(val_encoder, 'Replicates')
        val_encoder.Replicates = 2;
    end

    
    
end
