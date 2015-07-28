function  nDims  = getDimsHOG1D(seqlen, param)

    if nargin <= 1
        param.cells         = [1 25];   % unit: t
        param.overlap       = 0;
        param.gradmethod    = 'centered'; % 'centered'
        param.nbins         = 8;
        param.sign          = 'true';
        param.xscale         = 0.1;
    end
    
    if nargin < 1
        error('Not enough inputs\n');
    end
    
    
    val_param   = validateHOG1Dparam(param); 
    cells       = val_param.cells;
	nbins       = val_param.nbins;
  
    sCell   = cells(2);
    overlap = val_param.overlap;   
    
     % now we only suport maximal number of 10 blocks
    ref_lens = zeros(10,1);
    for i=1:10
        ref_lens(i) = sCell*i - overlap*(i-1);
    end
    [~, idx] = min(abs(ref_lens - seqlen));
    
    nBlock = idx; 
	nDims = nBlock * nbins;
    
    
end