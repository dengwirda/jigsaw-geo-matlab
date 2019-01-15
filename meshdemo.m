function meshdemo(demo)
%MESHDEMO build example meshes for JIGSAW(GEO).
%
%   MESHDEMO(N) calls the N-TH demo problem. The following 
%   demo problems are currently available:
%
% - DEMO-1: a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.
%
% - DEMO-2: generate a grid for the Australian region, using
%   scaled ocean-depth as a mesh-spacing indicator.
%
% - DEMO-3: generate a "multi-part" mesh of the (contiguous)
%   USA, using state boundaries to partition the mesh.
%
% - DEMO-4: generate a uniform resolution 150km global grid.
%
% - DEMO-5: generate a regionlly-refined global-grid, with a 
%   high-resolution north-atlantic 25km "patch" embedded wi- 
%   thin a uniformly resolved 150km background grid.
%
% - DEMO-6: generate a multi-resolution grid for the arctic 
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 100km, backgr-
%   ound arctic resolution is 50km and min. adaptive resolu-
%   tion is 25km.
%
%   See also JIGSAW

%-----------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   02-Jan-2019
%   darren.engwirda@columbia.edu
%-----------------------------------------------------------
%
   
    close all ; libpath ; libdata ;
    
    switch (demo)
%------------------------------------ call the demo programs
        case 1, demo1() ;
        case 2, demo2() ;
        case 3, demo3() ;
        case 4, demo4() ;
        case 5, demo5() ;
        case 6, demo6() ;
            
        otherwise
        error( ...
    'meshdemo:invalidSelection','Invalid selection!') ;
    end
 
end
 
function demo1
% DEMO-1 --- a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.

    demoA() ;
    demoB() ;
    demoC() ;
    
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.10,.30,.35]) ;
    
    set(figure(3),'units','normalized', ...
        'position',[.35,.55,.30,.35]) ;
    set(figure(4),'units','normalized', ...
        'position',[.35,.10,.30,.35]) ;
    
    set(figure(5),'units','normalized', ...
        'position',[.65,.55,.30,.35]) ;
    set(figure(6),'units','normalized', ...
        'position',[.65,.10,.30,.35]) ;    
    drawnow ;

end

function demoA
% DEMO-1 --- a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/BOX-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/BOX.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/BOX-MESH.msh'];
 
%------------------------------------ define JIGSAW geometry
    
    geom.mshID = 'EUCLIDEAN-MESH';

    geom.point.coord = [    % list of xy "node" coordinates
        0, 0, 0             % outer square
        9, 0, 0
        9, 9, 0
        0, 9, 0 
        4, 4, 0             % inner square
        5, 4, 0
        5, 5, 0
        4, 5, 0 ] ;
    
    geom.edge2.index = [    % list of "edges" between nodes
        1, 2, 0             % outer square 
        2, 3, 0
        3, 4, 0
        4, 1, 0 
        5, 6, 0             % inner square
        6, 7, 0
        7, 8, 0
        8, 5, 0 ] ;
        
    savemsh(opts.geom_file,geom) ;
    
