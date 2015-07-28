% run online encoding of test time series sequences, after you got the
% trained model

function sigTest = runOnlineEncoding(bofTest, encoderName, model)

    error(nargchk(3,3,nargin));
    
    nDims = numel(bofTest{1});
    sigTest   = cell(1,nDims);
              
    for i=1:nDims
        i_bofTest  = extractDimensionASynMTS(bofTest, i);

        switch encoderName
            case 'BoW'
                fprintf(1, 'BoW encoding...\n');
                sigTest{i} = onlineEncodingBoW(i_bofTest, model);
            case 'FV'
                fprintf(1, 'Fisher Vector encoding...\n');
                sigTest{i} = onlineEncodingFV(i_bofTest, model);
            case 'RF'
                fprintf(1, 'Random Forest encoding... (supervised encoding)\n');
                sigTest{i} = onlineEncodingRF(i_bofTest, model);
            otherwise
                error('Now only support 3 kinds of encoding ways: BoW, FV and RF\n');
        end

    end
                                
end