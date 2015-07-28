% encoding time series;
% input: local descriptors
% ouput: time series representations
function [sigTrain, sigTest, success] = encoding(bofTrain, bofTest, ...
                                    labelTrain, labelTest, encoderName, param)
    
    success = true;
    switch encoderName
        case 'BoW'
            fprintf(1, 'BoW encoding...\n');
            val_param = validateBoWparam(param);
            K = val_param.K;
            [sigTrain, sigTest, success] = encoderBoW(bofTrain, bofTest, K);
        case 'FV'
            fprintf(1, 'Fisher Vector encoding...\n');
            val_param = validateFVparam(param);
            [sigTrain, sigTest, success] = encoderFV(bofTrain, bofTest, val_param);
        case 'RF'
            fprintf(1, 'Random Forest encoding... (supervised encoding)\n');
            val_param = validateRFparam(param);
            [sigTrain, sigTest] = ...
                    encoderRF(bofTrain, bofTest, labelTrain, labelTest, val_param);
        otherwise
            error('Now only support 3 kinds of encoding ways: BoW, FV and RF\n');
    end
                                
end