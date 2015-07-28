% to fuse descriptors of the same subsequences;
% when there is large correlation between descriptors, it's better to fuse
% then first, and then fit into bow framework

% suitable for univariate and multivariate time series
function descriptors = mergeDescriptors(descriptors1, descriptors2)
    
    if ~iscell(descriptors1) || ~iscell(descriptors2) || ...
            ~iscell(descriptors1{1}) || ~iscell(descriptors2{1})
        error('Two inputs should be in format of cell arrays\n');
    end
    
    nSamples1 = numel(descriptors1);
    nSamples2 = numel(descriptors2);
    
    if nSamples1 ~= nSamples2
        error('# of samples inconsistency\n');
    end
    
    nSamples = nSamples1;
    
    nDims1 = numel(descriptors1{1});
    nDims2 = numel(descriptors2{1});
    
    if nDims1 ~= nDims2
        error('Dimensions inconsistency\n');
    end
    
    nDims = nDims1;
    
    descriptors = cell(nSamples,1);
    
    nDescriptors1 = descriptors1;
    nDescriptors2 = descriptors2;
 
    
    %% concatenation
    for i=1:nSamples
        tmp = cell(1, nDims);
        for j=1:nDims
            nsub = numel(nDescriptors1{i}{j});
            jtmp = cell(nsub,1);
            for k=1:nsub
                jtmp{k} = [nDescriptors1{i}{j}{k} nDescriptors2{i}{j}{k}];            
            end
            tmp{j} = jtmp;
        end
        descriptors{i} = tmp;
    end
  
end
