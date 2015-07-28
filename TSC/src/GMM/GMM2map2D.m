
% convert a GMM to map (2D)
function map = GMM2map2D(mapsize, modes)

    nModes = numel(modes);
    map = zeros(mapsize);
    h = mapsize(1);
    w = mapsize(2);

    for i=1:nModes
        imu = modes(i).center;
        cx = imu(1);
        cy = imu(2);

        icovmat = modes(i).cov;
        ipeaki = modes(i).peaki;

        if cond(icovmat) > 1.0e6
            continue;
        end

%         [X, Y] = meshgrid(1:w, 1:h);
%         idx = 1:h*w;
%         vec = [X(idx)' Y(idx)'] - repmat([cx cy],  h*w,1);
%         tmpmap = ipeaki * exp(-0.5.* vec / icovmat * vec');
        tmpmap =  GaussianMap2D(mapsize, cx, cy, icovmat);
        map = map + ipeaki * tmpmap;
    end


end