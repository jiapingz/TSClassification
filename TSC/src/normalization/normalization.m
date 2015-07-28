% normalization of time series representation
% data: arranged row by row
% method: 'l1', 'l2', 'power' & null
function norm_data = normalization(data, method, param)
    error(nargchk(2,3,nargin));
    norm_data = data;
    switch method
        case 'l1'
            norm_data = data./repmat(sum(abs(data),2), 1, size(data,2));
        case 'l2'
            norm_data = data./repmat(sqrt(sum(data.*data,2)), 1, size(data,2));
        case 'power'
            norm_data = sign(norm_data) .* power(abs(data), param.alpha);
        otherwise
            norm_data = data;            
    end
    
end