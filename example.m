function example(varargin)
%EXAMPLE build example meshes for JIGSAW(GEO).
%
%   EXAMPLE(N) calls the N-TH demo problem. The following
%   demo problems are currently available:
%
% - DEMO-1: generate a uniform resolution 150KM global grid.
%
% - DEMO-2: generate a regionally-refined global-grid, with
%   a high-resolution "patch" (37.5KM resolution) embedded
%   within a uniformly resolved 150KM background grid.
%
%   DEMO-3: build "smooth" mesh-spacing functions from noisy
%   + discontinuous input data using MARCHE.
%
% - DEMO-4: generate a multi-resolution grid for the arctic
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 150KM, backgr-
%   ound arctic resolution is 67KM and min. adaptive resolu-
%   tion is 33KM.
%
% - DEMO-5: generate uniform resolution struct. icosahedral
%   and cubedsphere grids.
%
% - DEMO-6: generate a grid for the Australian region, using
%   scaled ocean-depth as a mesh-spacing indicator.
%
% - DEMO-7: generate a "multi-part" mesh of the (contiguous)
%   USA, using state boundaries to partition the mesh.
%
%   See also JIGSAW
%

%-----------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   12-Sep-2020
%   d.engwirda@gmail.com
%-----------------------------------------------------------
%

    close all ; initjig ;

    demo =  +1;

    if (nargin >= 1), demo = varargin{1}; end

    switch (demo)
        case 1, demo_1 ;
        case 2, demo_2 ;
        case 3, demo_3 ;
        case 4, demo_4 ;
        case 5, demo_5 ;
        case 6, demo_6 ;
        case 7, demo_7 ;

        otherwise
        error( ...
    'example:invalidSelection','Invalid selection!') ;
    end

end

function demo_1
% DEMO-1: generate a uniform resolution (150KM) global grid.
%   JIGSAW is combined with a bisection procedure to improve
%   the regularity of the grid topology.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','opts.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH' ;
    geom.radii = 6371 * ones(3,1) ;

    savemsh (opts.geom_file,geom) ;

%------------------------------------ build mesh via JIGSAW!

    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +150. ;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    opts.optm_iter = + 32 ;

    mesh = tetris(opts, +4) ;

    topo = loadmsh( ...
        fullfile(rootpath, ...
            'files', 'topo.msh')) ;

    plotsphere(geom,mesh,[],topo) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;

    set(figure(2),'units','normalized', ...
    'position',[.05,.10,.25,.30]) ;

end

function demo_2
% DEMO-2 -- generate a regionally-refined global grid with a
%   high-resolution "patch" (@37.5KM) embedded within a
%   uniform background grid (@150.KM).
%   JIGSAW is combined with a bisection procedure to improve
%   the regularity of the grid topology.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','opts.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

    opts.hfun_file = ...                % sizing file
        fullfile(rootpath,...
            'cache','spac.msh') ;

%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH' ;
    geom.radii = 6371 * ones(3,1) ;

    savemsh (opts.geom_file,geom) ;

%------------------------------------ compute HFUN over GEOM

    topo = loadmsh(fullfile( ...
        rootpath, 'files', 'topo.msh' ) );

    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));

   [XPOS,YPOS] = meshgrid(xpos,ypos);

    XPOS = XPOS * pi/180 ;
    YPOS = YPOS * pi/180 ;

    hfun = +150.0 - 112.5 * exp( -( ...
        +1.5 * (XPOS + 1.0).^2 ...
        +1.5 * (YPOS - 0.5).^2).^4) ;

    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.radii = geom.radii;
    hmat.point.coord{1} = XPOS(1,:) ;
    hmat.point.coord{2} = YPOS(:,1) ;
    hmat.value = single(hfun);

    savemsh(opts.hfun_file,hmat) ;

