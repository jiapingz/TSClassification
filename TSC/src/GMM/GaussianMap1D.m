function map =  GaussianMap1D(mapsize, cx, sigma)

    h = mapsize(1);
    w = mapsize(2);

    r_icovmat = 1/(sigma^2);    
    idx = 1:h*w;   
    vec = idx' - cx;    

%     tmpmap  = exp(-0.5 * r_icovmat * (vec * vec'));
    tmpmap  = exp(-0.5*r_icovmat* (vec.^2));
    map     =  reshape(tmpmap, mapsize);
    
end