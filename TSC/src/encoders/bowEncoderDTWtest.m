% encode test time series 
% input: clusters(cell), which are gotten by dynamic time warping
%        TS(cell): time series to be encoded, each cell element contains a
%        sequence of subsequences sampled from raw time series
% output: descriptors of input time series

% distance between each subsequence and a cluster is defined as the minimum
% distance between that subsequence and each subsequence in that cluster
function descriptors =bowEncoderDTWtest(clusters, TS)
    if nargin ~= 2
        error('wrong number of input parameters\n');
    end
    
    if ~iscell(clusters) || ~iscell(TS)
        error('wrong type of input parameters\n');
    end
    nClusters = size(clusters,1);
    nTS = size(TS,1);
    descriptors = zeros(nTS, nClusters);
    
    for i=1:nTS
        fprintf(1, 'Encoding of test time series under DTW-MDS: %d\n',i);
        iTS = TS{i};
        nSequences = size(iTS,1);
        iDescriptor = zeros(1,nClusters);
        
        for j=1:nSequences   
            jSequence = iTS{j};
            jDists = zeros(nClusters,1);
            for k=1:nClusters
                jDists(k) = dist2clusterDTW(jSequence, clusters{k});
            end
            [~, idx] = sort(jDists, 'ascend');
            iDescriptor(idx(1)) = iDescriptor(idx(1)) + 1;
        end
        descriptors(i,:) = iDescriptor;
    end
  
end

% cluster(cell);
% sequence(mat);
function dist = dist2clusterDTW(sequence, cluster)
   cSize = size(cluster,1);
   dists = zeros(cSize,1);
   
   for i=1:cSize
       ref = cluster{i};
       dists(i) = dtw_c(ref, sequence);
   end
   dist = min(dists);    
end



