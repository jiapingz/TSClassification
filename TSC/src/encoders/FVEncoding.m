% fisher vector encoding

function [muSig, covSig] = FVEncoding(localDescriptors, K, mu, covMats, weights)

    error(nargchk(5,5,nargin));
    if ~iscell(localDescriptors)
        error('the 1st input should be cell\n');
    end
    
    if iscell(localDescriptors{1})
        bcell = true; bmat = false;
    elseif ismatrix(localDescriptors{1})
        bcell = false; bmat = true;
    end
    
    dims = size(mu, 2);

    descriptorsSeq  =   [];
    nInstances      =   numel(localDescriptors);
    nSubsequences_Instances       =   zeros(1, nInstances);

    for i=1:nInstances
        if bcell
            descriptorsSeq  = cat(1, descriptorsSeq, cell2mat(localDescriptors{i}));
        elseif bmat
            descriptorsSeq  = cat(1, descriptorsSeq, localDescriptors{i});
        else
            error('unsupported format of the 1st input\n');
        end
        nSequences      = size(localDescriptors{i},1);
        nSubsequences_Instances(i) =  nSequences;
    end

    nSeq_Inst_Idx = [0 cumsum(nSubsequences_Instances)];
    %% fisher vector of training activities

    % 1.1 soft assignment
    nSeqs = size(descriptorsSeq,1);
    probSeqs = zeros(nSeqs,K);
    for i=1:nSeqs
        fe = descriptorsSeq(i,:);
        for j=1:K
            kcovMat = covMats(:,:,j);
            det_kcovMat =  kcovMat * ones(dims,1);
            i_kcovMat = diag(1./kcovMat);
            probSeqs(i,j) = 1/sqrt(det_kcovMat*(2*pi)^dims) * ...
                    exp(-0.5*(fe-mu(j,:))*i_kcovMat*(fe-mu(j,:))');
        end
    end
    probSeqs = probSeqs .* repmat(weights, nSeqs, 1);
    nProbSeqs = probSeqs./repmat(sum(probSeqs,2),1,K);

    % 1.2 vector encoding
    muSig = zeros(nInstances, dims*K);
    covSig = zeros(nInstances, dims*K);
    for i=1:nInstances
        sidx = nSeq_Inst_Idx(i)+1;
        eidx = nSeq_Inst_Idx(i+1);
        nSeqs = eidx - sidx + 1;

        for k=1:K
            sigmaK = squeeze(covMats(:,:,k));
            muK = mu(k,:);
            wK = weights(k);
            for j=sidx:eidx
                ijSeq = descriptorsSeq(j,:);
                pk = nProbSeqs(j,k);
                muSig(i,(k-1)*dims+1:k*dims) = muSig(i,(k-1)*dims+1:k*dims) + ...
                        pk*(ijSeq - muK)./sqrt(sigmaK);

                covSig(i,(k-1)*dims+1:k*dims) = covSig(i,(k-1)*dims+1:k*dims) + ...
                    pk*((ijSeq - muK).^2./sigmaK-1);
            end
            muSig(i,(k-1)*dims+1:k*dims) = muSig(i,(k-1)*dims+1:k*dims)/(nSeqs*sqrt(wK));
            covSig(i,(k-1)*dims+1:k*dims) = covSig(i,(k-1)*dims+1:k*dims)/(nSeqs*sqrt(2*wK));

        end    
    end


end