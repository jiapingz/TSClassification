% represent a time series as a bag of patterns, please refer to Jessica Lin
% for details (2012)
% INPUTS: 
% slideWinSize: the size of the sliding window
% SAXsize:      the length after representation by SAX string
% alphbet_size: the number of discrete symbols
% NR_opt:       whether using numerosity reduction or not

% currently, the function only support 1-D time series
% don't support multidimensional time series yet
function bow = bowEncoderSAX(TS, slideWinSize, SAXsize, alphabet_size, NR_opt)

	symbolic_data =  timeseries2symbol(TS, slideWinSize, SAXsize, alphabet_size, NR_opt);
    idx = zeros(size(symbolic_data,1),1);
    
    for i=1:length(symbolic_data)
        idx(i) = mapSAX2IDX(symbolic_data(i,:), SAXsize, alphabet_size);
    end
    
    maxIdx = 0;
    for i=1:SAXsize
        maxIdx = maxIdx + alphabet_size * power(alphabet_size, i-1);
    end
    
	[bow, ~] = hist(idx, 1:maxIdx);
    bow = sparse(bow);
end

function numIdx =  mapSAX2IDX(symbolic_data, SAXsize, alphabet_size)
    locIdx = 1:SAXsize;
    numIdx = 0;
    
    for i=1:SAXsize
        numIdx = numIdx + symbolic_data(i) * power(alphabet_size, locIdx(i)-1);
    end
    
end
