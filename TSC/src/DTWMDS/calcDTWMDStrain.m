
function [DTWMDSvecs, DTWMDSmodel] = calcDTWMDStrain(sequences, DTWMDSparam)
% inputs:   
%       sequences -- sampled subsequences from time series instances
%                    sequences, should be stored in cell
%                    for multi-variate time series, dimensions are
%                    organized column-wisely
%       DTWMDSparam -- parameter setting for DTWMDS 

% outputs:
%       vecs -- calculated DTWMDS vectors 
%       DTWMDSmodel -- DTWMDS model, used for later on encoding of a
%                      subsequence

% this function works for both univariate and multivariate time series


    narginchk(1,2);
    
    if ~exist('sequences', 'var') ...
            || isempty(sequences) || ~iscell(sequences)
        error('The input subsequences should be a cell array\n');
    end
    
    if ~exist('DTWMDSparam', 'var') || ...
            isempty(DTWMDSparam)
        DTWMDSparam = validateDTWMDSparam();
    end
    
    nDims           =   DTWMDSparam.nDims;
    nClusters       =   DTWMDSparam.nClusters;
    nRepresentative =   DTWMDSparam.nRepresentative;
    nIter           =   DTWMDSparam.nIter;
    nIterLM         =   DTWMDSparam.nIterLM;
    
    nSeqs = numel(sequences);
    
    
    %(0) cell2mat
    sequences_mat = [];
    for i=1:nSeqs
        sequences_mat = cat(1, sequences_mat, (sequences{i}(:))');
    end        
    
    if size(sequences_mat,1) < nClusters
        nClusters = size(sequences_mat,1);
    end
    %(1) kmeans to cluster sequences into 'ncluseters'
    fprintf(1, 'training data: run Kmeans and randomly pick %d representatives from each cluster...\n', nRepresentative);
    kmeansParam             = validateKMeansparam;
    kmeansParam.nclusters   = nClusters;
    partitions = doClustering(sequences_mat, 'kmeans', kmeansParam);
    
    nClusters = numel(unique(partitions));
    partitionInd = sort(unique(partitions));
    centers = [];
    clusterMembers = cell(nClusters,1);
    for i=1:nClusters
        i_ind = partitions == partitionInd(i);
        centers = cat(1, centers, mean(sequences_mat(i_ind,:),1));
        clusterMembers{i} = sequences(i_ind);        
    end
    
    %(2) extract representatives from each cluster
    representatives = cell(nClusters,1);
    cntRepresentatives = zeros(nClusters,1);
    indRepresentatives = [];
    fRepresentatives = zeros(nSeqs,1) > 1.0;
    rng('shuffle');
    for i=1:nClusters
        i_ind = partitions == partitionInd(i);
        ridx = randperm(sum(i_ind));
        cnt = min(sum(i_ind), nRepresentative);
        
        i_ind = find(i_ind);
        i_rep = i_ind(ridx(1:cnt));
        representatives{i} = sequences(i_rep);        
        fRepresentatives(i_rep) = true;
        cntRepresentatives(i) = cnt;
        indRepresentatives = cat(1, indRepresentatives, i_rep(:));
    end
    
    %(3) initialize representatives
	fprintf(1, 'training data: initialize representatives...\n');
    representativeSeqs = {};
    representativeVecs = [];
    initialDTWMDSvecs = cell(nClusters,1);
    for i=1:nClusters
        iRepresentatives = representatives{i};
        icnt = numel(iRepresentatives);
        ivecs = [];
        for j=1:icnt
            j_iRepresentative = (iRepresentatives{j}(:))';
            j_iRatio = length(j_iRepresentative)/nDims;
            ivecs = cat(1, ivecs, imresize(j_iRepresentative, [1 nDims]) * sqrt(j_iRatio));
        end
        initialDTWMDSvecs{i} = ivecs;
        representativeVecs = cat(1, representativeVecs, ivecs);
        representativeSeqs = cat(1, representativeSeqs, iRepresentatives);
    end
    
    % (4) solve DTWMDS vectors for representatives
    nRepresentatives = numel(representativeSeqs);
    d = zeros(nRepresentatives,nRepresentatives);
    
    for i=1:nRepresentatives
        iseq = representativeSeqs{i};
        parfor j=i+1:nRepresentatives
            jseq = representativeSeqs{j};
            [d(i,j), ~] = DTWfast(iseq, jseq);
        end
    end
    d = d + d';
    
    options = optimset('Display', 'off', 'Algorithm', 'levenberg-marquardt',...
            'MaxIter',nIterLM,'MaxFunEvals',100);
        
    
        
    
    tic;
    cnt = 1;
    X = representativeVecs;
	fprintf(1, 'calculate DTW-MDS descriptors of representatives...\n');

    while cnt < nIter      
        for i=1:nRepresentatives
            count=i;
            if mod(count,100)==0 
                fprintf('iter:%d  point: %d\n',cnt, count);
            end
            x=X(i,:);     
            iflag = (1:nRepresentatives) ~= i;
            V_dist=d(iflag,i);
            X_ = X(iflag,:);
            x=lsqnonlin(@(x)MDS_cost_vector(x,V_dist,X_),x,[],[],options);
            X(i,:)=x;
        end
        cnt = cnt + 1;
    end
    toc
     
%     tic;
%     Y = mdscale(d,nDims);
%     toc
% 	[X, total_cost]=MDS_training(d,nDims,nIter,0,1);
            
    representativeVecs = X;
    representativesDTWMDS = mat2cell(representativeVecs, cntRepresentatives,nDims);
    
    
	DTWMDSmodel.nDims               = nDims;
    DTWMDSmodel.nClusters           = nClusters;
    DTWMDSmodel.nRepresentative     = nRepresentative;    
    DTWMDSmodel.nIterLM             = nIterLM;
    DTWMDSmodel.representatives     = representatives;
    DTWMDSmodel.representativesVecs = representativesDTWMDS;
    DTWMDSmodel.cntRepresentatives  = cntRepresentatives;
    DTWMDSmodel.centers             = centers;
    
    % (5) solve DTWMDS vectors for left sequences in each cluster
	fprintf(1, 'calculate DTW-MDS descriptors of left training subsequences...\n');
    DTWMDSvecs = zeros(nSeqs,nDims);
    DTWMDSvecs(indRepresentatives,:) = representativeVecs;
    parfor i=1:nSeqs
        if fRepresentatives(i) == true            
            continue;
        end
        iseq = sequences{i};
        icluster = partitions(i);
        
        if cntRepresentatives(icluster) == nRepresentative
        	iRepresentatives = representatives{icluster};
            iDTWMDS = representativesDTWMDS{icluster};
        else
            iRepresentatives = representatives{icluster};
            iDTWMDS = representativesDTWMDS{icluster};
            
            icnt = cntRepresentatives(icluster);
            icnt_ = nRepresentative - icnt;
            iflag = (1:nClusters) ~= icluster;
            representatives_ = representatives(iflag);
            representativesDTWMDS_ = representativesDTWMDS(iflag);
            
            representatives_1 = {};
            representativesDTWMDS_1 = [];
            for j=1:nClusters-1
                representatives_1 = cat(1, representatives_1, representatives_{j});
                representativesDTWMDS_1 = cat(1, representativesDTWMDS_1, ...
                                                        representativesDTWMDS_{j});
            end
            rng('shuffle');
            jcnt = numel(representatives_1);
            jorder = randperm(jcnt);
            if jcnt < icnt_
                jRepresentatives = representatives_1;
                jDTWMDS          = representativesDTWMDS_1;
            else
                jRepresentatives = representatives_1(jorder(1:icnt_));
                jDTWMDS          = representativesDTWMDS_1(jorder(1:icnt_),:);
            end
            
            iRepresentatives = cat(1, iRepresentatives, jRepresentatives);
            iDTWMDS = cat(1, iDTWMDS, jDTWMDS);            
        end
        
        jcnt = numel(iRepresentatives);
        d = zeros(jcnt,1);
        for j=1:jcnt
            d(j) = DTWfast(iseq, iRepresentatives{j});
        end

        iseq = (iseq(:))';
        iRatio = length(iseq)/nDims;
        x = imresize(iseq, [1 nDims]) * sqrt(iRatio);
        x=lsqnonlin(@(x)MDS_cost_vector(x,d,iDTWMDS),x,[],[],options);

        DTWMDSvecs(i,:) = x;
    end
    
    
    
end