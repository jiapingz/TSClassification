
% calculate descriptors for subsequences sampled from time series( or
% multidimensional time series)
% to allow different subsequences, each subsequence is stored in format of
% cell (allowing varying length), intead of matrix

function descriptors = calcDescriptorsTS(subsequences, descriptorName, param)
    
    if ~iscell(subsequences) && ~iscell(subsequences{1})
        error('The 1st parameter should be a cell array\n');
    end
    
    nDims = numel(subsequences);
    descriptors = cell(1,nDims);
    
    for i=1:nDims
        fprintf(1, 'compute descriptors: %s  of the %d dimension\n', descriptorName, i);        
        i_subsequences  = subsequences{i};        
        i_nsubsequences = numel(i_subsequences);
        i_descriptors   = cell(i_nsubsequences,1);
        
        for j=1:i_nsubsequences
            seq = i_subsequences{j};
            i_descriptors{j} = calcDescriptor(seq, descriptorName, param);
            
        end        
        descriptors{i} = i_descriptors;
    end
    
end