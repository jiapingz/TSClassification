
function sigTest = onlineEncodingRF(bofTest, model)   
      
    model = validateRFmodel(model);
    nBins       = model.nbins;
    nClasses    = model.nclasses;
    B           = model.B;
    
    if isempty(B) || isempty(nBins) || isempty(nClasses)
        error('Please check the trained model\n');
    end
    
    sigTest = RFEncoding(B, bofTest, nClasses, nBins);

end