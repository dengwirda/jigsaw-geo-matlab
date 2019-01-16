function [mesh] = bisect_sphere(opts,nlev)
%BISECT-SPHERE generate a grid via incremental bisection.
%   MESH = BISECT-SPHERE(OPTS,NLEV) generates MESH via
%   a sequence of NLEV bisection/optimisation operations.
%   OPTS is a config. options structure for JIGSAW.
%
%   See also JIGSAW

%-----------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   14-Jan-2019
%   darren.engwirda@columbia.edu
%-----------------------------------------------------------
%

    if ( isempty(opts))
        error('JIGSAW: insufficient inputs.');
    end
    
    if (~isempty(opts) && ~isstruct (opts))
        error('JIGSAW: invalid input types.');
    end
    if (~isempty(nlev) && ~isnumeric(nlev))
        error('JIGSAW: invalid input types.');
    end

    GEOM = loadmsh  (opts.geom_file) ;
    
%---------------------------- call JIGSAW via inc. bisection
    SCAL = +2. ^ nlev;

    OPTS = opts ;

    while (nlev >= +0)
    
        if (isfield(opts,'hfun_file'))

%---------------------------- create/write current HFUN data     
       [path,name,fext] = ...
            fileparts(opts.hfun_file) ;
    
        if (~isempty(path)), 
            path = [path, '/']; 
        end
    
        OPTS.hfun_file = ...
            [path,name,'-ITER', fext] ;
        
       [HFUN]=loadmsh(opts.hfun_file) ;
        
        HFUN.value = HFUN.value*SCAL;

        savemsh (OPTS.hfun_file,HFUN) ;
        
        end
        
        if (isfield(opts,'hfun_hmax'))
        
%---------------------------- create/write current HMAX data 
        OPTS.hfun_hmax = ...
        opts.hfun_hmax * SCAL ;
        
        end
        
        if (isfield(opts,'hfun_hmin'))
        
%---------------------------- create/write current HMIN data 
        OPTS.hfun_hmin = ...
        opts.hfun_hmin * SCAL ;
        
        end
        
%---------------------------- create/write current MESH data 
        mesh =   jigsaw (OPTS) ;
        
        nlev = nlev - 1 ;
        SCAL = SCAL / 2.;
        
        if (nlev >= +0)           
        if (isfield(opts,'init_file'))

%---------------------------- create/write current INIT data         
       [path,name,fext] = ...
            fileparts(opts.init_file) ;
  
        if (~isempty(path)), 
            path = [path, '/']; 
        end
  
        OPTS.mesh_iter = +0 ;
        OPTS.init_file = ...
            [path,name,'-ITER', fext] ;
        
        mesh =   bisect (GEOM,mesh) ;
 
        mesh =   attach (GEOM,mesh) ;
        
        savemsh (OPTS.init_file,mesh) ;
        
        else
        
%---------------------------- create/write current INIT data 
        [path,name,fext] = ...
            fileparts(opts.mesh_file) ;
    
        if (~isempty(path)), 
            path = [path, '/']; 
        end
    
        OPTS.mesh_iter = +0 ;
        OPTS.init_file = ...
            [path,name,'-ITER', fext] ;
        
        mesh =   bisect (GEOM,mesh) ;
        
        mesh =   attach (GEOM,mesh) ;
        
        savemsh (OPTS.init_file,mesh) ;
        
        end
        end
    
    end    
    
end

function [mesh] = attach(geom,mesh)
%ATTACH attach points to the surface of spheroidal geometry.

    xrad = mesh.point.coord(:,1) .^ 2 ...
         + mesh.point.coord(:,2) .^ 2 ...
         + mesh.point.coord(:,3) .^ 2 ;
    xrad = max(sqrt(xrad),eps) ;
    
    xlat = asin (mesh.point.coord(:,3)./xrad);
    xlon = atan2(mesh.point.coord(:,2), ...
                 mesh.point.coord(:,1)) ;

    mesh.point.coord(:,1) = ...
        geom.radii(1) .* cos(xlon).*cos(xlat);
    mesh.point.coord(:,2) = ...
        geom.radii(2) .* sin(xlon).*cos(xlat);
    mesh.point.coord(:,3) = ...
        geom.radii(3) .* sin(xlat);

end

function [mesh] = bisect(geom,mesh)
%BISECT bisect a mesh and project it to spheroidal geometry. 

    if(~meshhas(mesh,'point','coord') )
        return ;
    end

