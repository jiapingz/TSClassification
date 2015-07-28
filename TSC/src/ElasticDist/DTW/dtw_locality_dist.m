% dynamic time warping
% input:  sequence s;
%         sequence t;
%         local constraint window size w;

% output 
%          dist: dtw distance
%          dMat: distance matrix
%          lPath: length of the matching path
%          match: a sequence of match points

function dist = dtw_locality_dist(s,t,w)

    if nargin<3
        w=Inf;
    end

    ns=length(s);
    nt=length(t);
    if size(s,2)~=size(t,2)
        error('Error in dtw(): the dimensions of the two input signals do not match.');
    end
    w=max(w, abs(ns-nt)); % adapt window size

    %% initialization
    dMat=zeros(ns+1,nt+1)+Inf; % cache matrix
    dMat(1,1)=0;

    %% begin dynamic programming
    
    for i=2:ns+1
        for j=max(i-w,2):min(i+w,nt+1)
            oost=norm(s(i-1,:)-t(j-1,:));
            dMat(i,j)=oost+min( [dMat(i-1,j), dMat(i-1,j-1), dMat(i,j-1)] );

        end
    end
    dist=dMat(ns+1,nt+1);
    

end