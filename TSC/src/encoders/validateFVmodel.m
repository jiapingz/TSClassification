
function val_model = validateFVmodel(model)
    if nargin == 0 || isempty(model)
        val_model = struct('GMModel', gmdistribution, ...
                           'sigTrain', [], ...
                           'labelsTrain', []);
        return;
    end
    
    if ~isfield(model, 'GMModel')
        val_model.GMModel = gmdistribution;
    else
        val_model.GMModel = model.GMModel;
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