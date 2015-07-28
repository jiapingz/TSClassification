
function fileName =  generateDescriptorFileName(descriptorName, param)
% generate descriptor fileName:
% (1) HOG-1D;
% (2) Baydogan's
% (3) Windau
% (4) self
% (5) PLA
% (6) dePLA
% (7) PAA
% (8) HOG1DPAA
% (9) HOG1DDTWMDS
% (10) Slope
% (11) SlopePAA
% (12) DFT
% (13) DWT
    if nargin == 1
        descriptorName = 'HOG1D';
    end
    
    switch descriptorName
        case 'HOG1D'
            fileName = generateHOG1DFileName(param);
        case 'Windau'
            fileName = generateWindauFileName(param);

        case 'Baydogan'
            fileName = generateBaydoganFileName(param);
            
        case 'PAA'
            fileName = generatePAAdescriptorFileName(param);
        case 'HOG1DPAA'
            fileName = generateHOG1DPAAFileName(param);
            
        case 'HOG1DDTWMDS'
            fileName = generateHOG1DDTWMDSFileName(param);
        case 'DTWMDS'
            fileName = generateDTWMDSdescriptorFileName(param);
            
        case 'PLA'
            fileName = generatePLAdescriptorFileName(param);
            
        case 'dePLA'
            fileName = generatedePLAdescriptorFileName(param);
            
        case 'self'
            fileName = generateSelfFileName;  
        case 'Slope'
            fileName = generateSlopedescriptorFileName(param);
        case 'SlopePAA'
            fileName = generateSlopePAAdescriptorFileName(param);
        case 'DFT'
            fileName = generateDFTdescriptorFileName(param);
        case 'DWT'
            fileName = generateDWTdescriptorFileName(param);

        otherwise
            error('Only support 13 descriptors\n');
    end
    
 
end