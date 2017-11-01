function meshdemo(demo)
%MESHDEMO build example meshes for JIGSAW(GEO).
%
%   MESHDEMO(N) calls the N-TH demo problem. The following 
%   demo problems are currently available:
%
% - DEMO-1: a simple example demonstrating the construction
%   of PSLG geometry and user-defined mesh-size constraints.
%
% - DEMO-2: build a grid for the Australian region, using
%   scaled ocean-depth as a mesh-spacing indicator.
%
% - DEMO-3: generate a uniform resolution 150km global grid.
%
% - DEMO-4: generate a regionlly-refined global-grid, with a 
%   high-resolution north-atlantic 25km "patch" embedded wi- 
%   thin a uniformly resolved 150km background grid.
%
% - DEMO-5: generate a multi-resolution grid for the arctic 
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 100km, backgr-
%   ound arctic resolution is 50km and min. adaptive resolu-
%   tion is 25km.
%
%   See also JIGSAW

%-----------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   31-Oct-2017
%   de2363@columbia.edu
%-----------------------------------------------------------
%

%------------------------------------ push path to utilities
    
    filename = mfilename('fullpath') ;
    filepath = fileparts( filename ) ;
    
    addpath([filepath,'/mesh-util']) ;
 
    close all ;

    switch (demo)
%------------------------------------ call the demo programs

        case 1, demo1() ;
        case 2, demo2() ;
        case 3, demo3() ;
        case 4, demo4() ;
        case 5, demo5() ;
            
        otherwise
        error( ...
    'meshdemo:invalidSelection','Invalid selection!') ;
    end
 
end
 
function demo1
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
    
    hfun =-.3*exp(-.1*(XPOS-4.5).^2 ...
                  -.1*(YPOS-4.5).^2 ...
            ) + .4 ;
    
    hmat.mshID = 'EUCLIDEAN-GRID' ;
    hmat.point.coord{1} = xpos ;
    hmat.point.coord{2} = ypos ;
    hmat.value = hfun ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
  
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;             % null HFUN limits
    opts.hfun_hmin = 0.00 ;
  
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = 0.9375 ;
   
    opts.mesh_top1 = true ;             % for sharp feat's
    opts.geom_feat = true ;
    
    mesh = jigsaw  (opts) ;
 
