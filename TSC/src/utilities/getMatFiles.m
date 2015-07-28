function matfileNames = getMatFiles(path)
% input: 
%           path - directory
% output:
%           matfileNames - all .mat files under the directory
    if ispc
        slash = '\';
    else
        slash = '/';
    end

    matfiles = dir(strcat(path, slash, '*.mat'));
    matfileNames = {};
    for i=1:numel(matfiles)
        matfileNames = cat(1, matfileNames, matfiles(i).name);
    end

end