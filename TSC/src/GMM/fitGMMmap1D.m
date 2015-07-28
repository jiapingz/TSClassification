% use mean-shift to fit Gaussian Mixture models of probmap
% inputs:
%         probmap   - a probability density map, from which we sample points
%         nSamples  - the number of points to be sampled, the more the
%                     better
%         msParam   - mean shift parameter (set by validateMeanShiftparam)
% output: modes     - information of each density center

function modes = fitGMMmap1D(probmap, nSamples, msParam)  
    narginchk(1,3);
    if ~isvector(probmap)
        error('Only support GMM approximation of 1D signals\n');
    end
    if numel(probmap) == 1
        modes = []; return;
    end
    if ~exist('nSamples', 'var') || isempty(nSamples)
        nSamples = 50000;
    end

    if ~exist('msParam', 'var') || isempty(msParam)
        msParam = validateMeanShiftparam;
    end

    msParam = validateMeanShiftparam(msParam);
    msBW    = msParam.bandWidth;

    % 1. normalize probmap, such that it becomes a pdf
    if iscolumn(probmap)
        probmap = probmap';
    end
    rawmap = probmap;  %% maybe problematic, because there may exist a lot of negative values
    probmap(probmap < 0) = 0; % just in case
    probmap = probmap ./ sum(probmap(:)); % normalize

    [m, n] = size(probmap);
    % 2. draw samples from pdf
    [X, Y] = meshgrid(1:n, 1:m);
    ismp = discretesample(probmap, nSamples);

    samples = [X(ismp)+rand(1,nSamples); ones(1, numel(ismp))];
    [clustCent, data2cluster,cluster2dataCell] = MeanShiftCluster(samples, msBW);
    iMu = clustCent';
    nG = size(iMu, 1);

    me      = zeros(nG,1);
    covmat  = zeros(1, nG);
    peaki   = zeros(nG,1);
    sumi    = zeros(nG,1);
     
    modes = validateGMMmodesparam;
    cntModes = 0;
    for i = 1:nG

        if length(cluster2dataCell{i}) <= 2
            me(i,:) = 1;
            peaki(i) = 0;
            sumi(i) = 0;
             continue;
        end


        ci = samples(:,cluster2dataCell{i})';
        ci = ci(:,1);
        covci = cov(ci);
        rx = 1.5*sqrt(covci(1));

        cx = iMu(i,1);

        x0 = max(1, round(cx - rx));
        x1 = min(n, round(cx + rx));   
        
        xmin = max(1, min(ci));
        xmax = min(n, max(ci));

        img = rawmap(x0:x1);
        sumi(i) = sum(img(:)); 

        cx = max(1, round(cx));
        cx = min(cx, n);
        peaki(i) = rawmap(cx);
        covmat(:,i) = covci;
        me(i) = cx;
        
        cntModes = cntModes + 1;
        modes(cntModes).center  = cx;
        modes(cntModes).cov     = covci;
        modes(cntModes).peaki   = peaki(i);
        modes(cntModes).sumi    = sumi(i);
        modes(cntModes).span    = [x0 x1];
        modes(cntModes).scope   = [xmin xmax];
    end


end