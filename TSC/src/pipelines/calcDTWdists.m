
function distDTW = calcDTWdists(set1, set2)
    flag = false;
    if nargin == 1
        set2 = set1;
        flag = true;
    end;
    
    if ~iscell(set1) || ~iscell(set2) || ...
            ~iscell(set1{1}) || ~iscell(set2{1})
        error('Two inputs should be cell array\n');
    end
        
    nSet1 = numel(set1);
    nSet2 = numel(set2);
    
    dim1 = numel(set1{1});
    dim2 = numel(set2{1});
    if dim1 ~= dim2
        error('multi-dimensional time series should have the same dimensions\n');
    end
    dim = dim1;
    distDTW = zeros(nSet1, nSet2, dim);
    
    switch flag
        case false
            for i=1:nSet1
                ts1 = set1{i};
                fprintf(1, 'Processing %d/%d...\n', i, nSet1);
                for j=1:nSet2
                    ts2 = set2{j};
                    vec = zeros(1,dim);
                    parfor k=1:dim
                        k_ts1 = ts1{k};
                        k_ts2 = ts2{k};
                        vec(k) = dtw_c(k_ts1(:), k_ts2(:));
                    end
                    distDTW(i,j,:) = vec;
                end
            end
            
        case true
            for i=1:nSet1
                ts1 = set1{i};
                fprintf(1, 'Processing %d/%d...\n', i, nSet1);
                for j=i+1:nSet2
                    ts2 = set2{j};
                    vec = zeros(1,dim);
                    parfor k=1:dim
                        k_ts1 = ts1{k};
                        k_ts2 = ts2{k};
                        vec(k) = dtw_c(k_ts1(:), k_ts2(:));
                    end
                    distDTW(i,j,:) = vec;
                end
            end            
%            distDTW = distDTW + distDTW';   

            for i=1:nSet1
                for j=1:i-1
                    distDTW(i,j,:) = distDTW(j,i,:);
                end
            end
            
    end

end