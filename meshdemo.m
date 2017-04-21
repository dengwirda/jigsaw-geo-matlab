function meshdemo(varargin)
%MESHDEMO run demo problems for JIGSAW-GEO.
%   MESHDEMO(N) calls the N-TH demo problem. Three demo pro-
%   blems are currently available:
%
% - DEMO-1: generate a uniform resolution 150km global grid.
%
% - DEMO-2: generate a regionlly-refined global-grid, with a 
%   high-resolution north-atlantic 25km "patch" embedded wi- 
%   thin a uniformly resolved 150km background grid.
%
% - DEMO-3: generate a multi-resolution grid for the arctic 
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 100km, backgr-
%   ound arctic resolution is 50km and min. adaptive resolu-
%   tion is 25km.
%
%   See also JIGSAWGEO
%

%-----------------------------------------------------------
%   Darren Engwirda : 2017 --
%   Email           : engwirda@mit.edu
%   Last updated    : 21/04/2017
%-----------------------------------------------------------
%

    close all;

    n = 1;

    if (nargin >= 1), n = varargin{1}; end
       
    switch  (n)
        case 1, demo1 ;
        case 2, demo2 ;
        case 3, demo3 ;
        
        otherwise
        error('Invalid demo selection!') ;
    end

end

function demo1
% DEMO-1: generate a uniform resolution (150km) global grid. 

    opts.geom_file = ...            % radius file
        ['jigsaw-geo/dat/earth-sphere.geo' ];
    
    opts.hfun_file = ...            % length file
        ['jigsaw-geo/dat/uniform-150km.dat'];
    
    opts.jcfg_file = ...            % config file
        ['jigsaw-geo/out/uniform-150km.jig'];
    
    opts.mesh_file = ...            % output file
        ['jigsaw-geo/out/uniform-150km.msh'];
    
%------------------------------------------- build the mesh!
    mesh = jigsawgeo(opts) ;

%------------------------------------------- calc. cell alt.
    topo = readdat('jigsaw-geo/dat/topo.dat');
    
   [nlat,nlon] = size(topo);
    
    alon = linspace(-180,+180,nlon);
    alat = linspace(- 90,+ 90,nlat);
    
    zlev = findalt(mesh,alon,alat,topo);
  
