
function sigTest = onlineEncodingFV(bofTest, model)

    model = validateFVmodel(model);
    GMModel = model.GMModel;
    mu          = GMModel.mu;
    covMats     = GMModel.Sigma;
    w           = GMModel.PComponents;
    K           = GMModel.NComponents;
    
    if isempty(mu) || isempty(covMats) || ...
            isempty(w) || isempty(K)
        error('Please check validity of the trained model\n');
    end
    
    [muSigTest, covSigTest]   = FVEncoding(bofTest, K, mu, covMats, w);
    sigTest     = [muSigTest covSigTest];

    
end