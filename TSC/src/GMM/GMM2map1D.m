% convert a GMM to 1D map
function map = GMM2map1D(mapsize, modes) 
    nModes = numel(modes);
    map = zeros(mapsize);
%     h = mapsize(1);
%     w = mapsize(2);

    for i=1:nModes        
        c = modes(i).center;
        icovmat = modes(i).cov;
        ipeaki = modes(i).peaki;


        if abs(icovmat) < eps
            continue;
        end
        
        sigma = sqrt(icovmat);

%         r_icovmat = 1./icovmat;    
%         idx = 1:h*w;   
%         vec = idx' - c; 
%         tmpmap = ipeaki * exp(-0.5 * r_icovmat * (vec * vec'));
        tmpmap =  GaussianMap1D(mapsize, c, sigma);
        map = map + ipeaki * tmpmap;
    end


end