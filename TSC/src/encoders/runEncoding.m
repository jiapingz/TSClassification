% encoding time series;
% input: local descriptors
% ouput: time series representations

% this function can handle both univariate and multivariate time series
% format of inputs: nested cells, this specific format is used to keep
% consistent with the format of stored local descriptors

function [sigTrain, sigTest, success, t_train, t_test] = runEncoding(bofTrain, bofTest, ...
                                    labelTrain, labelTest, encoderName, param)
                                
                                
    if isempty(bofTrain) || isempty(bofTest) || ...
            ~iscell(bofTrain) || ~iscell(bofTest) || ...
                ~iscell(bofTrain{1}) || ~iscell(bofTest{1})
        error('Empty or Wrong formats of input data\n');
    end
    
    nDims = numel(bofTrain{1});
    sigTrain  = cell(1,nDims);
    sigTest   = cell(1,nDims);
    success = true;
              
    for i=1:nDims
        i_bofTrain = extractDimensionASynMTS(bofTrain, i);
        i_bofTest  = extractDimensionASynMTS(bofTest, i);

        switch encoderName
            case 'BoW'
                fprintf(1, 'BoW encoding...\n');
                val_param = validateBoWparam(param);
                K = val_param.K;
                [sigTrain{i}, sigTest{i}, success] = encoderBoW(i_bofTrain, i_bofTest, K);
                t_train = 0;
                t_test = 0; % to be modify
            case 'FV'
                fprintf(1, 'Fisher Vector encoding...\n');
                val_param = validateFVparam(param);
                [sigTrain{i}, sigTest{i}, success, t_train, t_test] = encoderFV(i_bofTrain, i_bofTest, val_param);
            case 'RF'
                fprintf(1, 'Random Forest encoding... (supervised encoding)\n');
                val_param = validateRFparam(param);
                [sigTrain{i}, sigTest{i}] = ...
                        encoderRF(i_bofTrain, i_bofTest, labelTrain, labelTest, val_param);
                t_train = 0;
                t_test = 0;
            otherwise
                error('Now only support 3 kinds of encoding ways: BoW, FV and RF\n');
        end

    end
                                
end