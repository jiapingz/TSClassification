
function [DTWMDSvecsTrainCell, DTWMDSvecsTestCell, DTWMDSmodel, t_train, t_test] = ...
                calcDTWMDSucr(datasetIdx, samplingSetting, DTWMDSparam)
% calculate DTWMDS description on UCR dataset
% inputs:
%           datasetIdx -- ucr dataset index
%           samplingSetting -- subsequence sampling setting
%           DTWMDSparam -- DTWMDS descriptor parameters

    narginchk(0,3);
    if ~exist('datasetIdx', 'var') || isempty(datasetIdx)
        datasetIdx = 1;
    end
    
    if ~exist('samplingSetting', 'var') || isempty(samplingSetting)
        samplingSetting = struct('method', 'hybrid', ...
                                 'param',  struct('seqlen', 60, ...
                                 'stride', 2, ...
                                 'sel',    10));
    end
    
    if ~exist('DTWMDSparam', 'var') || isempty(DTWMDSparam)
        DTWMDSparam = validateDTWMDSparam;
    end

    % read data from disk
    % train
    signals = readucr(datasetIdx, 'train');
    dataTrain    = signals(:,2:end);
    zdataTrain = zeros(size(dataTrain));
    nTrain = size(dataTrain,1);

    % z-normalization
    parfor j=1:nTrain
        zdataTrain(j,:) =  zNormalizeTS(dataTrain(j,:)) ;
    end

    zdataTraincell = mat2cell(zdataTrain, ones(1,nTrain),size(zdataTrain,2)); 

    % test
    signals = readucr(datasetIdx, 'test');
    labelsTest = signals(:,1);
    dataTest = signals(:,2:end);
    zdataTest = zeros(size(dataTest));
    nTest = length(labelsTest);
    % z-normalization
    parfor j=1:nTest
        zdataTest(j,:) =   zNormalizeTS(dataTest(j,:));
    end
    zdataTestcell = mat2cell(zdataTest, ones(1,nTest),size(zdataTest,2)); 


    %% sampling 
    t1 = clock;
 	samplingParam  = samplingSetting.param;
    seqlen = samplingParam.seqlen;
    stride = samplingParam.stride;
    sel    = samplingParam.sel;

    sequencesTrain = {};
    cntTrain = [];
    for i=1:nTrain
        isequences  = ...
                samplingatHybridPts(zdataTraincell{i}(:), sel, seqlen, stride);
        sequencesTrain   =   cat(1, sequencesTrain, isequences);
        cntTrain    =   cat(1, cntTrain, numel(isequences));
    end
        
        
    %% DTWMDS train data 
     fprintf(1, 'Processing training data......\n');
     [DTWMDSvecsTrain, DTWMDSmodel] = calcDTWMDStrain(sequencesTrain, DTWMDSparam);
     DTWMDSvecsTrainCell_ = mat2cell(DTWMDSvecsTrain, cntTrain, size(DTWMDSvecsTrain,2));
     DTWMDSvecsTrainCell = cell(nTrain,1);
	 t2 = clock;
     t_train = etime(t2, t1);

     parfor i=1:nTrain
         tmp = cell(1,1);
         iDescriptor = DTWMDSvecsTrainCell_{i};
         tmp{1} = mat2cell(iDescriptor, ones(1, size(iDescriptor,1)), size(iDescriptor,2));
         DTWMDSvecsTrainCell{i} = tmp;
     end

     
	%% DTWMDS test data
    t1 = clock;
	DTWMDSvecsTestCell = cell(nTest,1);
	fprintf(1, 'Processing test data...\n');
    for i=1:nTest
        fprintf('calculate DTWMDS descriptors of test subsequences: %d/%d\n', i, nTest);
        isequences  = ...
                samplingatHybridPts(zdataTestcell{i}(:), sel, seqlen, stride);
        jcnt = numel(isequences);
        vecs = cell(jcnt,1);
        parfor j=1:jcnt
            jsequence = isequences{j};
            vecs{j} =  calcDTWMDStest(jsequence, DTWMDSmodel);
        end
        tmp = cell(1,1);
        tmp{1} = vecs;
        DTWMDSvecsTestCell{i} = tmp; % this kind of storage format is used to 
                                     % be consistent with setting in
                                     % 'TSCpipeline'
    end
    t2 = clock;
    t_test = etime(t2,t1);
     

end