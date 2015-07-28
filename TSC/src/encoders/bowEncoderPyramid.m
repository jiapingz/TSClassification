% first decompose the time series, then represent the time series 
% by concatenation of histograms in different layers
% this is similar to beyond bag of words by Lazebnik

function encoder = bowEncoderPyramid(symbols, nclasses, nlayers)

    % first generate a decomposition tree, according to information gain
    t = genDecomposeTree(symbols, nclasses, 'depth', nlayers, 'MinLeaf', 1);
    iterator = t.breadthfirstiterator; 
    
    %% have to handle this singularity later on !!!
    if max(iterator) ~= (power(2, nlayers+1) - 1)
        encoder = zeros(1, nclasses * (power(2,nlayers+1) - 1));
        return;
    end
    
    encoder = [];
    for i=0:nlayers
        sidx = power(2, i);
        cnt  = power(2, i);
        eidx = sidx + cnt -1;
        
        idx = iterator(sidx:eidx);
        for j=1:length(idx)
            k = idx(j);
            node = t.get(k);
            subSymbols = node.representation;
            
            % transform into a histogram (actually frequency)
            [count, ~] = hist(subSymbols, 1:nclasses);
            encoder = cat(2,encoder, count);
        end
        
        
    end
   
end