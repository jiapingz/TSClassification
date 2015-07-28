% valid parameter setting for kmeans encoding
function val_encoder = validateBoWparam(encoder)
        if nargin == 0
            val_encoder = struct('K', 200);
            return;
        end
        
%     val_encoder.method = 'kmeans';
 
        val_encoder = encoder;
        if ~isfield(val_encoder, 'K')
            val_encoder.K = 100;
        end     
    
end