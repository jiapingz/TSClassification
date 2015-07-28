% extract some dimensions, indicated by dim_idx, from multivariate time
% series (MTS)

% MTS can either be raw subsequences, or
% descriptors of subsequences
% input: dim_idx, index of the target dimension

function deMTS = extractDimensionASynMTS(MTS, dim_idx)
    error(nargchk(2,2,nargin));
    if isempty(MTS) ||  ~iscell(MTS)  || ~iscell(MTS{1})
        error('The 1st input should be a nested cell array\n');
    end
    
    nInstances = numel(MTS);
    nDims = numel(MTS{1});
    if dim_idx > nDims
        error('Index exceeds the dimensionality of MTS\n');
    end
    deMTS = cell(nInstances,1);
    
    for i=1:nInstances
        iInstance = MTS{i};
        iInstance = iInstance{dim_idx};
        deMTS{i} = iInstance;        
    end
end