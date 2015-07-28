% make sure: each row of subsequences is feature vector of one observation
% each column is an observation
function symbols = symbolizationKMeans(subsequences, K)

    nSamples  =   size(subsequences,1);    
    idxSamples = [];
    feats = [];
    for i=1:nSamples
        idxSamples = cat(1, idxSamples, i*ones(size(subsequences{i},1),1));
        if iscell(subsequences{i})
            feats  = cat(1, feats, cell2mat(subsequences{i}));
        elseif ismatrix(subsequences{i})
            feats  = cat(1, feats, subsequences{i});
        else
            error('unsupported format of the 1st input\n');
        end
    end
    
    fprintf(1,'K-means to get the vocabulary\n');
    [idx2CTrain,~] = ...
        kmeans(feats, K, 'emptyaction','singleton', 'replicates', 1);
    
    % bow of training samples
    symbols = cell(nSamples,1); 
    for i=1:nSamples
        flag = idxSamples == i;
        symbols{i} = idx2CTrain(flag);
    end
    
end