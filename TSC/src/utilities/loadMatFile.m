function data = loadMatFile(directory, fileName)
    
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
    
    data = load(strcat(directory, slash, fileName));
    
end