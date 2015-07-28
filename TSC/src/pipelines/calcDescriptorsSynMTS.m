% calculate descriptors for subsequences sampled from multivariate time
% series. Now dimensions are synchronized!

function descs =  calcDescriptorsSynMTS(subsequences, descriptorName, param)
    
    if ~iscell(subsequences) 
        error('The 1st parameter should be a cell array\n');
    end    
      
    descs = cell(1,1);
    nSubsequences  =  numel(subsequences);
    descriptors   = cell(nSubsequences,1);

    for j=1:nSubsequences
        seqs = subsequences{j};
        ndims = size(seqs,2);
        vec = [];
        for i=1:ndims
            vec = cat(2,vec,  calcDescriptor(seqs(:,i), descriptorName, param));
        end
        descriptors{j} = vec;
    end
    
    descs{1} = descriptors;
    
end