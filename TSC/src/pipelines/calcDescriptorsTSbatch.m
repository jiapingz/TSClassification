
% calculate descriptors for time series(multidimensional time series)
% in one dataset 

function descriptors = calcDescriptorsTSbatch(subsequences, descriptorName, param)
    
    nTimeSeries = numel(subsequences);
    descriptors = cell(nTimeSeries,1);
    
    for i=1:nTimeSeries
        fprintf(1, 'calculate %s of %d/%d time series...\n', descriptorName, i, nTimeSeries);
        iTS_subsequences = subsequences{i};
        if ~iscell(iTS_subsequences) && ~iscell(iTS_subsequences{1})
            error('The 1st parameter should be a cell data type\n');
        end        
        descriptors{i} = calcDescriptorsTS(iTS_subsequences, descriptorName, param);        
    end

end