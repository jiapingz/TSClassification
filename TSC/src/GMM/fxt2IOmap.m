
% this function is used to produce IO maps from fixation locations
% IO maps are saved in form of png 
function IOmap = fxt2IOmap(stimuliNames, stimuliDims, fxts, gauBlob, saveFolder)
    
    if ~iscell(stimuliNames) || ~iscell(stimuliDims) || ...
               size(stimuliNames,1) ~= size(stimuliDims,1) ||...
                size(stimuliNames,1) ~= size(fxts,1)
           error('All the first 3 parameters should be in form of cells\n');
    end
    
    
    if ~isstruct(gauBlob)
        error('wrong type of the 3rd parameter\n');
    end
    
    if ~isfield(gauBlob, 'blobsize') || ~isfield(gauBlob, 'sigma')
        error('wrong fields of the struct\n')
    end
    
    outputflag = false;
    if nargout ~= 0
        outputflag = true;
    end
    
    if outputflag == false && ~exist(saveFolder)
        mkdir(saveFolder);
    end
    
    blobSize = gauBlob.blobsize;    
    sigma  = gauBlob.sigma;
        
    % generate a gaussian patch, whose sigma is fixed
    gauPatch = generateGaussianBlob(blobSize, sigma);
    xPatch = blobSize(2);
    yPatch = blobSize(1);
    xPatchHalf = round(xPatch/2.0);
    yPatchHalf = round(yPatch/2.0);    
    
	epsilon = 1.0e-6;
    
    nStimuli = size(stimuliNames,1);
    rng('shuffle');
    ord = randperm(nStimuli);
    for k=1:nStimuli
        i = ord(k);
        name = stimuliNames{i};
        name = pruneExtStr(name);
        
        if outputflag == false && exist(strcat(saveFolder, '/', name, '.png'), 'file')
            fprintf(1,'exist\n');
            continue;
        end
            
        
        IOmap = zeros(stimuliDims{i});
        fixations = fxts{i};        
        nFxts = size(fixations,1);        
        
        yIO = round(stimuliDims{i}(1));
        xIO = round(stimuliDims{i}(2));
        rect1 = [1 1 xIO yIO];

        for j=1:nFxts
                       
            xCenter = fixations(j,2);
            yCenter = fixations(j,1);
            
            xstart = round(xCenter - xPatchHalf);
            xend = round(xstart + xPatch - 1);
            
            ystart = round(yCenter - yPatchHalf);
            yend = round(ystart + yPatch - 1);
            
            rect2 = [xstart, ystart, xend, yend];
            
            [idx1, idx2] = intersection4rect(rect1, rect2);
            idx1 = logical(reshape(idx1, yIO, xIO));
            idx2 = logical(reshape(idx2, yPatch, xPatch));
            IOmap(idx1) = IOmap(idx1) + gauPatch(idx2);
            
        end
        
        if (max(IOmap(:)) - min(IOmap(:))) < epsilon
            continue;
        end
        
        % normalization to [0 1]
        IOmap = double(IOmap - min(IOmap(:)))/double(max(IOmap(:)) - min(IOmap(:))); 
        if outputflag == false
            imwrite(IOmap, strcat(saveFolder, '/', name, '.png'));
        end
    end
    
    
    
    
end