%------------------------------ map elements to unique edges
    edge = []; maps = [];
    
    if (meshhas(mesh,'edge2','index') && ...
           ~isempty(mesh.edge2.index) )
    %-------------------------- map EDGE2's onto edge arrays
        nedg = size(edge,1) ;
        ncel = size(mesh.edge2.index,1);

        edge = [edge; 
        mesh.edge2.index(:,[1,2])
            ] ;
       
        maps.edge2.index =zeros(ncel,1);
        maps.edge2.index(:, 1 ) = ...
        (1:ncel)' + ncel*0 + nedg ;
    end

    if (meshhas(mesh,'tria3','index') && ...
           ~isempty(mesh.tria3.index) )
    %-------------------------- map TRIA3's onto edge arrays
        nedg = size(edge,1) ;
        ncel = size(mesh.tria3.index,1);

        edge = [edge; 
        mesh.tria3.index(:,[1,2])
        mesh.tria3.index(:,[2,3])
        mesh.tria3.index(:,[3,1])
            ] ;
       
        maps.tria3.index =zeros(ncel,3);
        maps.tria3.index(:, 1 ) = ...
        (1:ncel)' + ncel*0 + nedg ;
        maps.tria3.index(:, 2 ) = ...
        (1:ncel)' + ncel*1 + nedg ;
        maps.tria3.index(:, 3 ) = ...
        (1:ncel)' + ncel*2 + nedg ;
    end
    
    if (meshhas(mesh,'quad4','index') && ...
           ~isempty(mesh.quad4.index) )
    %-------------------------- map QUAD4's onto edge arrays
        nedg = size(edge,1) ;
        ncel = size(mesh.quad4.index,1);

        edge = [edge; 
        mesh.quad4.index(:,[1,2])
        mesh.quad4.index(:,[2,3])
        mesh.quad4.index(:,[3,4])
        mesh.quad4.index(:,[4,1])
            ] ;
            
        maps.quad4.index =zeros(ncel,4);
        maps.quad4.index(:, 1 ) = ...
        (1:ncel)' + ncel*0 + nedg ;
        maps.quad4.index(:, 2 ) = ...
        (1:ncel)' + ncel*1 + nedg ;
        maps.quad4.index(:, 3 ) = ...
        (1:ncel)' + ncel*2 + nedg ;
        maps.quad4.index(:, 4 ) = ...
        (1:ncel)' + ncel*3 + nedg ;    
    end

%------------------------------ unique edges and re-indexing
  %[edge, imap, jmap] = ...
  %     unique(sort(edge, 2), 'rows');
   
%-- as a (much) faster alternative to the 'ROWS' based call
%-- to UNIQUE above, the edge list (i.e. pairs of UINT32 va-
%-- lues) can be cast to DOUBLE, and the sorted comparisons 
%-- performed on vector inputs!
 
    edge = sort(edge,2) ;
   
   [junk,imap,jmap] = unique(edge*[2^31;1]);  
    junk = [] ;
    
    edge = edge(imap,:) ;

%------------------------------ map unique edges to elements
    if (meshhas(mesh,'edge2','index'))
        maps.edge2.index(:,1) = jmap( ...
        maps.edge2.index(:,1)) ;
    end
    
    if (meshhas(mesh,'tria3','index'))
        maps.tria3.index(:,1) = jmap( ...
        maps.tria3.index(:,1)) ;
        maps.tria3.index(:,2) = jmap( ...
        maps.tria3.index(:,2)) ;    
        maps.tria3.index(:,3) = jmap( ...
        maps.tria3.index(:,3)) ;
    end    
    
    if (meshhas(mesh,'quad4','index'))
        maps.quad4.index(:,1) = jmap( ...
        maps.quad4.index(:,1)) ;
        maps.quad4.index(:,2) = jmap( ...
        maps.quad4.index(:,2)) ;    
        maps.quad4.index(:,3) = jmap( ...
        maps.quad4.index(:,3)) ;
        maps.quad4.index(:,4) = jmap( ...
        maps.quad4.index(:,4)) ;
    end

%------------------------------ create new midpoint vertices
    pmid = mesh.point.coord(edge(:,1),:) ...
         + mesh.point.coord(edge(:,2),:) ;
    pmid = pmid / +2. ;

    inew = (1:size(pmid,1))' + ...
        size (mesh.point.coord,1) ;
        
    mesh.point.coord = [
        mesh.point.coord ; pmid ] ;
    
    if (meshhas(mesh,'edge2','index'))
%------------------------------ create new indexes for EDGE2
        mesh.edge2.index = [
        % 1st sub-edge
             mesh.edge2.index(:,1) , ...
        inew(maps.edge2.index(:,1)), ...
             mesh.edge2.index(:,3)
        % 2nd sub-edge
        inew(maps.edge2.index(:,1)), ...
             mesh.edge2.index(:,1) , ...
             mesh.edge2.index(:,3)
            ] ; 
    end
        
    if (meshhas(mesh,'tria3','index'))
%------------------------------ create new indexes for TRIA3
        mesh.tria3.index = [
        % 1st sub-tria
             mesh.tria3.index(:,1) , ...
        inew(maps.tria3.index(:,1)), ...
        inew(maps.tria3.index(:,3)), ...
             mesh.tria3.index(:,4)
        % 2nd sub-tria
             mesh.tria3.index(:,2) , ...
        inew(maps.tria3.index(:,2)), ...
        inew(maps.tria3.index(:,1)), ...
             mesh.tria3.index(:,4)
        % 3rd sub-tria
             mesh.tria3.index(:,3) , ...
        inew(maps.tria3.index(:,3)), ...
        inew(maps.tria3.index(:,2)), ...
             mesh.tria3.index(:,4)
        % 4th sub-tria
        inew(maps.tria3.index(:,1)), ...
        inew(maps.tria3.index(:,2)), ...
        inew(maps.tria3.index(:,3)), ...
             mesh.tria3.index(:,4)
            ] ; 
    end


end



