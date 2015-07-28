function val_model = validateDTWMDSmodelParam(model)
    if nargin == 0        
        val_model = struct('nDims', 20, ...
                             'nClusters', 10, ...
                             'nCenters', 10, ...
                             'nIterLM', 10, ...
                             'nRepresentatives', 40, ...
                             'representatives', {}, ...
                             'representativesVecs', {}, ...
                             'cntRepresentatives', [], ...
                             'centers', []);
        return;
    end
    
    val_model = model;
    if ~isfield(val_model, 'nDims')
        val_model.nDims = 20;
    end
    
    if ~isfield(val_model, 'nClusters')
        val_model.nClusters = 10;
    end
    
    if ~isfield(val_model, 'nCenters')
        val_model.nCenters = 10;
    end
    
    if ~isfield(val_model, 'nIterLM')
        val_model.nIterLM = 10;
    end
        
    if ~isfield(val_model, 'nRepresentative')
        val_model.nRepresentative = 40;
    end
    
    if ~isfield(val_model, 'representatives')
        val_model.representatives = cell(val_model.nClusters,1);
    end
    
    if ~isfield(val_model, 'representativesVecs')
        val_model.representativesVecs = cell(val_model.nClusters,1);
    end
    
    if ~isfield(val_model, 'centers')
        val_model.centers = zeros(val_model.nClusters, val_model.nDims);
    end
    
    
    
    
end