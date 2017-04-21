function [hfun] = limhfun( ...
            alon,alat,rGEO,wrap,hfun,varargin)
%LIMHFUN impose "gradient-limits" on a mesh-spacing function.
%   [HNEW] = LIMHFUN(ALON,ALAT,RGEO,WRAP,HFUN) computes a new 
%   smoothed grid-spacing function HNEW, by imposing "gradie-
%   nt-limits" on HFUN, requiring that the maximum variation 
%   along grid edges is bounded below a user-specified thres-
%   hold. ALON and ALAT are NLON-by-1 and NLAT-by-1 vectors 
%   of longitude and latitude coordinates, respectivley, cor-
%   responding to elements in the NLAT-by-NLON grid-spacing 
%   matrix HFUN. RGEO is the radius of the geoid, and WRAP is
%   TRUE if the longitudinal coordinate is periodic. Gradient
%   limits are imposed such that
%
%       ABS(HNEW(N2)-HNEW(N1)) <= ELEN * DHDX,
%
%   where N1, N2 are two nodes in the grid joined by an edge
%   of length ELEN, and DHDX is the max. allowable gradient.
%
%   [HNEW] = LIMHFUN(...,DHDX,ITER) sets the optional gradi-
%   ent limit and max. iteration parameters. The default va-
%   lues DHDX = 0.15 and ITER = 4096 are selected otherwise. 
%
%   See also LIMGRAD
%

%-----------------------------------------------------------
%   Darren Engwirda : 2017 --
%   Email           : engwirda@mit.edu
%   Last updated    : 21/04/2017
%-----------------------------------------------------------
%
  
    dhdx = +.15; imax = 4096;

    if (nargin>=+6), dhdx = varargin{1}; end
    if (nargin>=+7), imax = varargin{2}; end

%---------------------------------------------- basic checks    
    if ( ~isnumeric(alon) || ...
         ~isnumeric(alat) || ...
         ~isnumeric(rGEO) || ...
         ~islogical(wrap) || ...
         ~isnumeric(hfun) || ...
         ~isnumeric(dhdx) || ...
         ~isnumeric(imax) )
        error('limhfun:incorrectInputClass' , ...
            'Incorrect input class.') ;
    end

%---------------------------------------------- basic checks
    if ( ~isvector (alon) || ...
         ~isvector (alat) || ...
         ~isvector (rGEO) || ...
        ndims(hfun) ~= +2 || ...
        numel(wrap) ~= +1 || ...
        numel(dhdx) ~= +1 || ...
        numel(imax) ~= +1 )
        error('limhfun:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end
    if (size(hfun,1) ~= length(alat) || ...
        size(hfun,2) ~= length(alon) )
        error('limhfun:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end

%----------------------------------- assemble "lat-lon" grid
   [ppos,quad] = ...
         sphgrid(alon,alat,rGEO,wrap) ;

%----------------------------------- calc. grid "edge-graph"
    edge = [quad(:,[1,2])
            quad(:,[2,3])
            quad(:,[3,4])
            quad(:,[4,1])
           ] ; 
    edge = unique(sort(edge,2),'rows') ;
    
%-- calc. edge lengths (could do this as proper "geodesics", 
%-- but approximation in R^3 is generally good enough here!)    
    evec = ppos(edge(:,2),:) ...
         - ppos(edge(:,1),:) ;
    elen = sqrt(sum(evec.^2,2));

%----------------------------------- gradient-limit on graph
    hfun = reshape(limgrad(edge,elen, ...
        hfun(:),dhdx,imax),size(hfun)) ;
    
end