%------------------------------------ build mesh via JIGSAW! 
  
    fprintf(1,'  Constructing MESH...\n');
  
    opts.hfun_hmax = 0.05 ;             % null HFUN limits
   
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = +.95 ;
   
    opts.mesh_top1 = true ;             % for sharp feat's
    opts.geom_feat = true ;
    
    mesh = jigsaw  (opts) ;
 
    figure('color','w');
    patch ('faces',mesh.tria3.index(:,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor',[.7,.7,.9], ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.8], ...
        'linewidth',1.5) ;
    
    drawcost( meshcost(mesh) );

end

function demoB
% DEMO-1 --- a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/BOX-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/BOX.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/BOX-MESH.msh'];
 
%------------------------------------ define JIGSAW geometry
    
    global JIGSAW_EDGE2_TAG ;

    geom.mshID = 'EUCLIDEAN-MESH';

    geom.point.coord = [    % list of xy "node" coordinates
        0, 0, 0             % outer square
        9, 0, 0
        9, 9, 0
        0, 9, 0 
        2, 2, 0             % inner square
        7, 2, 0
        7, 7, 0
        2, 7, 0 
        3, 3, 0
        6, 6, 0 ] ;
    
    geom.edge2.index = [    % list of "edges" between nodes
        1, 2, 0             % outer square 
        2, 3, 0
        3, 4, 0
        4, 1, 0 
        5, 6, 0             % inner square
        6, 7, 0
        7, 8, 0
        8, 5, 0
        9,10, 0] ;          % inner const.
    
    geom.bound.index = [
        1, 1, JIGSAW_EDGE2_TAG
        1, 2, JIGSAW_EDGE2_TAG
        1, 3, JIGSAW_EDGE2_TAG
        1, 4, JIGSAW_EDGE2_TAG
        1, 5, JIGSAW_EDGE2_TAG
        1, 6, JIGSAW_EDGE2_TAG
        1, 7, JIGSAW_EDGE2_TAG
        1, 8, JIGSAW_EDGE2_TAG
        2, 5, JIGSAW_EDGE2_TAG
        2, 6, JIGSAW_EDGE2_TAG
        2, 7, JIGSAW_EDGE2_TAG
        2, 8, JIGSAW_EDGE2_TAG
            ] ;
        
    savemsh(opts.geom_file,geom) ;
    
%------------------------------------ build mesh via JIGSAW! 
  
    fprintf(1,'  Constructing MESH...\n');
  
    opts.hfun_hmax = 0.05 ;             % null HFUN limits
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = +.95 ;
   
    opts.mesh_top1 = true ;             % for sharp feat's
    opts.geom_feat = true ;
    
    mesh = jigsaw  (opts) ;
 
    figure('color','w');
    I = mesh.tria3.index(:,4) == +1;
    patch ('faces',mesh.tria3.index(I,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor',[.7,.9,.7], ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    I = mesh.tria3.index(:,4) == +2;
    patch ('faces',mesh.tria3.index(I,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor',[.9,.7,.9], ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.8], ...
        'linewidth',1.5) ;
    
    drawcost( meshcost(mesh) );

end

function demoC
% DEMO-1 --- a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/BOX-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/BOX.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/BOX-MESH.msh'];
    
    opts.hfun_file = ...                % HFUN file
        ['jigsaw/out/BOX-HFUN.msh'];
 
%------------------------------------ define JIGSAW geometry
    
    geom.mshID = 'EUCLIDEAN-MESH';

    geom.point.coord = [    % list of xy "node" coordinates
        0, 0, 0             % outer square
        9, 0, 0
        9, 9, 0
        0, 9, 0 
        4, 4, 0             % inner square
        5, 4, 0
        5, 5, 0
        4, 5, 0 ] ;
    
    geom.edge2.index = [    % list of "edges" between nodes
        1, 2, 0             % outer square 
        2, 3, 0
        3, 4, 0
        4, 1, 0 
        5, 6, 0             % inner square
        6, 7, 0
        7, 8, 0
        8, 5, 0 ] ;
        
    savemsh(opts.geom_file,geom) ;
    
%------------------------------------ compute HFUN over GEOM    
        
    xpos = linspace( ...
        min(geom.point.coord(:,1)), ...
        max(geom.point.coord(:,2)), ...
                128) ;
                    
    ypos = linspace( ...
        min(geom.point.coord(:,1)), ...
        max(geom.point.coord(:,2)), ...
                128) ;
    
   [XPOS,YPOS] = meshgrid(xpos,ypos) ;
    
    hfun =-.4*exp(-.1*(XPOS-4.5).^2 ...
                  -.1*(YPOS-4.5).^2 ...
            ) + .6 ;
    
    hmat.mshID = 'EUCLIDEAN-GRID';
    hmat.point.coord{1} = xpos ;
    hmat.point.coord{2} = ypos ;
    hmat.value = hfun ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
  
    fprintf(1,'  Constructing MESH...\n');
  
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;             % null HFUN limits
    opts.hfun_hmin = 0.00 ;
  
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = +.95 ;
   
    opts.mesh_top1 = true ;             % for sharp feat's
    opts.geom_feat = true ;
    
    mesh = jigsaw  (opts) ;
 
    figure('color','w');
    patch ('faces',mesh.tria3.index(:,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor',[.9,.7,.7], ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.8], ...
        'linewidth',1.5) ;
    
    drawcost( meshcost(mesh) );

end
 
function demo2
% DEMO-2 -- generate a grid for the Australian region, using
%   scaled ocean-depth as a mesh-spacing indicator.
 
%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/out/AUS-PROJ.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/AUS.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/AUS-MESH.msh'];
    
    opts.hfun_file = ...                % HFUN file
        ['jigsaw/out/AUS-HFUN.msh'];
        
%------------------------------------ setup TOPO for spacing
  
    fprintf(1,'  Loading TOPO data...\n');
  
    geom = loadmsh('jigsaw/geo/aust.msh');
    
    topo = loadmsh('jigsaw/geo/topo.msh');
    
    alon = topo.point.coord{1};
    alat = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(alat),length(alon));
    
    xmin = min(geom.point.coord(:,1));  % only keep AU-bit
    xmax = max(geom.point.coord(:,1));
    ymin = min(geom.point.coord(:,2));
    ymax = max(geom.point.coord(:,2));

    xone = find(alon>=xmin,1,'first');
    xend = find(alon<=xmax,1, 'last');
    
    xone = xone - 1 ;
    xend = xend + 1 ;
    
    yone = find(alat>=ymin,1,'first');
    yend = find(alat<=ymax,1, 'last');
    
    yone = yone - 1 ;
    yend = yend + 1 ;
    
    alon = alon(xone:xend) ;
    alat = alat(yone:yend) ;
    zlev = zlev(yone:yend,xone:xend) ;

%------------------------------------ compute HFUN from TOPO    
        
    fprintf(1,'  Forming HFUN data...\n'); 
    
    hmin = +10. ;                       % min. H(X) [deg.]
    hmax = +100. ;                      % max. H(X)
    
    hfun = sqrt(max(-zlev,eps))/.5;     % scale with sqrt(H)
    hfun = max(hfun,hmin);
    hfun = min(hfun,hmax);
    
%------------------------------------ set HFUN grad.-limiter
    
    dhdx = +.15 ;                       % smoothing limits
    
    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.radii = 6371.E+00;
    hmat.point.coord{1} = alon * pi/180. ;
    hmat.point.coord{2} = alat * pi/180. ;
    hmat.value = single(hfun);
    
    hmat = limgrad(hmat,dhdx);

%------------------------------------ do stereographic proj.    
   
    geom.point.coord(:,1:2) = ...
    geom.point.coord(:,1:2)    * pi/180. ;
    
    proj.kind  = 'STEREOGRAPHIC' ;
    proj.rrad  = 6371.E+00;
    proj.xmid  = ...
        mean(geom.point.coord(:, 1));
    proj.ymid  = ...
        mean(geom.point.coord(:, 2));
  
   [GEOM] = projmsh(geom,proj,'fwd');
   [HMSH] = projmsh(hmat,proj,'fwd');
    
    savemsh(opts.geom_file,GEOM) ;
    savemsh(opts.hfun_file,HMSH) ;

%------------------------------------ build mesh via JIGSAW! 
   
    fprintf(1,'  Constructing MESH...\n');
   
    opts.hfun_scal = 'absolute';        % null HFUN limits
    opts.hfun_hmax = +inf ;             
    opts.hfun_hmin = 0.00 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.mesh_eps1 = 1.00 ;
    
    MESH = jigsaw  (opts) ;
    
    plotplanar(GEOM,MESH,HMSH) ;
    
end

function demo3
%DEMO-3 --- generate a "multi-part" mesh of the (contiguous)
%USA, using state boundaries to partition the mesh.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/out/us48-PROJ.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/us48.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/us48-MESH.msh'];
    
%------------------------------------ import GEOM. from file
    
    geom = loadmsh('jigsaw/geo/us48.msh');
   
%------------------------------------ do stereographic proj.    
   
    geom.point.coord(:,1:2) = ...
    geom.point.coord(:,1:2) * pi/180;
    
    proj.kind  = 'STEREOGRAPHIC' ;
    proj.rrad  = 6371.E+00;
    proj.xmid  = ...
        mean(geom.point.coord(:, 1));
    proj.ymid  = ...
        mean(geom.point.coord(:, 2));
  
   [GEOM] = projmsh(geom,proj,'fwd');
    
    savemsh(opts.geom_file,GEOM) ;
    
%------------------------------------ create mesh via JIGSAW
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_hmax = .005 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    opts.mesh_eps1 = +1/6 ;
    
    opts.optm_qlim = +.95 ;
    
    MESH = jigsaw  (opts) ;
    
    HFUN = [] ;
    
    plotplanar(GEOM,MESH,HFUN) ;

end

function demo4
% DEMO-4: generate a uniform resolution (150km) global grid. 

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/EARTH-CONST-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/EARTH-CONST.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/EARTH-CONST-MESH.msh'];
    
%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH';
    geom.radii = 6371 * ones(3,1);
    
    savemsh (opts.geom_file,geom);
    
%------------------------------------ build mesh via JIGSAW! 
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +150;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    
    mesh = jigsaw  (opts) ;
    
    hfun = [] ;
    
    plotsphere(mesh,hfun) ;
    
end

function demo5
% DEMO-5 -- generate a regionlly-refined global-grid, with a 
%   high-resolution north-atlantic 25km "patch" embedded wi- 
%   thin a uniformly resolved 150km background grid.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/EARTH-REGIONAL-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/EARTH-REGIONAL.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/EARTH-REGIONAL-MESH.msh'];
    
    opts.hfun_file = ...                % HFUN file
        ['jigsaw/out/EARTH-REGIONAL-HFUN.msh'];
    
%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH';
    geom.radii = 6371 * ones(3,1);
    
    savemsh (opts.geom_file,geom);
    
%------------------------------------ compute HFUN over GEOM
        
    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));
    
   [XPOS,YPOS] = meshgrid(xpos,ypos);
    
    XPOS = XPOS * pi/180 ;
    YPOS = YPOS * pi/180 ;
   
    hfun =-150. * exp(-0.8*(XPOS+.9).^2 ...
                      -0.8*(YPOS-.5).^2 ...
                  ) ;
    hfun(hfun < -125.) = -125. ;
    hfun = +150.0 + hfun ;
    
    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.point.coord{1} = XPOS(1,:) ;
    hmat.point.coord{2} = YPOS(:,1) ;
    hmat.value = single(hfun) ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = +.95 ;
    
    mesh = jigsaw  (opts) ;
    
    plotsphere(mesh,hmat) ;
    
end

function demo6
% DEMO-6 --- generate a multi-resolution grid for the arctic 
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 100km, backgr-
%   ound arctic resolution is 50km and min. adaptive resolu-
%   tion is 25km.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/EARTH-ARCTIC-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/EARTH-ARCTIC.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/EARTH-ARCTIC-MESH.msh'];
    
    opts.hfun_file = ...                % HFUN file
        ['jigsaw/out/EARTH-ARCTIC-HFUN.msh'];
    
%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH';
    geom.radii = 6371 * ones(3,1);
    
    savemsh (opts.geom_file,geom);
    
%------------------------------------ compute HFUN over GEOM
        
    fprintf(1,'  Loading TOPO data...\n');
        
    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));
    
   [nlat,nlon] = size(zlev);

    radE = 6371.0E+00 ;
   
    fprintf(1,'  Forming HFUN data...\n');
   
   [XPOS,YPOS] = meshgrid (xpos,ypos) ;
      
    hfn0 = +100. ;                      % global spacing
    hfn2 = +20.;                        % adapt. spacing
    hfn3 = +50.;                        % arctic spacing
    
    hfun = +hfn0*ones(nlat,nlon) ;
    
    htop = sqrt(max(-zlev(:),eps))/1.5;
    htop = max(htop,hfn2);
    htop = min(htop,hfn3);
    htop(zlev>0.) = hfn0 ;
    
    hfun(YPOS>+50.) = htop(YPOS>+50.) ;

