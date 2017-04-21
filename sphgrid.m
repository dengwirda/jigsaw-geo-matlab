function [ppos,quad] = sphgrid(alon,alat,rGEO,wrap)
%SPHGRID assemble a simple structured grid in lat-lon space.
%   [PPOS,QUAD] = SPHGRID(ALON,ALAT,RGEO,WRAP) builds a str-
%   uctured quadrilateral grid for the spheroid. ALON, ALAT 
%   are NLON-by-1 and NLAT-by-1 vectors of longitude and la-
%   titude coordinates, respectivley. RGEO is the radius of 
%   the geoid, and WRAP is TRUE if the longitudinal coordin-
%   ate is periodic.
%
%   The grid is returned in a generalised unstructured form,
%   with PPOS an N-by-3 array of vertex coordinates (in R^3) 
%   and QUAD an M-by-4 list of element indexing. Coordinates
%   for the II-TH quadrilateral are thus given by PPOS(N1,:)
%   PPOS(N2,:), PPOS(N3,:) and PPOS(N4,:), where 
%   N1 = QUAD(II,1), N2 = QUAD(II,2), N3 = QUAD(II,3) and 
%   N4 = QUAD(II,4). 
%
%   See also JIGSAWGEO
%

%-----------------------------------------------------------
%   Darren Engwirda : 2017 --
%   Email           : engwirda@mit.edu
%   Last updated    : 21/04/2017
%-----------------------------------------------------------
%

%---------------------------------------------- basic checks    
    if ( ~isnumeric(alon) || ...
         ~isnumeric(alat) || ...
         ~isnumeric(rGEO) || ...
         ~islogical(wrap) )
        error('sphgrid:incorrectInputClass' , ...
            'Incorrect input class.') ;
    end

%---------------------------------------------- basic checks
    if ( ~isvector (alon) || ...
         ~isvector (alat) || ...
         ~isvector (rGEO) )
        error('sphgrid:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end

%----------------------------------------- tile lat-lon grid
    nlat = length(alat) ;
    nlon = length(alon) ;

   [alon,alat] = meshgrid(alon, alat) ;
    
    ALON = alon * pi / 180. ;
    ALAT = alat * pi / 180. ;
    
%----------------------------------------- spheroidal coord.
    xpos = rGEO.*cos(ALON).*cos(ALAT) ;
    ypos = rGEO.*sin(ALON).*cos(ALAT) ;
    zpos = rGEO.*sin(ALAT)  ;
    
    ppos = [xpos(:), ypos(:), zpos(:)];
    
    grid = reshape( ...
        (1:nlat*nlon)',nlat,nlon) ;
   
    if (wrap)
%----------------------------------------- grid _IS periodic 
  
        quad = zeros((nlat-1)*(nlon-0),4);
        
        next = +1 ;
        
        for jpos = 2 : nlat
       
            quad(next,1) = ...
                grid(jpos-1,nlon-0);
            quad(next,2) = ...
                grid(jpos-1,    +1);
            quad(next,3) = ...
                grid(jpos-0,    +1);
            quad(next,4) = ...
                grid(jpos-0,nlon-0);
            
            next = next+1 ;
            
        end
        
        for ipos = 2 : nlon
        for jpos = 2 : nlat
       
            quad(next,1) = ...
                grid(jpos-1,ipos-1);
            quad(next,2) = ...
                grid(jpos-1,ipos-0);
            quad(next,3) = ...
                grid(jpos-0,ipos-0);
            quad(next,4) = ...
                grid(jpos-0,ipos-1);
            
            next = next+1 ;
            
        end
        end
        
    else
%----------------------------------------- grid NOT periodic
        
        quad = zeros((nlat-1)*(nlon-1),4);
        
        next = +1 ;
        
        for ipos = 2 : nlon
        for jpos = 2 : nlat
       
            quad(next,1) = ...
                grid(jpos-1,ipos-1);
            quad(next,2) = ...
                grid(jpos-1,ipos-0);
            quad(next,3) = ...
                grid(jpos-0,ipos-0);
            quad(next,4) = ...
                grid(jpos-0,ipos-1);
            
            next = next+1 ;
            
        end
        end
        
    end
    
end


