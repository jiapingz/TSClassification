
function fileName = generateEncoderFileName(encoderName, param)
    
    switch encoderName
        case 'BoW'
            fileName = generateBoWFileName(param);
        case 'RF'
            fileName = generateRFFileName(param);
        case 'FV'
            fileName = generateFVFileName(param);
        otherwise
            error('Only support 3 kinds of encoding methods\n');
    end
    
end