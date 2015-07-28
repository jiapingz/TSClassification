function map =  GaussianMap2D(mapsize, cx, cy, covmat)

    h = mapsize(1);
    w = mapsize(2);

    [X, Y] = meshgrid(1:w, 1:h);
    idx = 1:h*w;

    vec = [X(idx)' Y(idx)'] - repmat([cx cy],  h*w,1);
    % fast version, but consuming memory     
    %{
    tmpmap = exp(-0.5.* vec / covmat * vec');
    map = reshape(diag(tmpmap), mapsize);
    %}
    
    % slow version
    icovmat = inv(covmat);
    a = icovmat(1,1);
    d = icovmat(2,2);
    c = icovmat(1,2);
    b = icovmat(2,1);    
	tmpmap = exp(-0.5 * ( a*vec(:,1).^2 + d*vec(:,2).^2 + (b+c)*vec(:,1).*vec(:,2) ));
    map = reshape(tmpmap, mapsize);
    
end