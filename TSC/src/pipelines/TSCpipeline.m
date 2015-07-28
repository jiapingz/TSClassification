% pipeline of time series classification, univariate and multivariate time series
% for multivariate time series: 
%       (1) each dimension is processed independently
%       (2) fuse dimensional representations

function TSCpipeline(datasetName, data, labels, idxTrain, idxTest, datasetSetting, saveDir)
% specific notice: only one kind of descriptor is allowed
    global datapath;
    global slash;
    samplingSetting      = datasetSetting.sampling;    
    descriptorsSetting   = datasetSetting.descriptors;   
    encodersSetting      = datasetSetting.encoders;        
    classifiersSetting   = datasetSetting.classifiers;
    
     
    matfileExt = '.mat';
    % run experiments on UCR
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    samplingFileNames = {};
    %% (1) sampling
    nSamplingWays = numel(samplingSetting);
    
    for i=1:nSamplingWays
        samplingMethod = samplingSetting(i).method;
        samplingParam  = samplingSetting(i).param;
        seqlen = samplingParam.seqlen;
        stride = samplingParam.stride;
        sel    = samplingParam.sel;
        samplingFileName = generateSeqFileName(samplingMethod, seqlen, stride, sel);
        if ~exist(strcat(saveDir, slash, [samplingFileName matfileExt]), 'file')
            [subsequences, subsequencesIdx] = ...
                            runSamplingTSbatch(data, samplingMethod, sel, seqlen, stride);
            save(strcat(saveDir, slash,  [samplingFileName matfileExt]), 'subsequences', 'subsequencesIdx', 'labels' );
        end    
        samplingFileNames = cat(1, samplingFileNames, [samplingFileName matfileExt]);         
    end
    
    
    %% (2) descriptor computation
    descriptorFileNames = {};
    nSampledSequencesFiles = numel(samplingFileNames);
    nDescriptors = numel(descriptorsSetting);
    
    for s=1:nSampledSequencesFiles
        load(strcat(saveDir, slash,  samplingFileNames{s}));
        for d=1:nDescriptors
            descriptorName = descriptorsSetting(d).method;
            descriptorParam = descriptorsSetting(d).param;
            tmpDescriptorFileName = ...
                        generateDescriptorFileName(descriptorName, descriptorParam);
            
            descriptorFileName = genDescriptorFileName(samplingFileNames{s}(1:end-4), tmpDescriptorFileName);
            
             if ~exist(strcat(saveDir, slash, [descriptorFileName matfileExt]), 'file')
                 
                
                if strcmp(descriptorName, 'HOG1DDTWMDS')
                % special case: DTWMDS descriptor   
                % (1) HOG1D
                    descriptors_hog = calcDescriptorsTSbatch(subsequences, 'HOG1D', descriptorParam.HOG1D);
                % (2) DTWMDS
                    descriptorFileName_dtwmds = ...
                        generateDescriptorFileName('DTWMDS', descriptorParam.DTWMDS);
                    % load pre-computed DTWMDS descriptors
                    fprintf(1, 'Loading pre-computed DTWMDS descriptors...\n');
                    DTWMDSdescriptorFile = strcat(datapath.DTWMDSdescriptorsDir, slash, datasetName, ...
                                              slash, [descriptorFileName_dtwmds matfileExt]);
                    if ~exist(DTWMDSdescriptorFile, 'file')
                        strMessage = strcat(datapath.DTWMDSdescriptorsDir, slash, datasetName);
                        fprintf(1, 'Please first compute DTWMDS descriptors, and place the descirptor file into folder:\n %s\n', strMessage);
                        return;
                    else
                        descriptors_dtwmds = load(DTWMDSdescriptorFile); 
                    end
                    descriptors = mergeDescriptors(descriptors_hog, descriptors_dtwmds.descriptors);
                    
                elseif strcmp(descriptorName, 'DTWMDS')
                    descriptorFileName_dtwmds = ...
                    	generateDescriptorFileName('DTWMDS', descriptorParam);
                    fprintf(1, 'Loading pre-computed DTWMDS descriptors...\n');
                    DTWMDSdescriptorFile = strcat(datapath.DTWMDSdescriptorsDir, slash,  datasetName, ...
                                              slash, [descriptorFileName_dtwmds matfileExt]);
                    if ~exist(DTWMDSdescriptorFile, 'file')
                        strMessage = strcat(datapath.DTWMDSdescriptorsDir, slash, ...
                                                    datasetName);
                        fprintf(1, 'Please first compute DTWMDS descriptors, and place the descirptor file into folder:\n %s\n', strMessage);
                        return;
                    else
                        descriptors_dtwmds = load(DTWMDSdescriptorFile); 
                    end
                    descriptors = descriptors_dtwmds;
                    
                else                    
                % general case: other descriptors
                    descriptors = calcDescriptorsTSbatch(subsequences, descriptorName, descriptorParam);
                end
                
                % l2 normalization of hog1d-paa descriptor                 
                startIndex = regexp(descriptorFileName,'\w*-HOG1DDTWMDS-\w*', 'ONCE');
                if ~isempty(startIndex)
                     descriptors = normFusedDescriptorsL2(descriptors, 16);  
                end               
                % prune constant dimensions 
                [descriptors, activeDims] = pruneConstDimensions(descriptors);
                if sum(cell2mat(activeDims)) == 0
                    continue;
                end
                save(strcat(saveDir, slash, [descriptorFileName matfileExt]), ...
                            'subsequences', 'subsequencesIdx', 'descriptors', 'activeDims', 'labels' );                 
             end
            descriptorFileNames = cat(1, descriptorFileNames, [descriptorFileName matfileExt]);         

        end
    end
    
    %% (3) encoding
    nEncoders        = numel(encodersSetting);
    nDescriptorFiles = numel(descriptorFileNames);
    encoderFileNames = {};
    
    nClasses = length(unique(labels));    
    nInstances = length(labels);
    if isempty(idxTrain) && isempty(idxTest)
        rng('shuffle');
        nTrain = round(0.6*nInstances);
        nTest = nInstances - nTrain;
        idxrand = randperm(nInstances);
        while 1
            if length(unique(labels(idxrand(1:nTrain)))) == nClasses
                idxTrain = idxrand(1:nTrain);
                idxTest = idxrand(nTrain+1:end);
                break;
            end
        end        
    end
    labelsTrain = labels(idxTrain);
    labelsTest  = labels(idxTest);
    
    
    for i=1:nDescriptorFiles
        load(strcat(saveDir, slash, descriptorFileNames{i}));
        b_DFT = ~isempty(strfind(descriptorFileNames{i}, 'DFT'));
        for j=1:nEncoders
            encoderName = encodersSetting(j).method;
            encoderParam = encodersSetting(j).param;
            
            % DFT only supports bag-of-words encodings
            if strcmp(encoderName, 'FV') && b_DFT
                continue;
            end
            
            if strcmp(encoderName, 'RF') && b_DFT
                continue;
            end            
            
            switch encoderName
                case {'BoW', 'FV'}
                    Ks = encoderParam.K;
                case 'RF'
                    Ks = encoderParam.NTrees;
                otherwise
            end
            
            
            for k=1:length(Ks)
                param = encoderParam;
               switch encoderName
                    case {'BoW', 'FV'}
                        param.K = Ks(k);
                    case 'RF'
                        param.NTrees = Ks(k);
                   otherwise
               end
                
