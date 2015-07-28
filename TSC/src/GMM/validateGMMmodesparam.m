function val_content = validateGMMmodesparam(content)
    
    if nargin == 0
        val_content = struct('center', [], ...
                             'cov', [], ...
                             'peaki', 0, ...
                             'sumi', 0, ...
                             'span', [], ... %
                             'scope', []);   % scope is the region it takes
        return;
    end
    
    val_content = content;
    if ~isfield(val_content, 'center')
        val_content.center = [];
    end
    
    if ~isfield(val_content, 'cov')
        val_content.cov = [];
    end
    
    if ~isfield(val_content, 'peaki')
        val_content.peaki = 0;
    end
    
    if ~isfield(val_content, 'sumi')
        val_content.sumi = 0;
    end
    
    if ~isfield(val_content, 'span')
        val_content.span = [];
    end
    
    if ~isfield(val_content, 'scope')
        val_content.scope = [];
    end
    
end