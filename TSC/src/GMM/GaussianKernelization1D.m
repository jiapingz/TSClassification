function kernelizedMap = GaussianKernelization1D(pts, dst_mapsize, gKernelParam, weights)
% kernel density estimation
% inputs:
%           pts          - points in   2D coordinates
%           dst_mapsize  - destination map size 
%           gKernelParam - gaussian kernel parameters

    narginchk(3,4);
    if ~isvector(pts)
        warning('Points should be in 1D\n');
    end
	nObservations = numel(pts);
    if ~exist('weights', 'var') || isempty(weights)
        weights = ones(nObservations,1);
    end
        
    gKernelParam = validateGKernelparam(gKernelParam);
    covmat = gKernelParam.cov;
    sigma = sqrt(covmat);
    kernelizedMap = zeros(dst_mapsize);
    % generate a gaussian patch, whose sigma is fixed
    for i=1:nObservations
        cx = pts(i);
        map =  GaussianMap1D(dst_mapsize, cx, sigma);
        kernelizedMap = kernelizedMap + weights(i)*map;

    end

    if (max(kernelizedMap(:)) - min(kernelizedMap(:))) < eps
        return;
    end
    % normalization to [0 1]
    kernelizedMap = double(kernelizedMap - min(kernelizedMap(:)))/double(max(kernelizedMap(:)) - min(kernelizedMap(:))); 

end