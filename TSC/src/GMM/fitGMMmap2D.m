% use mean-shift to fit Gaussian Mixture models of probmap

function modes = fitGMMmap2D(probmap, nSamples, msParam)
    
    narginchk(1,3);
    if ~exist('nSamples', 'var') || isempty(nSamples)
        nSamples = 50000;
    end

    if ~exist('msParam', 'var') || isempty(msParam)
        msParam = validateMeanShiftparam;
    end

    msParam = validateMeanShiftparam(msParam);
    msBW    = msParam.bandWidth;

    rawmap = probmap;  %% maybe problematic, because there may exist a lot of negative values
    probmap(probmap < 0) = 0; % just in case

    [m, n] = size(probmap);
    probmap = probmap ./ sum(probmap(:)); % normalize

    [X, Y] = meshgrid(1:n, 1:m);
    ismp = discretesample(probmap, nSamples);

    samples = [X(ismp)+rand(1,nSamples); Y(ismp)+rand(1,nSamples)];
    [clustCent, data2cluster,cluster2dataCell] = MeanShiftCluster(samples, msBW);
    iMu = clustCent';
    nG = size(iMu, 1);

    mu      = zeros(nG,2);
    covmat   = zeros(2, 2, nG);
    peaki  = zeros(nG,1);
    sumi  = zeros(nG,1);
    
    cntModes = 0;
    modes = validateGMMmodesparam;

    for i = 1:nG

        if length(cluster2dataCell{i}) <= 2
            mu(i,:) = [1 1];
            peaki(i) = 0;
            sumi(i) = 0;
            continue;
        end


        ci = samples(:,cluster2dataCell{i})';
        covci = cov(ci);
        rx = 2*sqrt(covci(1,1));
        ry = 2*sqrt(covci(2,2));

        cx = iMu(i,1);
        cy = iMu(i,2);

        x0 = max(1, round(cx - rx));
        y0 = max(1, round(cy - ry));
        x1 = min(n, round(cx + rx));
        y1 = min(m, round(cy + ry));


        img = rawmap(y0:y1, x0:x1);
        sumi(i) = sum(img(:));

    %     [center,covci_1] = covMass(img);
    %     cx = x0 + center(2);
    %     cy = y0 + center(1);
        cy = max(1, round(cy));
        cy = min(cy, m);
        cx = max(1, round(cx));
        cx = min(cx, n);
        peaki(i) = rawmap(cy, cx);
        covmat(:,:,i) = covci;
        mu(i,:) = [cx cy];
        
        cntModes = cntModes + 1;
        modes(cntModes).center  = mu(i,:);
        modes(cntModes).cov     = covci;
        modes(cntModes).peaki   = peaki(i);
        modes(cntModes).sumi    = sumi(i);
        

    end
end