%------------------------------------------- draw the output
    figure;
    patch('faces',mesh.tria3.index(zlev<=0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facevertexcdata',zlev(zlev<=0.,:), ...
    'facecolor','flat','edgecolor',[.2,.2,.2], ...
    'linewidth',.75);
    axis image off; hold on;
    patch('faces',mesh.tria3.index(zlev> 0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facecolor','w','edgecolor','none', ...
    'linewidth',.75);
    set(gcf,'color','w','units','normalized', ...
    'position',[.1,.1,.8,.8]);
    set(gca,'clipping','off');
    caxis([min(topo(:))*4./3., +0.]) ;
    view(-80,+10);
    colormap('hot');
    brighten(+0.75); drawnow ;
    
    drawcost(meshcost(mesh)) ;
         
end

function demo2
% DEMO-2 -- generate a regionlly-refined global-grid, with a 
%   high-resolution north-atlantic 25km "patch" embedded wi- 
%   thin a uniformly resolved 150km background grid.

    opts.geom_file = ...            % radius file
        ['jigsaw-geo/dat/earth-sphere.geo' ];
    
    opts.hfun_file = ...            % length file
        ['jigsaw-geo/dat/regional-25km.dat'];
    
    opts.jcfg_file = ...            % config file
        ['jigsaw-geo/out/regional-25km.jig'];
    
    opts.mesh_file = ...            % output file
        ['jigsaw-geo/out/regional-25km.msh'];
    
%------------------------------------------- build the mesh!
    mesh = jigsawgeo(opts) ;
    
%------------------------------------------- calc. cell alt.
    topo = readdat('jigsaw-geo/dat/topo.dat');
    
   [nlat,nlon] = size(topo);
    
    alon = linspace(-180,+180,nlon);
    alat = linspace(- 90,+ 90,nlat);
    
    zlev = findalt(mesh,alon,alat,topo);
    
%------------------------------------------- draw the output
    figure;
    patch('faces',mesh.tria3.index(zlev<=0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facevertexcdata',zlev(zlev<=0.,:), ...
    'facecolor','flat','edgecolor',[.2,.2,.2], ...
    'linewidth',.75);
    axis image off; hold on;
    patch('faces',mesh.tria3.index(zlev> 0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facecolor','w','edgecolor','none', ...
    'linewidth',.75);
    set(gcf,'color','w','units','normalized', ...
    'position',[.1,.1,.8,.8]);
    set(gca,'clipping','off');
    caxis([min(topo(:))*4./3., +0.]) ;
    view(+10,+20);
    colormap('hot');
    brighten(+0.75); drawnow ;
    
    drawcost(meshcost(mesh)) ;
         
end

function demo3
% DEMO-3 --- generate a multi-resolution grid for the arctic 
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 100km, backgr-
%   ound arctic resolution is 50km and min. adaptive resolu-
%   tion is 25km.

    opts.geom_file = ...            % radius file
        ['jigsaw-geo/dat/earth-sphere.geo'];
    
    opts.hfun_file = ...            % length file
        ['jigsaw-geo/dat/regional-eu.dat'];
    
    opts.jcfg_file = ...            % config file
        ['jigsaw-geo/out/regional-eu.jig'];
    
    opts.mesh_file = ...            % output file
        ['jigsaw-geo/out/regional-eu.msh'];

%------------------------------------ setup grid-spacing fun
    topo = ...
        readdat('jigsaw-geo/dat/topo.dat');

   [nlat,nlon] = size(topo);

    radE = 6371.E+00 ;

    alon = linspace(-180,+180,nlon);
    alat = linspace(- 90,+ 90,nlat);
    
   [ALON,ALAT] = meshgrid (alon,alat) ;
      
    hfn0 = +100. ;                  % global spacing
    hfn2 = +25.;                    % adapt. spacing
    hfn3 = +50.;                    % arctic spacing
    
    dhdx = +.10;                    % max. gradients
    
    hfun = +hfn0*ones(nlat,nlon) ;
    
    htop = max(-hfn2*topo/1000.,hfn2) ;
    htop = min(htop,hfn3);
    
    hfun(ALAT>+50.) = htop(ALAT>+50.) ;
    
    hnew = limhfun( ...
       alon,alat,radE,true,hfun,dhdx) ;
    
%------------------------------------------- write spac-file
    makedat(opts.hfun_file,hnew) ;
        
%------------------------------------------- build the mesh!
    mesh = jigsawgeo(opts) ;
 
%------------------------------------------- calc. cell alt.    
    zlev = findalt(mesh,alon,alat,topo);
    
%------------------------------------------- draw the output    
    figure;
    patch('faces',mesh.tria3.index(zlev<=0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facevertexcdata',zlev(zlev<=0.,:), ...
    'facecolor','flat','edgecolor',[.2,.2,.2], ...
    'linewidth',.75);
    axis image off; hold on;
    patch('faces',mesh.tria3.index(zlev> 0,1:3), ...
    'vertices',mesh.point.coord(:,1:3), ...
    'facecolor','w','edgecolor','none', ...
    'linewidth',.75);
    set(gcf,'color','w','units','normalized', ...
    'position',[.1,.1,.8,.8]);
    set(gca,'clipping','off');
    caxis([min(topo(:))*4./3., +0.]) ;
    view(-330,+45); zoom(+1.5) ;
    colormap('hot');
    brighten(+0.75); drawnow ;
    
    drawcost( ...
    meshcost(mesh,@hfndemo,alon,alat,hnew));

    hfun(topo > +0.0) = +inf ;      % mask out land
    hnew(topo > +0.0) = +inf ;
        
    figure;
    surf(alon,alat,hfun); 
    shading flat;view(2); 
    axis image; box on; grid off;
    set(gca,'ylim', ...
        [-100,+100],'ytick',[- 90:45:+ 90]);
    set(gca,'xlim', ...
        [-190,+190],'xtick',[-180:60:+180]);
    set(gca,'ticklength', ...
        2*get(gca,'ticklength'));
    set(gca,'linewidth',1.);
    xlabel('lon (deg)');ylabel('lat (deg)');
    title('RAW GRID-SPACING FUNCTION');
    
    figure;
    surf(alon,alat,hnew); 
    shading flat;view(2); 
    axis image; box on; grid off;
    set(gca,'ylim', ...
        [-100,+100],'ytick',[- 90:45:+ 90]);
    set(gca,'xlim', ...
        [-190,+190],'xtick',[-180:60:+180]);
    set(gca,'ticklength', ...
        2*get(gca,'ticklength'));
    set(gca,'linewidth',1.);
    xlabel('lon (deg)');ylabel('lat (deg)');
    title('SMOOTH GRID-SPACING FUNCTION');  
    
    set(figure(3),'units','normalized',...
        'position',[.65,.50,.30,.35]) ;
    set(figure(4),'units','normalized',...
        'position',[.65,.20,.30,.35]) ;

end

function [zlev] = findalt(mesh,alon,alat,topo)
%FINDALT calc. an "altitude" for each tria-cell in the mesh.

    xrad = mesh.point.coord(:,1) .^ 2 ...
         + mesh.point.coord(:,2) .^ 2 ...
         + mesh.point.coord(:,3) .^ 2 ;
    xrad = max(sqrt(xrad),eps) ;
    
    xlat = asin (mesh.point.coord(:,3)./xrad);
    xlon = atan2(mesh.point.coord(:,2), ...
                 mesh.point.coord(:,1)) ;
                 
    xlat = xlat * 180 / pi;
    xlon = xlon * 180 / pi;
    
    xlev = interp2 (alon,alat,topo,xlon,xlat);
    
    zlev = xlev (mesh.tria3.index(:,1)) ...
         + xlev (mesh.tria3.index(:,2)) ...
         + xlev (mesh.tria3.index(:,3)) ;
    zlev = zlev / +3.;

end

function [hdat] = hfndemo(ppos,alon,alat,hfun)
%HFNDEMO eval. the user-defined mesh-spacing at points PPOS.

    xrad = ppos(:,1) .^ 2 ...
         + ppos(:,2) .^ 2 ...
         + ppos(:,3) .^ 2 ;
    xrad = max(sqrt(xrad),eps) ;
    
    xlat = asin (ppos(:,3)./xrad);
    xlon = atan2(ppos(:,2), ...
                 ppos(:,1)) ;
                 
    xlat = xlat * 180 / pi;
    xlon = xlon * 180 / pi;
    
    hdat = interp2 (alon,alat,hfun,xlon,xlat);

end


