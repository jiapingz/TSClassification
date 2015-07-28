% fisher vector encoding

function [muSig, covSig] = FisherVector(descriptorsAct, K, mu, covMats, weights)

%     mu              = GMModel.mu;
%     covMats         = GMModel.Sigma;
%     weights          = GMModel.PComponents;
    dims = size(mu, 2);

    descriptorsSeq  =   [];
    nActs  =   size(descriptorsAct,1);
    nSeq_Acti = zeros(1, nActs);

    for i=1:nActs
        descriptorsSeq      = [descriptorsSeq; cell2mat(descriptorsAct{i})];
        nSequences      = size(descriptorsAct{i},1);
        nSeq_Acti(i) =  nSequences;
    end

    nSeq_Acti_Idx = [0 cumsum(nSeq_Acti)];
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
    muSig = zeros(nActs, dims*K);
    covSig = zeros(nActs, dims*K);
    for i=1:nActs
        sidx = nSeq_Acti_Idx(i)+1;
        eidx = nSeq_Acti_Idx(i+1);
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