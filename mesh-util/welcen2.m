function [ok] = welcen2(pp,pw,tt)
%WELCEN2 'well-centred' status for elements of a 2-simplex
%triangulation embedded in R^2.
%   [WC] = WELCEN2(PP,PW,TT) returns TRUE for triangles that
%   contain their own 'dual' vertex in their interiors. PP
%   is a V-by-2 list of XY coordinates, TT is a T-by-3 list
%   of triangle indicies, and PW is a V-by-1 array of vertex
%   weights. When PW = 0, the dual mesh is a Voronoi diagram
%   and dual vertices are triangle circumcentres.

%   Darren Engwirda : 2017 --
%   Email           : de2363@columbia.edu
%   Last updated    : 19/03/2018

%---------------------------------------------- basic checks    
    if ( ~isnumeric(pp) || ...
         ~isnumeric(pw) || ...
         ~isnumeric(tt) )
        error('welcen2:incorrectInputClass' , ...
            'Incorrect input class.');
    end
    
%---------------------------------------------- basic checks
    if (ndims(pp) ~= +2 || ...
        ndims(pw) ~= +2 || ...
        ndims(tt) ~= +2 )
        error('welcen2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end
    
    if (size(pp,2)~= +2 || ...
            size(pp,1)~= size(pw,1) || ...
                size(tt,2) < +3 )
        error('welcen2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end

%------------------------------------- compute dual vertices
    cc = pwrbal2(pp,pw,tt);

%------------------------------------- signed areas to vert.
    d1 = cc(:,1:2) ...
            - pp(tt(:,1),:) ;
    d2 = cc(:,1:2) ...
            - pp(tt(:,2),:) ;
    d3 = cc(:,1:2) ...
            - pp(tt(:,3),:) ;
    
    a3 = d1(:,1) .* d2(:,2) ...
       - d1(:,2) .* d2(:,1) ;
    a2 = d1(:,2) .* d3(:,1) ...
       - d1(:,1) .* d3(:,2) ;
    a1 = d3(:,2) .* d2(:,1) ...
       - d3(:,1) .* d2(:,2) ;

%------------------------------------- interior if same sign
    ok = a1 .* a2 >= +0.0 ...
       & a2 .* a3 >= +0.0 ;
   
end



