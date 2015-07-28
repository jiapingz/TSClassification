
function [alpha, cv_acc] = CValpha(sigTrain, labelsTrain, alphas, svmParam, partitions)
% this function is specifically designed for power factor tuning in SVM
% classifier
% inputs: 
%           sigTrain    --  signature of training examples
%           labelsTrain --  labels of training examples
%           alphas      --  range of power factors
%           svmParam    --  SVM parameter settings
%           partitions  --  partition of training files


    nAlpha = numel(alphas);
    cv_acc = zeros(1,nAlpha);
	for a=1:nAlpha        
        a_alpha = alphas(a);        
        cnt = zeros(1,size(partitions,2));        
        for f=1:size(partitions,2)
            f_testIdx       =   partitions(:,f);
            f_trainIdx      =   ~partitions(:,f);
            f_trainlabels   =   labelsTrain(f_trainIdx);
            f_testlabels    =   labelsTrain(f_testIdx);
            f_traindata     =   sigTrain(f_trainIdx,:);
            f_testdata      =   sigTrain(f_testIdx,:);
            
 
            [f_testPred,~] =  classifierSVM(f_traindata.^a_alpha, f_trainlabels, ...
                                        f_testdata.^a_alpha, f_testlabels, svmParam);
            
            cnt(f) = sum(f_testPred == f_testlabels);
            
        end
        cv_acc(a) = sum(cnt)/size(partitions,1);        
    end
    
    [~,a_idx] = max(cv_acc);
    alpha = alphas(a_idx);

 
end