function absFile = genAbsMatFile(directory, fileName)
    
    narginchk(2,2);
    if ispc
        slash = '\';
    else
        slash = '/';
    end
    
    idx = strfind(fileName, '.mat');
    if isempty(idx)
        fileName = [fileName '.mat'];
    end
    
    absFile = strcat(directory, slash, fileName);
    
end