%------------------------------------ build mesh via JIGSAW!

    fprintf(1,'  Constructing MESH...\n');

    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    opts.optm_iter = + 32 ;

    mesh = tetris(opts, +4) ;

    plotsphere(geom,mesh,hmat,topo) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;

    set(figure(2),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    set(figure(3),'units','normalized', ...
    'position',[.05,.10,.25,.30]) ;

end

function demo_3
% DEMO-3 --- use MARCHE to build "smooth" mesh-spacing data
%   from noisy/discontinuous inputs.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','opts.jig') ;

    opts.hfun_file = ...                % sizing file
        fullfile(rootpath,...
            'cache','spac.msh') ;

%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH' ;
    geom.radii = 6371 * ones(3,1) ;

    savemsh (opts.geom_file,geom) ;

%------------------------------------ compute HFUN over GEOM

    fprintf(1,'  Loading TOPO data...\n');

    topo = loadmsh(fullfile( ...
        rootpath, 'files', 'topo.msh' ) );

    fprintf(1,'  Forming HFUN data...\n');

    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = topo.value;

   [XPOS,YPOS] = meshgrid (xpos,ypos) ;

    hfn0 = +150. ;                      % global spacing
    hfn2 = +33.;                        % adapt. spacing
    hfn3 = +67.;                        % arctic spacing

    hfun = +hfn0*ones(size(zlev)) ;

    htop = sqrt(max(-zlev(:),eps))/1. ;
    htop = max(htop,hfn2);
    htop = min(htop,hfn3);
    htop(zlev>0.) = hfn0 ;

    hfun(YPOS>=40.) = htop(YPOS>=40.) ;

%------------------------------------ set HFUN grad.-limiter

    dhdx = +0.050 ;                      % max. gradients

    hmat.mshID = 'ELLIPSOID-GRID' ;
    hmat.radii = geom.radii ;
    hmat.point.coord{1} = xpos*pi/180 ;
    hmat.point.coord{2} = ypos*pi/180 ;
    hmat.value = single(hfun) ;
    hmat.slope = dhdx*ones(size(hfun));

    savemsh (opts.hfun_file,hmat) ;

%------------------------------------ set HFUN grad.-limiter

    hlim = marche(opts) ;

    plotsphere(geom,[],hmat,topo) ;
    plotsphere(geom,[],hlim,topo) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    title('H(x): raw data');

    set(figure(2),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;
    title('H(x): smoothed');

end

function demo_4
% DEMO-4 --- generate a multi-resolution grid for the arctic
%   ocean basin, with local refinement along coastlines and
%   shallow ridges. Global grid resolution is 150KM, backgr-
%   ound arctic resolution is 67KM and min. adaptive resolu-
%   tion is 33KM.
%   JIGSAW is combined with a bisection procedure to improve
%   the regularity of the grid topology.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','opts.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

    opts.hfun_file = ...                % sizing file
        fullfile(rootpath,...
            'cache','spac.msh') ;

%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH' ;
    geom.radii = 6371 * ones(3,1) ;

    savemsh (opts.geom_file,geom) ;

%------------------------------------ compute HFUN over GEOM

    fprintf(1,'  Loading TOPO data...\n');

    topo = loadmsh(fullfile( ...
        rootpath, 'files', 'topo.msh' ) );

    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));

   [nlat,nlon] = size(zlev);

    radE = 6371.0E+00 ;

    fprintf(1,'  Forming HFUN data...\n');

   [XPOS,YPOS] = meshgrid (xpos,ypos) ;

    hfn0 = +150. ;                      % global spacing
    hfn2 = +33.;                        % adapt. spacing
    hfn3 = +67.;                        % arctic spacing

    hfun = +hfn0*ones(nlat,nlon) ;

    htop = sqrt(max(-zlev(:),eps))/1. ;
    htop = max(htop,hfn2);
    htop = min(htop,hfn3);
    htop(zlev>0.) = hfn0 ;

    hfun(YPOS>=40.) = htop(YPOS>=40.) ;

%------------------------------------ set HFUN grad.-limiter

    dhdx = +0.050 ;                     % max. gradients

    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.radii = radE ;
    hmat.point.coord{1} = xpos*pi/180 ;
    hmat.point.coord{2} = ypos*pi/180 ;
    hmat.value = single(hfun) ;
    hmat.slope = dhdx*ones(size(hfun));

    savemsh(opts.hfun_file,hmat) ;

