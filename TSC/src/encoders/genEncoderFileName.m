
function encoderFileName = ...
                    genEncoderFileName(descriptorFileName, tmpEncoderFileName)
    error(nargchk(2,2,nargin));
	encoderFileName = sprintf('%s-%s', descriptorFileName, tmpEncoderFileName);    
end