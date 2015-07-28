% validate trained BoW model

function val_model = validateBoWmodel(model)
    
    if nargin == 0 || isempty(model) || ~isstruct(model)
        val_model = struct('clusterCenters', [], ...
                       'sigTrain', [], ...
                       'labelsTrain', []);
        return;
    end
    
    if ~isfield(model, 'clusterCenters')
        val_model.clusterCenters = [];
    else
        val_model.clusterCenters = model.clusterCenters;
    end
    
    if ~isfield(model, 'sigTrain')
        val_model.sigTrain = [];
    else
        val_model.sigTrain = model.sigTrain;
    end
    
    if ~isfield(model, 'labelsTrain')
        val_model.labelsTrain = [];
    else
        val_model.labelsTrain = model.labelsTrain;
    end
    
end