

function [sigTrain, models, success] = trainEncoder(bofTrain, labelsTrain, ...
                                                                 encoderName, param)
    
    error(nargchk(4,4,nargin));
                                
    if isempty(bofTrain) ||  ~iscell(bofTrain) || ...
                ~iscell(bofTrain{1})
        error('Empty or Wrong formats of input data\n');
    end
    
    nDims = numel(bofTrain{1});
    sigTrain  = cell(1,nDims);
    models     = cell(1,nDims);
    success = true;
              
    for i=1:nDims
        i_bofTrain = extractDimensionASynMTS(bofTrain, i);
 
        switch encoderName
            case 'BoW'
                fprintf(1, 'train encoder BOW...\n');
                val_param = validateBoWparam(param);
                K = val_param.K;
                [sigTrain{i}, models{i}, success] = trainEncoderBoW(i_bofTrain, K);
            case 'FV'
                fprintf(1, 'train encoder FV...\n');
                val_param = validateFVparam(param);
                [sigTrain{i}, models{i}, success] = trainEncoderFV(i_bofTrain, val_param);
            case 'RF'
                fprintf(1, 'train encoder RF... (supervised encoding)\n');
                val_param = validateRFparam(param);
                [sigTrain{i}, models{i}] = ...
                        trainEncoderRF(i_bofTrain, labelsTrain, val_param);
            otherwise
                error('Now only support 3 kinds of encoding ways: BoW, FV and RF\n');
        end

    end
                                
end