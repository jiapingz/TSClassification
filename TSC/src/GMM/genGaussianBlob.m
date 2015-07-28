
% generate gaussian
function gauBlob = genGaussianBlob(GaussianKernel)

%{
    gKernel = validateGKernelparam(GaussianKernel);
    windowsize = gKernel.windowsize;
    covmat   = gKernel.sigma;
    %imgsize = [511 681];
    %sigma = 80;                             % gaussian standard deviation in pixels
    P = [round(windowsize(1)/2) round(windowsize(2)/2)];

    [Xm Ym] = meshgrid(-P(2):P(2), -P(1):P(1));             % 2D matrices
    s = covmat ;  
    gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) ); % formula for 2D gaussian
    gauBlob = imresize(gauss,windowsize);
 %}
    gKernel = validateGKernelparam(GaussianKernel);
    mapsize = gKernel.windowsize;
    covmat  = gKernel.cov;
    cx = mapsize(2)/2;
    cy = mapsize(1)/2;
    gauBlob =  GaussianMap2D(mapsize, cx, cy, covmat);


end