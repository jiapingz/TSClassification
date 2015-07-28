
function [dVec, descriptors] = calcDescriptorsDTWMDS(sequences, dVec, featDim)
    
    if ~exist('dVec', 'var') || isempty(dVec)
    % step 1:
        fprintf(1, 'calculating DTW distances between samples...\n');
        tic;
        dVec = dtw_2sets(sequences);    
        toc;
    end
    
% step 2:    
    fprintf(1, 'MDS to map DTW distances matrix into feature vectors...\n');
    tic;
    if min(dVec) > 0
        [descriptors,~] = mdscale(squareform(dVec),featDim);
    else
        [descriptors,~] = mdscale(squareform(dVec),featDim, 'Start', 'random');
    end
    toc;
    
end