%------------------------------------ set HFUN grad.-limiter
    
    dhdx = +.10;                        % max. gradients
       
    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.radii = radE ;
    hmat.point.coord{1} = xpos*pi/180 ;
    hmat.point.coord{2} = ypos*pi/180 ;
    hmat.value = single(hfun) ;
    
    hmat = limgrad(hmat,dhdx) ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = +.95 ;
    
    mesh = jigsaw  (opts) ;

    plotsphere(mesh,hmat) ;
    
end

function plotsphere(mesh,hfun)
%PLOT-SPHERE draw JIGSAW output for sphere problems.

    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));

    if (~isempty(hfun))
%------------------------------------ disp. 'grid' functions
    if (all(size(hfun.value)==size(zlev)))
        vals = hfun.value ;
        vals(zlev>0.) = inf ;
    end
    figure('color','w');
    surf(hfun.point.coord{1}*180/pi, ...
         hfun.point.coord{2}*180/pi, ...
         vals) ;
    view(2); axis image; hold on ;
    shading interp;
    title('JIGSAW HFUN data') ; 
    end
    
    if (~isempty(mesh))
%------------------------------------ draw unstructured mesh
    tlev = ...
        findalt(mesh,xpos,ypos,zlev);
    W   = tlev <= +0. ;
    D   = tlev >  +0. ;
    
    figure('color','w') ;
    patch ('faces',mesh.tria3.index(W,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facevertexcdata',tlev(W,:), ...
        'facecolor','flat', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image off;
    patch ('faces',mesh.tria3.index(D,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','w', ...
        'edgecolor','none');
    set(gca,'clipping','off') ;
    caxis([min(zlev(:))*4./3., +0.]);
    colormap('hot');
    brighten(+0.75);
    title('JIGSAW TRIA mesh (MASK)');
    
    drawcost(meshcost( mesh, hfun)) ;
    end
         
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.35,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(3),'units','normalized', ...
        'position',[.05,.10,.30,.35]) ;
    drawnow ;

end

function plotplanar(geom,mesh,hfun)
%PLOT-PLANAR draw JIGSAW output for planar problems.
  
    if (~isempty(geom))
%------------------------------------ draw domain boundaries
    figure('color','w');
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    hold on; axis image;
    title('JIGSAW GEOM data') ;
    end

    if (~isempty(hfun))
    switch (hfun.mshID)
    case{'EUCLIDEAN-GRID', ...
         'ELLIPSOID-GRID'}
%------------------------------------ disp. 'grid' functions
   [xpos,ypos] = meshgrid( ...
         hfun.point.coord{   1}, ...
         hfun.point.coord{   2}) ;
    mask = ~inpoly2( ...
        [xpos(:),ypos(:)], ...
        geom.point.coord(:,1:2), ...
        geom.edge2.index(:,1:2)) ;
    vals = hfun.value ;
    vals(mask) = +inf ;   
    figure('color','w') ;
    surf(hfun.point.coord{1}, ...
         hfun.point.coord{2}, ...
         vals) ;
    view(2); axis image; hold on ;
    shading interp;
    title('JIGSAW HFUN data') ;
    
    case{'EUCLIDEAN-MESH', ...
         'ELLIPSOID-MESH'}
%------------------------------------ disp. 'mesh' functions
    pmsk = inpoly2( ...
        hfun.point.coord(:,1:2), ...
        geom.point.coord(:,1:2), ...
        geom.edge2.index(:,1:2)) ;
    tmsk = pmsk( ...
        hfun.tria3.index(:,1:3)) ;
    K = sum(tmsk,2) > 1 ;
    figure('color','w') ;
    patch ('faces',hfun.tria3.index(K,1:3), ...
        'vertices',hfun.point.coord(:,1:2), ...
        'facevertexcdata',hfun.value, ...
        'facecolor','flat', ...
        'edgecolor','none') ;
    view(2); axis image; hold on ;
    title('JIGSAW HFUN data') ;
       
    end 
    end

    if (~isempty(mesh))
%------------------------------------ draw unstructured mesh
    figure('color','w');
  
    P = mesh.tria3.index (:,4);
    if ( all (P == +0))
    patch ('faces',mesh.tria3.index(:,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;    
    else
    for ip = 1 : max(P)
    I = P == ip;
    patch ('faces',mesh.tria3.index(I,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor', rand(1,3), ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    end
    end
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    if (~isempty(geom))
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.8], ...
        'linewidth',1.5) ;
    end
    title('JIGSAW TRIA mesh') ;

    drawcost( ...
        meshcost( mesh,hfun)) ;
    end
    
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.35,.55,.30,.35]) ;
    set(figure(3),'units','normalized', ...
        'position',[.35,.10,.30,.35]) ;
    set(figure(4),'units','normalized', ...
        'position',[.05,.10,.30,.35]) ;
    drawnow ;

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


