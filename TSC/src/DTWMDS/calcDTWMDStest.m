function vec =  calcDTWMDStest(sequence, DTWMDSmodel)
% calculate DTWMDS encoding vector for any test sequence
% inputs: 
%           sequence --  a test sequence, mxn, m: # of time stamps, n:
%                        dimensions
%           DTWMDSmodel -- DTWMDSmodel, gotten on training data
% ouputs:
%           vec     -- encoding vector of the test sequence

    narginchk(2,2);
    if ~exist('sequence', 'var') || isempty(sequence) || ...
           ~exist('DTWMDSmodel', 'var') || isempty(DTWMDSmodel)
       error('Make sure you input both a test sequence and a model\n');
    end

    DTWMDSmodel = validateDTWMDSmodelParam(DTWMDSmodel);
    nDims               =   DTWMDSmodel.nDims;
    nClusters           =   DTWMDSmodel.nClusters;
    nRepresentative     =   DTWMDSmodel.nRepresentative;    
    nIterLM             =   DTWMDSmodel.nIterLM; 
    representatives     =   DTWMDSmodel.representatives;
    representativesVecs =   DTWMDSmodel.representativesVecs;
    cntRepresentatives  =   DTWMDSmodel.cntRepresentatives;
    clusterCenters      =   DTWMDSmodel.centers;
    
    
    % computer encoding vector of sequence
    options = optimset('Display', 'off', 'Algorithm', 'levenberg-marquardt',...
            'MaxIter',nIterLM,'MaxFunEvals',100);
	iseq = sequence;
	dist2centers = dist2(iseq(:)', clusterCenters);
    [~,icluster] = min(dist2centers);

    if cntRepresentatives(icluster) == nRepresentative
        iRepresentatives = representatives{icluster};
        iDTWMDS = representativesVecs{icluster};
    else
        iRepresentatives = representatives{icluster};
        iDTWMDS = representativesVecs{icluster};

        icnt = cntRepresentatives(icluster);
        icnt_ = nRepresentative - icnt;
        iflag = (1:nClusters) ~= icluster;
        representatives_ = representatives(iflag);
        representativesDTWMDS_ = representativesVecs(iflag);

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
    parfor j=1:jcnt
        d(j) = DTWfast(iseq(:), iRepresentatives{j});
    end

    iseq = (iseq(:))';
    iRatio = length(iseq)/nDims;
    x = imresize(iseq, [1 nDims]) * sqrt(iRatio);
    x=lsqnonlin(@(x)MDS_cost_vector(x,d,iDTWMDS),x,[],[],options);

	vec = x;
    
end