%------------------------------------ set HFUN grad.-limiter

    hmat = marche(opts) ;

%------------------------------------ build mesh via JIGSAW!

    fprintf(1,'  Constructing MESH...\n');

    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    opts.optm_iter = + 32 ;

    mesh = tetris(opts, +4) ;

    plotsphere(geom,mesh,hmat,topo) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;

    set(figure(2),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    set(figure(3),'units','normalized', ...
    'position',[.05,.10,.25,.30]) ;

end

function demo_5
% DEMO-5: generate uniform resolution structured icosahedral
%   and cubedsphere grids.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','opts.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH' ;
    geom.radii = 1. * ones(3,1) ;

    savemsh (opts.geom_file,geom) ;

%------------------------------------ build mesh via JIGSAW!

    topo = loadmsh( ...
        fullfile(rootpath, ...
            'files', 'topo.msh')) ;

    opts.hfun_hmax = +1.;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qtol = +1.E-06 ;
    opts.optm_iter = +512 ;

    mesh = icosahedron(opts, +6) ;

    plotsphere(geom,mesh,[],topo) ;

    mesh = cubedsphere(opts, +6) ;

    plotsphere(geom,mesh,[],topo) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    set(figure(2),'units','normalized', ...
    'position',[.05,.10,.25,.30]) ;

    set(figure(3),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;
    set(figure(4),'units','normalized', ...
    'position',[.30,.10,.25,.30]) ;

end

function demo_6
% DEMO-6 -- generate a 2-dim. grid for the Australian region
%   using scaled ocean-depth as a mesh-spacing indicator.
%   A local stereographic projection is employed.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','aust.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

    opts.hfun_file = ...                % sizing file
        fullfile(rootpath,...
            'cache','spac.msh') ;

%------------------------------------ setup TOPO for spacing

    fprintf(1,'  Loading TOPO data...\n');

    geom = loadmsh(fullfile( ...
        rootpath,'files','aust.msh'));

    topo = loadmsh(fullfile( ...
        rootpath,'files','topo.msh'));

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

    hfun = sqrt(max(-zlev,eps))/.5 ;    % scale with H^1/2
    hfun = max(hfun,hmin);
    hfun = min(hfun,hmax);

    dhdx = +.15 *ones(size(hfun));      % smoothing limits

    hmat.mshID = 'ELLIPSOID-GRID';
    hmat.radii = 6371.E+00;
    hmat.point.coord{1} = ...
                alon * pi / 180. ;
    hmat.point.coord{2} = ...
                alat * pi / 180. ;
    hmat.value = hfun ;
    hmat.slope = dhdx ;

%------------------------------------ do stereographic proj.

    fprintf(1,'  Forming PROJ data...\n');

    geom.point.coord(:,1:2) = ...
    geom.point.coord(:,1:2) * pi/180;

    proj.prjID  = 'STEREOGRAPHIC';
    proj.radii  = 6371.E+00;
    proj.xbase  = 0.5 * ( ...
        min(geom.point.coord(:,1)) ...
      + max(geom.point.coord(:,1)) );
    proj.ybase  = 0.5 * ( ...
        min(geom.point.coord(:,2)) ...
      + max(geom.point.coord(:,2)) );

   [GPRJ] = project(geom,proj,'fwd');
   [HPRJ] = project(hmat,proj,'fwd');

    savemsh(opts.geom_file,GPRJ) ;
    savemsh(opts.hfun_file,HPRJ) ;

%------------------------------------ set HFUN grad.-limiter

    HPRJ = marche  (opts) ;

%------------------------------------ build mesh via JIGSAW!

    fprintf(1,'  Constructing MESH...\n');

    opts.hfun_scal = 'absolute';        % null HFUN limits
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = 0.00 ;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.mesh_eps1 = 1.00 ;

    MPRJ = jigsaw  (opts) ;

    plotplanar(GPRJ,MPRJ,HPRJ) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    set(figure(2),'units','normalized', ...
    'position',[.05,.10,.25,.30]) ;
    set(figure(3),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;
    set(figure(4),'units','normalized', ...
    'position',[.30,.10,.25,.30]) ;

end

function demo_7
%DEMO-7 --- generate a "multi-part" mesh of the (contiguous)
%   USA, using state boundaries to partition the mesh.
%   A local stereographic projection is employed.

%------------------------------------ setup files for JIGSAW

    rootpath = fileparts( ...
        mfilename( 'fullpath' )) ;

    opts.geom_file = ...                % domain file
        fullfile(rootpath,...
            'cache','geom.msh') ;

    opts.jcfg_file = ...                % config file
        fullfile(rootpath,...
            'cache','us48.jig') ;

    opts.mesh_file = ...                % output file
        fullfile(rootpath,...
            'cache','mesh.msh') ;

%------------------------------------ import GEOM. from file

    geom = loadmsh(fullfile( ...
        rootpath,'files','us48.msh')) ;

%------------------------------------ do stereographic proj.

    geom.point.coord(:,1:2) = ...
    geom.point.coord(:,1:2) * pi/180;

    proj.prjID  = 'STEREOGRAPHIC';
    proj.radii  = 6371.E+00;
    proj.xbase  = 0.5 * ( ...
        min(geom.point.coord(:,1)) ...
      + max(geom.point.coord(:,1)) );
    proj.ybase  = 0.5 * ( ...
        min(geom.point.coord(:,2)) ...
      + max(geom.point.coord(:,2)) );

   [GEOM] = project(geom,proj,'fwd');

    savemsh(opts.geom_file,GEOM) ;

%------------------------------------ create mesh via JIGSAW

    fprintf(1,'  Constructing MESH...\n');

    opts.hfun_hmax = .005 ;

    opts.mesh_dims = +2 ;               % 2-dim. simplexes
    opts.mesh_eps1 = +1/6 ;

    MESH = jigsaw  (opts) ;

    plotplanar(GEOM,MESH,[]) ;

    drawnow ;
    set(figure(1),'units','normalized', ...
    'position',[.05,.50,.25,.30]) ;
    set(figure(2),'units','normalized', ...
    'position',[.30,.50,.25,.30]) ;
    set(figure(3),'units','normalized', ...
    'position',[.30,.10,.25,.30]) ;

end

function plotsphere(geom,mesh,hfun,topo)
%PLOT-SPHERE draw JIGSAW output for sphere problems.

    if (~isempty(topo))
        xpos = topo.point.coord{1};
        ypos = topo.point.coord{2};
        zlev = reshape( ...
        topo.value,length(ypos),length(xpos));
    else
        zlev = [] ;
    end

    if (~isempty(hfun))
    switch (upper(hfun.mshID))
        case{'EUCLIDEAN-GRID', ...
             'ELLIPSOID-GRID'}
%------------------------------------ disp. 'grid' functions
        hfun.value = reshape(hfun.value, ...
            length(hfun.point.coord{2}), ...
            length(hfun.point.coord{1})  ...
            ) ;
        if (all(size(hfun.value)==size(zlev)))
            vals = hfun.value ;
            vals(zlev>0.) = inf ;
        else
            vals = hfun.value ;
        end
        figure('color','w');
        surf(hfun.point.coord{1}*180/pi, ...
             hfun.point.coord{2}*180/pi, ...
             vals) ;
        view(2); axis image; hold on ;
        shading interp;
        title('JIGSAW HFUN data') ;
    end
    end

    if (~isempty(mesh))
%------------------------------------ draw unstructured mesh
    if (~isempty(topo))
       [tlev,qlev] = findalt( ...
            geom,mesh,xpos,ypos,zlev);
        figure('color','w') ;
        if (inspect(mesh,'tria3'))
        W   = tlev <= +0. ;
        D   = tlev >  +0. ;
        patch ('faces',mesh.tria3.index(W,1:3), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facevertexcdata',tlev(W), ...
            'facecolor','flat', ...
            'edgecolor','k') ;
        hold on; axis image off;
        patch ('faces',mesh.tria3.index(D,1:3), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facecolor','w', ...
            'edgecolor','none');
        end
        if (inspect(mesh,'quad4'))
        W   = qlev <= +0. ;
        D   = qlev >  +0. ;
        patch ('faces',mesh.quad4.index(W,1:4), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facevertexcdata',qlev(W), ...
            'facecolor','flat', ...
            'edgecolor','k') ;
        hold on; axis image off;
        patch ('faces',mesh.quad4.index(D,1:4), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facecolor','w', ...
            'edgecolor','none');
        end
        set(gca,'clipping','off') ;
        caxis([min(zlev(:))*4./3., +0.]);
        brighten(+0.75);
    else
        figure('color','w') ;
        if (inspect(mesh,'tria3'))
        patch ('faces',mesh.tria3.index(:,1:3), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facecolor','w', ...
            'edgecolor','k') ;
        hold on; axis image off;
        end
        if (inspect(mesh,'quad4'))
        patch ('faces',mesh.quad4.index(:,1:4), ...
            'vertices',mesh.point.coord(:,1:3), ...
            'facecolor','w', ...
            'edgecolor','k') ;
        hold on; axis image off;
        end
        set(gca,'clipping','off') ;
    end
    drawcost(mesh, hfun) ;
    end

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
    switch (upper(hfun.mshID))
        case{'EUCLIDEAN-GRID', ...
             'ELLIPSOID-GRID'}
%------------------------------------ disp. 'grid' functions
        hfun.value = reshape(hfun.value, ...
            length(hfun.point.coord{2}), ...
            length(hfun.point.coord{1})  ...
            ) ;
        figure('color','w') ;
        surf(hfun.point.coord{1}, ...
             hfun.point.coord{2}, ...
             hfun.value) ;
        view(2); axis image; hold on ;
        shading interp;
        title('JIGSAW HFUN data') ;

        case{'EUCLIDEAN-MESH', ...
             'ELLIPSOID-MESH'}
%------------------------------------ disp. 'mesh' functions
        figure('color','w') ;
        patch ('faces',hfun.tria3.index(:,1:3), ...
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
            'facecolor',[.9,.9,.9], ...
            'edgecolor',[.2,.2,.2]) ;
        hold on; axis image;
        else
        for ip = 1 : max(P)
        I = P == ip;
        patch ('faces',mesh.tria3.index(I,1:3), ...
            'vertices',mesh.point.coord(:,1:2), ...
            'facecolor', .5*rand(1,3)+.5, ...
            'edgecolor',[.2,.2,.2]) ;
        hold on; axis image;
        end
        end
        patch ('faces',mesh.edge2.index(:,1:2), ...
            'vertices',mesh.point.coord(:,1:2), ...
            'facecolor','w', ...
            'edgecolor',[.8,.1,.1], ...
            'linewidth',2.5) ;
        if (~isempty(geom))
        patch ('faces',geom.edge2.index(:,1:2), ...
            'vertices',geom.point.coord(:,1:2), ...
            'facecolor','w', ...
            'edgecolor',[.1,.1,.8], ...
            'linewidth',1.5) ;
        end
        title('JIGSAW TRIA mesh') ;

        drawcost (mesh,hfun) ;
    end

end

function [tlev,qlev] = ...
    findalt(geom,mesh,alon,alat,topo)
%FINDALT calc. an "altitude" for each mesh-cell in the mesh.

    tlev = []; qlev = [];

    xsph = R3toS2( ...
        geom.radii, mesh.point.coord(:, 1:3));

    xlat = xsph(:,2) * 180 / pi;
    xlon = xsph(:,1) * 180 / pi;

    xlev = interp2 (alon,alat,topo,xlon,xlat);

    if (inspect(mesh,'tria3'))
    tlev = xlev (mesh.tria3.index(:,1)) ...
         + xlev (mesh.tria3.index(:,2)) ...
         + xlev (mesh.tria3.index(:,3)) ;
    tlev = tlev / +3.0 ;
    end

    if (inspect(mesh,'quad4'))
    qlev = xlev (mesh.quad4.index(:,1)) ...
         + xlev (mesh.quad4.index(:,2)) ...
         + xlev (mesh.quad4.index(:,3)) ...
         + xlev (mesh.quad4.index(:,4)) ;
    qlev = qlev / +4.0 ;
    end

end