%------------------------------------ draw mesh/cost outputs

    ang2 = triang2( ...                 % calc. tri-angles
        mesh.point.coord(:,1:2), ...
        mesh.tria3.index(:,1:3)) ;
            
    t_90 = max(ang2,[],2) > 90.0 ;
    t_95 = max(ang2,[],2) > 95.0 ;
    
    figure;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    hold on; axis image;
    title('JIGSAW GEOM data') ;

    figure;
    surf(XPOS,YPOS,hfun);
    view(2); hold on; axis image; 
    shading interp ;
    title('JIGSAW HFUN data') ;

    figure;
    patch ('faces',mesh.tria3.index(:,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    patch ('faces',mesh.tria3.index(t_90,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','y', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.tria3.index(t_95,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','r', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    title('JIGSAW TRIA mesh') ;

    drawscr(mesh.point.coord (:,1:2), ...
            mesh.edge2.index (:,1:2), ...
            mesh.tria3.index (:,1:3)) ;
    
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
 
function demo2
% DEMO-2 --- build a grid for the Australian region, using
%   scaled ocean-depth as a mesh-spacing indicator.
 
%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/AUS-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/AUS.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/AUS-MESH.msh'];
    
    opts.hfun_file = ...                % HFUN file
        ['jigsaw/out/AUS-HFUN.msh'];
        
%------------------------------------ setup TOPO for spacing
  
    fprintf(1,'  Loading TOPO data...\n');
  
    geom = loadmsh('jigsaw/geo/AUS-GEOM.msh');
    
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
    
    hmin = +.075 ;                      % min. H(X) [deg.]
    hmax = +.750 ;                      % max. H(X)
    
    hfun = -zlev(:) / 2000.;            % scale with depth
    hfun = max(hfun,hmin);
    hfun = min(hfun,hmax);
    
%------------------------------------ set HFUN grad.-limiter

    fprintf(1,'  Set HFUN limiters...\n');
    
   [ALON,ALAT] = meshgrid(alon,alat) ;
    
    vert = [ALON(:),ALAT(:)];           % triangulate vert
    
    tria = ...
        delaunayn(double (vert));
    
    dhdx = +.150 ;                      % smoothing limits
    
   [hfun] = ...
    limhfn2(vert,tria,hfun,dhdx);
    
%------------------------------------ save GEOM/HFUN to file
    
    fprintf(1,'  Save data to file...\n');
    
    hmat.mshID = 'EUCLIDEAN-GRID';
    hmat.point.coord{1} = alon ;
    hmat.point.coord{2} = alat ;
    hmat.value = single(reshape( ...
        hfun,length(alat),length(alon)) );
    
    savemsh(opts.hfun_file,hmat) ;

%------------------------------------ build mesh via JIGSAW! 
   
    opts.hfun_scal = 'absolute';        % null HFUN limits
    opts.hfun_hmax = +inf ;             
    opts.hfun_hmin = 0.00 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.mesh_eps1 = 1.00 ;
    opts.mesh_rad2 = 1.00 ;
    
    mesh = jigsaw  (opts) ;
  
%------------------------------------ draw mesh/cost outputs

    ang2 = triang2( ...                 % calc. tri-angles
        mesh.point.coord(:,1:2), ...
        mesh.tria3.index(:,1:3)) ;
            
    t_90 = max(ang2,[],2) > 90.0 ;
    t_95 = max(ang2,[],2) > 95.0 ;

    figure;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','none', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    hold on; axis image;
    title('JIGSAW GEOM data') ;

    hmat.value(zlev > +0.) = +inf ;
    
    figure;
    surf(alon,alat,hmat.value);
    view(2); hold on; axis image; 
    shading interp;
    title('JIGSAW HFUN data') ;

    figure;
    patch ('faces',mesh.tria3.index(:,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image;
    patch ('faces',mesh.tria3.index(t_90,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','y', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.tria3.index(t_95,1:3), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','r', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.edge2.index(:,1:2), ...
        'vertices',mesh.point.coord(:,1:2), ...
        'facecolor','w', ...
        'edgecolor',[.1,.1,.1], ...
        'linewidth',1.5) ;
    patch ('faces',geom.edge2.index(:,1:2), ...
        'vertices',geom.point.coord(:,1:2), ...
        'facecolor','none', ...
        'edgecolor',[.1,.1,.8], ...
        'linewidth',1.0) ;
    title('JIGSAW TRIA mesh') ;

    drawscr(mesh.point.coord (:,1:2), ...
            mesh.edge2.index (:,1:2), ...
            mesh.tria3.index (:,1:3)) ;
    
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

function demo3
% DEMO-3: generate a uniform resolution (150km) global grid. 

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
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = 150. ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = 0.9375 ;
    
    opts.verbosity = +1 ;
    
    mesh = jigsaw  (opts) ;
    
%------------------------------------ draw mesh/cost outputs

    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));

    tlev = ...
        findalt(mesh,xpos,ypos,zlev) ;

    ang2 = triang2( ...                 % calc. tri-angles
        mesh.point.coord(:,1:3), ...
        mesh.tria3.index(:,1:3)) ;
            
    t_90 = max(ang2,[],2) > 90.0 ;
    t_95 = max(ang2,[],2) > 95.0 ;
    
    twet = tlev <= +0. ;
    tdry = tlev >  +0. ;
    
    figure;
    patch ('faces',mesh.tria3.index(twet,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facevertexcdata',tlev(twet,:), ...
        'facecolor','flat', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image off;
    patch ('faces',mesh.tria3.index(tdry,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','w', ...
        'edgecolor','none');
    patch ('faces',mesh.tria3.index(t_90,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','y', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.tria3.index(t_95,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','r', ...
        'edgecolor',[.2,.2,.2]) ;
    set(gca,'clipping','off') ;
    caxis([min(zlev(:))*4./3., +0.]);
    colormap('hot');
    brighten(+0.75);
    title('JIGSAW TRIA mesh') ;
    
    drawscr(mesh.point.coord (:,1:3), ...
            [], ...
            mesh.tria3.index (:,1:3)) ;
            
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.10,.30,.35]) ;
    drawnow ;
    
end

function demo4
% DEMO-4 -- generate a regionlly-refined global-grid, with a 
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
    hmat.value = hfun ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = 0.9375 ;
    
    opts.verbosity = +1 ;
    
    mesh = jigsaw  (opts) ;
    
%------------------------------------ draw mesh/cost outputs

    tlev = ...
        findalt(mesh,xpos,ypos,zlev) ;

    ang2 = triang2( ...                 % calc. tri-angles
        mesh.point.coord(:,1:3), ...
        mesh.tria3.index(:,1:3)) ;
            
    t_90 = max(ang2,[],2) > 90.0 ;
    t_95 = max(ang2,[],2) > 95.0 ;
    
    hfun(zlev > +0.) = inf;
    
    figure;
    surf(XPOS*180/pi,YPOS*180/pi,hfun) ;
    view(2); axis image; hold on ;
    shading interp;
    title('JIGSAW HFUN data') ;
    
    twet = tlev <= +0. ;
    tdry = tlev >  +0. ;
    
    figure;
    patch ('faces',mesh.tria3.index(twet,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facevertexcdata',tlev(twet,:), ...
        'facecolor','flat', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image off;
    patch ('faces',mesh.tria3.index(tdry,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','w', ...
        'edgecolor','none');
    patch ('faces',mesh.tria3.index(t_90,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','y', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.tria3.index(t_95,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','r', ...
        'edgecolor',[.2,.2,.2]) ;
    set(gca,'clipping','off') ;
    caxis([min(zlev(:))*4./3., +0.]);
    colormap('hot');
    brighten(+0.75);
    title('JIGSAW TRIA mesh') ;
    
    drawscr(mesh.point.coord (:,1:3), ...
            [], ...
            mesh.tria3.index (:,1:3)) ;
            
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.35,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(3),'units','normalized', ...
        'position',[.05,.10,.30,.35]) ;
    drawnow ;
    
end

function demo5
% DEMO-5 --- generate a multi-resolution grid for the arctic 
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
        
    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));
    
   [nlat,nlon] = size(zlev);

    radE = 6371.0E+00 ;
   
   [XPOS,YPOS] = meshgrid (xpos,ypos) ;
      
    hfn0 = +100. ;                      % global spacing
    hfn2 = +25.;                        % adapt. spacing
    hfn3 = +50.;                        % arctic spacing
    
    dhdx = +.10;                        % max. gradients
    
    hfun = +hfn0*ones(nlat,nlon) ;
    
    htop = max(-hfn2*zlev/1000.,hfn2) ;
    htop = min(htop,hfn3);
    
    hfun(YPOS>+50.) = htop(YPOS>+50.) ;
    
    hnew = limhfun( ...
       xpos,ypos,radE,true,hfun,dhdx) ;
   
    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.point.coord{1} = xpos*pi/180 ;
    hmat.point.coord{2} = ypos*pi/180 ;
    hmat.value = hnew ;
    
    savemsh(opts.hfun_file,hmat) ;
    
%------------------------------------ build mesh via JIGSAW! 
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    
    opts.optm_qlim = 0.9375 ;
    
    opts.verbosity = +1 ;
    
    mesh = jigsaw  (opts) ;
    
%------------------------------------ draw mesh/cost outputs

    tlev = ...
        findalt(mesh,xpos,ypos,zlev) ;

    ang2 = triang2( ...                 % calc. tri-angles
        mesh.point.coord(:,1:3), ...
        mesh.tria3.index(:,1:3)) ;
            
    t_90 = max(ang2,[],2) > 90.0 ;
    t_95 = max(ang2,[],2) > 95.0 ;
    
    hnew(zlev > +0.) = inf;
    
    figure;
    surf(XPOS,YPOS,hnew) ;
    view(2); axis image; hold on ;
    shading interp;
    title('JIGSAW HFUN data') ;
    
    twet = tlev <= +0. ;
    tdry = tlev >  +0. ;
    
    figure;
    patch ('faces',mesh.tria3.index(twet,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facevertexcdata',tlev(twet,:), ...
        'facecolor','flat', ...
        'edgecolor',[.2,.2,.2]) ;
    hold on; axis image off;
    patch ('faces',mesh.tria3.index(tdry,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','w', ...
        'edgecolor','none');
    patch ('faces',mesh.tria3.index(t_90,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','y', ...
        'edgecolor',[.2,.2,.2]) ;
    patch ('faces',mesh.tria3.index(t_95,1:3), ...
        'vertices',mesh.point.coord(:,1:3), ...
        'facecolor','r', ...
        'edgecolor',[.2,.2,.2]) ;
    set(gca,'clipping','off') ;
    caxis([min(zlev(:))*4./3., +0.]);
    colormap('hot');
    brighten(+0.75);
    title('JIGSAW TRIA mesh') ;
    
    drawscr(mesh.point.coord (:,1:3), ...
            [], ...
            mesh.tria3.index (:,1:3)) ;
            
    drawnow ;        
    set(figure(1),'units','normalized', ...
        'position',[.35,.55,.30,.35]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.55,.30,.35]) ;
    set(figure(3),'units','normalized', ...
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


