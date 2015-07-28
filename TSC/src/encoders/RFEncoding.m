% random forest encoder

function sig = RFEncoding(BagClassifier, descriptorsSeq, nClasses, nBins)
                                        
    error(nargchk(4,4, nargin));
    
    if ~iscell(descriptorsSeq)
        error('local descriptors should be saved in a cell array\n');
    end
    
    if iscell(descriptorsSeq{1})
        bcell = true; bmat = false;
    elseif ismatrix(descriptorsSeq{1})
        bcell = false; bmat = true;
    end

    descriptors  =   [];
    nInstances  =   size(descriptorsSeq,1);
   
    nSubseq_inst = [];
    for i=1:nInstances
        if bcell
            descriptors = cat(1, descriptors, cell2mat(descriptorsSeq{i}));
        elseif bmat
            descriptors = cat(1, descriptors, descriptorsSeq{i});
        else
            error('unsupported format of the 2nd input\n');
        end
        nSubsequences = size(descriptorsSeq{i},1);
        nSubseq_inst = cat(2,nSubseq_inst, nSubsequences);
    end

    nSubseq_inst = [0 cumsum(nSubseq_inst)];
    % build a random forest classifier
  
    [~, scores] = predict(BagClassifier,descriptors);

    xVals = linspace(0,1,nBins+1);
    xvalues = zeros(1,nBins);
    for i=1:nBins
        xvalues(i) = (xVals(i) + xVals(i+1))/2;
    end
    
    % encode each time series in a way similar to soft-assignment
    sig = zeros(nInstances, nClasses*nBins);
    for i=1:nInstances
        iscores = scores(nSubseq_inst(i)+1:nSubseq_inst(i+1),:);
        for j=1:nClasses
            j_iscores = iscores(:,j);
            [nele,~] = hist(j_iscores,xvalues);
            sig(i, (j-1)*nBins+1:j*nBins) = nele;
        end  
    end
    
end