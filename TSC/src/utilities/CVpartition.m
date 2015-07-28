
% labeling starts from 1, 2, ...
function [idxTrain, idxTest] = CVpartition(labels, nclasses, nFolders)
    % this function is obselete, won't be used in future !!!
    
    error(nargchk(3,3,nargin));
    idxTrain = cell(nFolders,1);
    idxTest  = cell(nFolders,1);
    
    classIdx = cell(nclasses,1);
    markers  = cell(nclasses,1);
    labels = labels(:);
    rng('shuffle');
    for i=1:nclasses
        classIdx{i} = find(labels == i);
        nsamples = sum(labels==i);
%         randidx = randperm(nsamples);
%         shuffledIdx = classIdx{i}(randidx);
%         classIdx{i} = shuffledIdx;
        if nsamples < nFolders
            markers{i} = 0;
            continue;
        end
        
        folderSize = floor(nsamples/nFolders);
        if folderSize * nFolders == nsamples
            markers{i} = folderSize * ones(1, nFolders);
        else
            markers{i} = [folderSize * ones(1, nFolders-1) nsamples - folderSize*(nFolders-1)];
        end
        markers{i} = [0 cumsum(markers{i})];   
        
    end
    
    
    for i=1:nFolders        
        tmpTrainIdx = [];
        tmpTestIdx = [];
        for j=1:nclasses
            tmpIdx     = classIdx{j};
            tmpmarkers = markers{j};
            if ~isscalar(tmpmarkers)
                tmpTestIdx = cat(1, tmpTestIdx, tmpIdx(tmpmarkers(i)+1:tmpmarkers(i+1)));
                tmpTrainIdx = cat(1, tmpTrainIdx, ...
                                    setdiff(tmpIdx, tmpIdx(tmpmarkers(i)+1:tmpmarkers(i+1))));
            else
                randTestIdx = randi(length(tmpIdx));
                tmpTestIdx = cat(1, tmpTestIdx, tmpIdx(randTestIdx));
                tmpTrainIdx = cat(1, tmpTrainIdx, setdiff(tmpIdx, tmpIdx(randTestIdx)));
            end
            
        end
        
        idxTrain{i} = tmpTrainIdx;
        idxTest{i}  = tmpTestIdx;
    end
    
end