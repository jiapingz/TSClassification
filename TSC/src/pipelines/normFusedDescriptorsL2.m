% fuse two descriptors: make sure each of they have the same l2 norm
% suitable for both univariate and multivariate time series descriptors
% the format of descriptors(nested cells) is specifically designed for this
% projects
function norm_descriptors = normFusedDescriptorsL2(descriptors, cutline)
    if isempty(descriptors) || ~iscell(descriptors) ...
                                    || ~iscell(descriptors{1})
        error('Wrong format of the input parameters\n');
    end
    nDims      = numel(descriptors{1});
    nInstances = numel(descriptors);
    norm_descriptors = descriptors;
     for i=1:nDims
        i_descriptors = {};
        i_nInstances = [];
        for j=1:nInstances            
            i_nInstances  = cat(1, i_nInstances,  numel(descriptors{j}{i}));
            i_descriptors = cat(1, i_descriptors, descriptors{j}{i});            
        end
        i_descriptors = cell2mat(i_descriptors);
        
        i_descriptors1 = i_descriptors(:,1:cutline);
        i_descriptors2 = i_descriptors(:,cutline+1:end);
        
        len1 = mean(sqrt(sum(i_descriptors1.*i_descriptors1,2)));
        len2 = mean(sqrt(sum(i_descriptors2.*i_descriptors2,2)));
        
        i_descriptors1 = i_descriptors1/len1;
        i_descriptors2 = i_descriptors2/len2;
        
        i_descriptors = [i_descriptors1 i_descriptors2];
        
        i_descriptors = mat2cell(i_descriptors, i_nInstances);
        
        for j=1:nInstances
            norm_descriptors{j}{i} = ...
                    mat2cell(i_descriptors{j},ones(size(i_descriptors{j},1),1));
        end         
     end
    
end