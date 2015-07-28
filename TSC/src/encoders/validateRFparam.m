
function val_encoder = validateRFparam(encoder)
    % for random forest classification, there are lots of parameter
    % settings, however, we mainly use the default setting of matlab
    % function, and just pick the most important two parameters: namely
    % NTrees and classification(instead of regression)
    if nargin == 0
        val_encoder =  struct('NTrees', 50, ...
                                    'Method', 'classification', ...
                                    'nbins', 5);
        return;
    end
    
%     val_encoder.method = 'RF';
 
        val_encoder = encoder;
        if ~isfield(val_encoder, 'NTrees')
            val_encoder.NTrees = 50; %default # of trees
        end
        if ~isfield(val_encoder, 'nbins')
            val_encoder.nbins = 5;
        end
        if ~isfield(val_encoder, 'Method')
            val_encoder.Method = 'classification';
        else
            locs = strfind({'classification', 'regression'}, val_encoder.Method);
            if isempty(locs{1})
                val_encoder.Method = 'classification';
            end
            
        end
      
    
end