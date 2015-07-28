function val_param =  validateDTWMDSparam(param)
% since MDS has high time complexities, we will break MDS into two
% sub-steps: (1) do kmeans, and choose some representatives from each
% cluster, and apply MDS on all representatives to get their mapped
% vectors;
% (2) within each cluster, solve the mapping of each point separately

    if nargin == 0
        val_param = struct('nDims', 20, ...         % # of dimensions
                           'nClusters', 50, ...     % # of kmeans clusters
                           'nIter', 2, ...       % # of iteration for calc. of representatives
                           'nIterLM', 10, ...        % # of iteration for LM algo. 
                           'nRepresentative', 40); % # of representatives 
                                                    % from each cluster
        return;        
    end
    
    val_param  = param;
    
    if ~isfield(val_param, 'nDims')
        val_param.nDims = 20;
    end
    
    if ~isfield(val_param, 'nClusters')
        val_param.nClusters = 10;
    end
    
    if ~isfield(val_param, 'nRepresentative')
        val_param.nRepresentative = 40;
    end
    
    if ~isfield(val_param, 'nIter')
        val_param.nIter = 100;
    end
    
    if ~isfield(val_param, 'nIterLM')
        val_param.nIterLM = 10;
    end


end