%                 i_descriptors = extractDimensionASynMTS(descriptors, 1);
                bofTrain = descriptors(idxTrain);
                bofTest  = descriptors(idxTest);
                tmpEncoderFileName = generateEncoderFileName(encoderName, param);
                encoderFileName = genEncoderFileName(descriptorFileNames{i}(1:end-4), ...
                                                                tmpEncoderFileName);
                success = true;
                if ~exist(strcat(saveDir, slash, [encoderFileName matfileExt]), 'file')
                        [sigTrain, sigTest, success] = runEncoding(bofTrain, bofTest, ...
                            labelsTrain, labelsTest, encoderName, param);
                   if success == false
                       continue;
                   end                   
                   save(strcat(saveDir, slash, [encoderFileName matfileExt]), 'sigTrain', 'sigTest', ...
                                'idxTrain', 'idxTest', 'labels',  'subsequences', 'subsequencesIdx', 'descriptors');
                end
                if success
                    encoderFileNames = cat(1, encoderFileNames, [encoderFileName matfileExt]);         
                end

            end

            
        end
    end
        
    %% (4) SVM classification        

    encoderName = encodersSetting(1).method;
    encoderParam = encodersSetting(1).param;
    switch encoderName
        case {'BoW', 'FV'}
            Ks = encoderParam.K;
        case 'RF'
            Ks = encoderParam.NTrees;
        otherwise
    end
    
    % first cross validate alpha within each K
    % then cross validate both alpha and K
	if ~exist(strcat(saveDir, slash, 'accuracies-alpha-K.mat'), 'file')    
        nEncoderFiles = numel(encoderFileNames);  
        nClassifierSettings = numel(classifiersSetting);
        
        if nEncoderFiles > numel(Ks)
            error('Only support one descriptor\n');
        end
        
        % cross-validate alpha
        alpha = 0.1:0.1:1;
        alphas = zeros(nEncoderFiles,1);
        for i=1:nClassifierSettings        
            svmParam = classifiersSetting(i).param;
            for j=1:nEncoderFiles
                load(strcat(saveDir, slash, encoderFileNames{j}));
                % time series representation fusion
                sigTrain = cell2mat(sigTrain);
                sigTest  = cell2mat(sigTest);
                
                if j==1
                    partitions = CVsplit2folders(labels(idxTrain), 15);
                end
                % cross validate each alpha
                [al, ~] = CValpha(sigTrain, labels(idxTrain), alpha, svmParam, partitions);
                 alphas(j) = al;  

            end
        end
 
        %  cross validate k
        nSplits = 5;
        mAccuracies = zeros(nEncoderFiles,nSplits);
        for i=1:nSplits
            for j=1:nEncoderFiles
                load(strcat(saveDir, slash, encoderFileNames{j}));
                % time series representation fusion
                sigTrain = cell2mat(sigTrain);
                sigTest  = cell2mat(sigTest);

                if j==1
                    partitions = CVsplit2folders(labels(idxTrain), 15);
                end
                 mAccuracies(j,i) = evalmAccuracy(sigTrain, labels(idxTrain), alphas(j), svmParam, partitions);
                
            end
        end
        mAccuracies = mean(mAccuracies,2);

        % test using cross-validate alpha & K
        for i=1:nClassifierSettings        
            svmParam = classifiersSetting(i).param;
            [~, idx] = max(mAccuracies);
            j = idx;

            load(strcat(saveDir, slash, encoderFileNames{j}));
            % time series representation fusion
            sigTrain = cell2mat(sigTrain);
            sigTest  = cell2mat(sigTest);

            %% cross-validated alpha & K
            al = alphas(j);
            K = Ks(j);
            % using cross-validated alpha to predict labels of test
            % data
            [~, acc] =  classifierSVM(sigTrain.^al, labels(idxTrain), ...
                                sigTest.^al, labels(idxTest), svmParam);
            
            %% this is the accuracy on test data
            test_acc = acc;                         
          
        end
        
         save(strcat(saveDir, slash, 'accuracies-alpha-K.mat'),  'test_acc', 'K', 'al');       
            
    end
    
end