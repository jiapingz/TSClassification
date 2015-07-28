
% calculate descriptors for time series(multidimensional time series)
% in one dataset , MTS must be synchronized

function descriptors = calcDescriptorsSynMTSbatch(subsequences, descriptorName, param)
    
    nTimeSeries = numel(subsequences);
    descriptors = cell(nTimeSeries,1);
    
    for i=1:nTimeSeries
        fprintf(1, 'calculate descriptors: %s %d/%d\n', descriptorName, i, nTimeSeries);
        iTS_subsequences = subsequences{i};
        if ~iscell(iTS_subsequences) 
            error('The 1st parameter should be in cell data type\n');
        end        
        descriptors{i} = calcDescriptorsSynMTS(iTS_subsequences, descriptorName, param);        
    end

end