function kernelizedMap = GaussianKernelization2D(pts, dst_mapsize, gKernelParam, weights)
% kernel density estimation
% inputs:
%           pts          - points in   2D coordinates
%           dst_mapsize  - destination map size 
%           gKernelParam - gaussian kernel parameters

    narginchk(3,4);
    [nObservations, nDims] = size(pts);
    if nObservations < nDims 
        warning('Points should be organized row by row\n');
    end
    
    if ~exist('weights', 'var') || isempty(weights)
        weights = ones(nObservations,1);
    end
    
    gKernelParam = validateGKernelparam(gKernelParam);
    covmat = gKernelParam.cov;
    kernelizedMap = zeros(dst_mapsize);
    % generate a gaussian patch, whose sigma is fixed
    for i=1:nObservations
        ipt  = pts(i,:);
        cx = ipt(1); 
        cy = ipt(2);
        map =  GaussianMap2D(dst_mapsize, cx, cy, covmat);
        kernelizedMap = kernelizedMap + weights(i)*map;

    end

    if (max(kernelizedMap(:)) - min(kernelizedMap(:))) < eps
        return;
    end
    % normalization to [0 1]
    kernelizedMap = double(kernelizedMap - min(kernelizedMap(:)))/double(max(kernelizedMap(:)) - min(kernelizedMap(:))); 

end