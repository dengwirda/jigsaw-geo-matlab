function ensemble(enum)
%ENSEMBLE example grid ensemble test cases.
%
%   ENSEMBLE(N) calls the N-TH ensemble test case.
%
% - ENSEMBLE:1 generate an ensemble of grids starting from a 
%   uniform resolution initial condition.
%
% - ENSEMBLE:2 generate an ensemble of grids starting from a 
%   variable resolution initial condition.
%
%   See also JIGSAW, TRIPOD

    close all ; libpath ; libdata ;
    
    switch (enum)
%------------------------------------ call the demo programs
        case 1, ensembleA() ;
        case 2, ensembleB() ;
            
        otherwise
        error( ...
    'ensemble:invalidSelection','Invalid selection!') ;
    end

end

function ensembleA
%ENSEMBLE-A generate an ensemble of grids starting from a 
%uniform resolution initial condition.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/EARTH-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/EARTH.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/EARTH-MESH.msh'];
        
%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH';
    geom.radii = 6371 * ones(3,1);
    
    savemsh (opts.geom_file,geom);
    
%------------------------------------ build mesh via JIGSAW! 
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +100.;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    
    mesh = bisect_sphere(opts,+1) ;
    plotsphere(mesh) ;

%------------------------------------ "random" perturbations 

    mesh = jumble_sphere(opts,mesh,.25) ;
    plotsphere(mesh) ;
    
    mesh = jumble_sphere(opts,mesh,.50) ;
    plotsphere(mesh) ;

    mesh = jumble_sphere(opts,mesh,.75) ;
    plotsphere(mesh) ;
    
%------------------------------------ tile mesh/cost figures    
    
    set(figure(1),'units','normalized', ...
        'position',[.05,.55,.20,.25]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.20,.20,.25]) ;
        
    set(figure(3),'units','normalized', ...
        'position',[.25,.55,.20,.25]) ;
    set(figure(4),'units','normalized', ...
        'position',[.25,.20,.20,.25]) ;
        
    set(figure(5),'units','normalized', ...
        'position',[.45,.55,.20,.25]) ;
    set(figure(6),'units','normalized', ...
        'position',[.45,.20,.20,.25]) ;
        
    set(figure(7),'units','normalized', ...
        'position',[.65,.55,.20,.25]) ;
    set(figure(8),'units','normalized', ...
        'position',[.65,.20,.20,.25]) ;        
    drawnow ;

end

function ensembleB
%ENSEMBLE-B generate an ensemble of grids starting from a 
%variable resolution initial condition.

%------------------------------------ setup files for JIGSAW

    opts.geom_file = ...                % GEOM file
        ['jigsaw/geo/EARTH-GEOM.msh'];
    
    opts.jcfg_file = ...                % JCFG file
        ['jigsaw/out/EARTH.jig'];
    
    opts.mesh_file = ...                % MESH file
        ['jigsaw/out/EARTH-MESH.msh'];
        
    opts.hfun_file = ...
        ['jigsaw/out/EARTH-ARCTIC-HFUN.msh'];
    
%------------------------------------ define JIGSAW geometry

    geom.mshID = 'ELLIPSOID-MESH';
    geom.radii = 6371 * ones(3,1);
    
    savemsh (opts.geom_file,geom);
    
%------------------------------------ build mesh via JIGSAW! 
    
    fprintf(1,'  Constructing MESH...\n');
    
    opts.hfun_scal = 'absolute';
    opts.hfun_hmax = +inf ;
    opts.hfun_hmin = +0.0 ;
    
    opts.mesh_dims = +2 ;               % 2-dim. simplexes

    opts.optm_qlim = +.95 ;
    
    mesh = bisect_sphere(opts,+1) ;
    plotsphere(mesh) ;

%------------------------------------ "random" perturbations 

    mesh = jumble_sphere(opts,mesh,.25) ;
    plotsphere(mesh) ;
    
    mesh = jumble_sphere(opts,mesh,.50) ;
    plotsphere(mesh) ;

    mesh = jumble_sphere(opts,mesh,.75) ;
    plotsphere(mesh) ;

%------------------------------------ tile mesh/cost figures    
    
    set(figure(1),'units','normalized', ...
        'position',[.05,.55,.20,.25]) ;
    set(figure(2),'units','normalized', ...
        'position',[.05,.20,.20,.25]) ;
        
    set(figure(3),'units','normalized', ...
        'position',[.25,.55,.20,.25]) ;
    set(figure(4),'units','normalized', ...
        'position',[.25,.20,.20,.25]) ;
        
    set(figure(5),'units','normalized', ...
        'position',[.45,.55,.20,.25]) ;
    set(figure(6),'units','normalized', ...
        'position',[.45,.20,.20,.25]) ;
        
    set(figure(7),'units','normalized', ...
        'position',[.65,.55,.20,.25]) ;
    set(figure(8),'units','normalized', ...
        'position',[.65,.20,.20,.25]) ;        
    drawnow ;

end

function plotsphere(mesh)
%PLOT-SPHERE draw JIGSAW output for sphere problems.

    topo = loadmsh('jigsaw/geo/topo.msh');
    
    xpos = topo.point.coord{1};
    ypos = topo.point.coord{2};
    zlev = reshape( ...
    topo.value,length(ypos),length(xpos));

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
    
    drawcost(meshcost(mesh)) ;
    end
    
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



