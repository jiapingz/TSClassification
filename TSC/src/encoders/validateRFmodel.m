
function val_model = validateRFmodel(model)
    if nargin == 0 || isempty(model)
        val_model = struct('B', [], ...
                           'nbins', 5, ...
                           'nclasses', 10, ...
                           'sigTrain', [], ...
                           'labelsTrain', []);
        return;
    end
    
    val_model = model;
    
    if ~isfield(model, 'B')
        val_model.B = [];
    end
    
    if ~isfield(model,'nbins')
        val_model.nbins = 5;
    end
    
    if ~isfield(model, 'nclasses')
        val_model.nclasses = 10;
    end
    
    if ~isfield(model, 'sigTrain')
        val_model.sigTrain = [];
    end
    
    if ~isfield(model, 'labelsTrain')
        val_model.labelsTrain = [];
    end


end