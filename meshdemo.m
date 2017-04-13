function meshdemo(varargin)
%MESHDEMO run demo problems for JIGSAW-GEO.
%
%   MESHDEMO(N) calls the N-TH demo problem. Two demo problems are 
%   currently available:
%
%   - DEMO-1: generate a uniform resolution (150km) global grid.
%
%   - DEMO-2: generate a regionlly-refined global-grid, with a high-
%       resolution north-atlantic "patch" (25km) embedded in a unif-
%       ormly resolved (150km) background grid.
%
%   See also JIGSAWGEO

%---------------------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   13-Apr-2017
%   engwirda [at] mit [dot] edu
%---------------------------------------------------------------------
%

    close all;

    n = 1;

    if (nargin >= 1), n = varargin{1}; end
       
    switch  (n)
        case 1, demo1 ;
        case 2, demo2 ;
        
        otherwise
        error('Invalid demo selection!') ;
    end

end

function demo1
% DEMO-1: generate a uniform resolution (150km) global grid. 

    name = 'uniform-150km' ;

%-- setup files for JIGSAW
    opts.geom_file = ...            % radius file
        ['jigsaw-geo/dat/earth-sphere.geo' ];
    
    opts.hfun_file = ...            % length file
        ['jigsaw-geo/dat/uniform-150km.dat'];
    
    opts.jcfg_file = ...            % config file
        ['jigsaw-geo/out/',name,'.jig'];
    
    opts.mesh_file = ...            % output file
        ['jigsaw-geo/out/',name,'.msh'];
       
%-- JIGSAW options.
    opts.mesh_kern = 'delfront';
    opts.mesh_dims = 2 ;
    opts.mesh_snk2 = 0.100 ;
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = 5000. ;
    
%-- build the mesh!
    mesh = jigsawgeo(opts) ;
 
%-- draw the output
    
    topo = readdat('jigsaw-geo/dat/topo.dat');
    
    alat = linspace(-.5*pi,+.5*pi,size(topo,1));
    alon = linspace(-1.*pi,+1.*pi,size(topo,2));
    
    xrad = mesh.point.coord(:,1) .^ 2 ...
         + mesh.point.coord(:,2) .^ 2 ...
         + mesh.point.coord(:,3) .^ 2 ;
    xrad = max(sqrt(xrad),eps) ;
    
    xlat = asin (mesh.point.coord(:,3) ./ xrad);
    xlon = atan2(mesh.point.coord(:,2), ...
                 mesh.point.coord(:,1)) ;
    
    xlev = interp2(alon,alat,topo,xlon,xlat);
    
    zlev = xlev (mesh.tria3.index(:,1)) ...
         + xlev (mesh.tria3.index(:,2)) ...
         + xlev (mesh.tria3.index(:,3)) ;
    zlev = zlev / +3.;
    
    figure;
    patch('faces',mesh.tria3.index(zlev<=0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facevertexcdata',zlev(zlev<=0.,:), ...
    'facecolor','flat','edgecolor',[.2,.2,.2], ...
    'facelighting','flat','edgelighting','none', ...
    'linewidth',.75);
    axis image off; hold on;
    patch('faces',mesh.tria3.index(zlev> 0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facecolor','w','edgecolor','none', ...
    'facelighting','flat','edgelighting','none', ...
    'linewidth',.75);
    set(gcf,'color','w','units','normalized', ...
    'position',[.05,.05,.90,.90]);
    set(gca,'clipping','off');
    caxis([min(topo(:))*4./3., +0.]) ;
    view(-80,+10);
    colormap('hot');
    brighten(+0.75); drawnow ;
    
    drawcost(meshcost(mesh)) ;
         
end

function demo2
%DEMO-2: generate a regionlly-refined global-grid, with a high-
%   resolution north-atlantic "patch" (25km) embedded in a uni-
%   formly resolved (150km) background grid. 

    name = 'regional-25km' ;
    
%-- setup files for JIGSAW
    opts.geom_file = ...            % radius file
        ['jigsaw-geo/dat/earth-sphere.geo' ];
    
    opts.hfun_file = ...            % length file
        ['jigsaw-geo/dat/regional-25km.dat'];
    
    opts.jcfg_file = ...            % config file
        ['jigsaw-geo/out/',name,'.jig'];
    
    opts.mesh_file = ...            % output file
        ['jigsaw-geo/out/',name,'.msh'];
       
%-- JIGSAW options.
    opts.mesh_kern = 'delfront';
    opts.mesh_dims = 2 ;
    opts.mesh_snk2 = 0.100 ;
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = 5000. ;
    
%-- build the mesh!
    mesh = jigsawgeo(opts) ;
 
%-- draw the output
    
    topo = readdat('jigsaw-geo/dat/topo.dat');
    
    alat = linspace(-.5*pi,+.5*pi,size(topo,1));
    alon = linspace(-1.*pi,+1.*pi,size(topo,2));
    
    xrad = mesh.point.coord(:,1) .^ 2 ...
         + mesh.point.coord(:,2) .^ 2 ...
         + mesh.point.coord(:,3) .^ 2 ;
    xrad = max(sqrt(xrad),eps) ;
    
    xlat = asin (mesh.point.coord(:,3) ./ xrad);
    xlon = atan2(mesh.point.coord(:,2), ...
                 mesh.point.coord(:,1)) ;
    
    xlev = interp2(alon,alat,topo,xlon,xlat);
    
    zlev = xlev (mesh.tria3.index(:,1)) ...
         + xlev (mesh.tria3.index(:,2)) ...
         + xlev (mesh.tria3.index(:,3)) ;
    zlev = zlev / +3.;
    
    figure;
    patch('faces',mesh.tria3.index(zlev<=0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facevertexcdata',zlev(zlev<=0.,:), ...
    'facecolor','flat','edgecolor',[.2,.2,.2], ...
    'facelighting','flat','edgelighting','none', ...
    'linewidth',.75);
    axis image off; hold on;
    patch('faces',mesh.tria3.index(zlev> 0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facecolor','w','edgecolor','none', ...
    'facelighting','flat','edgelighting','none', ...
    'linewidth',.75);
    set(gcf,'color','w','units','normalized', ...
    'position',[.05,.05,.90,.90]);
    set(gca,'clipping','off');
    caxis([min(topo(:))*4./3., +0.]) ;
    view(-80,+10);
    colormap('hot');
    brighten(+0.75); drawnow ;
    
    drawcost(meshcost(mesh)) ;
         
end



