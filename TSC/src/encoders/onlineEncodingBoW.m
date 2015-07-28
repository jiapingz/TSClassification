% given the trained model, encode a test time series by bag of words

function  bowTest = onlineEncodingBoW(bofTest, model)
 

    model = validateBoWmodel(model);
    nTest   =   numel(bofTest);
    
    if iscell(bofTest{1})
        bcell = true; bmat = false;
    elseif ismatrix(bofTest{1})
        bcell = false; bmat = true;
    else
        error('Format error for the 1st two parameters\n');
    end   
    
    Centers = model.clusterCenters; 
    
    if ~ismatrix(Centers) || isempty(Centers)
        error('Please check the trained model\n');
    end
    
    K = size(Centers,1);
    
    % BoW of testing samples
    idx2CTesting = cell(nTest,1);
    bowTest = zeros(nTest,K);
    for i=1:nTest
        if bcell
            ibofTest = cell2mat(bofTest{i});
        elseif bmat
            ibofTest = bofTest{i};
        end
        nSeqs = numel(bofTest{i});
        idxSeqs = zeros(nSeqs,1);
        for j=1:nSeqs
           [~, idxSeqs(j)] = ...
               min(sum((repmat(ibofTest(j,:), K,1) - Centers).^2, 2));
        end
        idx2CTesting{i} = idxSeqs;
        [bowTest(i,:), ~] = hist(idxSeqs,1:K);
    end
    
end