function [varargout] = jigsawgeo(opts)
%JIGSAWGEO interface to the JIGSAW-GEO grid-generator.
%
%   MESH = JIGSAWGEO(OPTS);
%
%   Call the JIGSAW mesh generator using the configuration options spec-
%   ified in the OPTS structure. See READMSH/MAKEMSH for a description of 
%   the MESH output structure.
%
%   OPTS is a user-defined set of meshing options:
%
%   REQUIRED fields:
%   ---------------
%
%   OPTS.GEOM_FILE - 'GEOMNAME.GEO', a string containing the name of the 
%       geometry file (is required at input).
%
%   OPTS.JCFG_FILE - 'JCFGNAME.JIG', a string containing the name of the 
%       cofig. file (will be created on output).
%
%   OPTS.MESH_FILE - 'MESHNAME.MSH', a string containing the name of the 
%       output file (will be created on output).
%
%   OPTS.HFUN_FILE - 'HFUNNAME.DAT', a string containing the name of the 
%       grid-length file (is required at input). 
%
%   OPTIONAL fields (MESH):
%   ----------------------
%
%   OPTS.MESH_DIMS - {default=3} number of "topological" dimensions to 
%       mesh. DIMS=K meshes K-dimensional features, irrespective of the
%       number of spatial dimensions of the problem (i.e. if the geomet-
%       ry is 3-dimensional and DIMS=2 a surface mesh will be produced).
%
%   OPTS.MESH_KERN - {default='delfront'} meshing kernal, choice of the
%       standard Delaunay-refinement algorithm (KERN='delaunay') or the 
%       Frontal-Delaunay method (KERN='delfront').
%
%   OPTS.MESH_ITER - {default=+INF} max. number of mesh refinement iter-
%       ations. Set ITER=N to see progress after N iterations. 
%
%   OPTS.MESH_RAD2 - {default=1.05} max. radius-edge ratio for 2-tria 
%       elements. 2-trias are refined until the ratio of the element ci-
%       rcumradius to min. edge length is less-than MESH_RAD2.
%
%   OPTIONAL FIELDS (MISC):
%   ----------------------
%
%   OPTS.VERBOSITY - {default=0} verbosity of log-file output generated
%       by JIGSAW-GEO. Set VERBOSITY>=1 to display additional output.
%
%   See also READMSH, MAKEMSH, DRAWMESH
%

%   JIGSAW-GEO is an unstructured mesh generator for the construction of 
%   locally-orthogonal staggered unstructured grids for geophysical app-
%   lications on the sphere. Specifically, JIGSAW-GEO supports the gene-
%   ration of guaranteed-quality Voronoi/Delaunay grids appropriate for 
%   large-scale general circulation models.
%
%   JIGSAW-GEO is based on combination of "restricted" Frontal-Delaunay-
%   refinement and "hill-climbing" type optimisation algorithms. See the 
%   following references for additional details:
%    
%   [1] Darren Engwirda, Locally-orthognal unstructured grid-
%       generation for general circulation modelling on the sphere, 
%       2016, https://arxiv.org/abs/1611.08996
%
%   See the fulltext articles for additional information and references.

%---------------------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   13-Apr-2017
%   engwirda [at] mit [dot] edu
%---------------------------------------------------------------------
%

    jexename = '';

    if ( isempty(opts))
        error('JIGSAW: insufficient inputs.');
    end
    
    if (~isempty(opts) && ~isstruct(opts))
        error('JIGSAW: invalid input types.');
    end
        
    makejig(opts.jcfg_file,opts);
    
    filename = mfilename('fullpath');
    filepath = fileparts( filename );

%-- default to _debug binary
    if (strcmp(jexename,''))
    if (ispc())
        jexename = [filepath, ...
            '\jigsaw-geo\bin\WIN-64\jigsaw-geo64d.exe'];
    elseif (ismac ())
        jexename = [filepath, ...
            '/jigsaw-geo/bin/MAC-64/jigsaw-geo64d'];
    elseif (isunix())
        jexename = [filepath, ...
            '/jigsaw-geo/bin/GLX-64/jigsaw-geo64d'];
    end
    end
    
    if (exist(jexename,'file')~=+2), jexename = ''; end
    
%-- switch to release binary
    if (strcmp(jexename,''))
    if (ispc())
        jexename = [filepath, ...
            '\jigsaw-geo\bin\WIN-64\jigsaw-geo64r.exe'];
    elseif (ismac ())
        jexename = [filepath, ...
            '/jigsaw-geo/bin/MAC-64/jigsaw-geo64r'];
    elseif (isunix())
        jexename = [filepath, ...
            '/jigsaw-geo/bin/GLX-64/jigsaw-geo64r'];
    end
    end
  
    jexetext = [jexename, ' ', opts.jcfg_file] ;
    
%-- call JIGSAW and capture stdout
    if (exist(jexename,'file') == +2)
   
   [status, result] = system(jexetext, '-echo');
   
%-- OCTAVE doesn't handle '-echo'!
    if (exist('OCTAVE_VERSION', 'builtin') > 0)
        fprintf(1,'%s',result) ;
    end
    
    else
    error('JIGSAW: executable not found.') ;
    end

    if (nargout == +1)
    varargout{1} = readmsh(opts.mesh_file) ;
    end
    
end

function makejig(name,opts)
%MAKEJIG make *.JIG file for JIGSAW .

   [path,file,fext] = fileparts(name) ;

    if(~strcmp(lower(fext),'.jig'))
        error('Invalid file name');
    end

    try
   
    ffid = fopen(name, 'w' ) ;
   
    fprintf(ffid,'# %s.jig configuration file\r\n',file);
    
    data = fieldnames (opts) ;
    data = sort(data) ;
    
    for ii = +1:length(data) 
        
    switch (lower(data{ii})) 
    %!! if some of these options are undomcumented, it's because 
    %!! they are either (i) still experimental, or (ii) intended 
    %!! for internal use only...
    %!!
        case 'verbosity'
        pushints(ffid,opts.verbosity,'verbosity',false);
    %-- FILE options
        case 'jcfg_file' ;
        case 'geom_file'
        pushchar(ffid,opts.geom_file,'geom_file');
        
        case 'mesh_file'
        pushchar(ffid,opts.mesh_file,'mesh_file');
        
        case 'hfun_file'
        pushchar(ffid,opts.hfun_file,'hfun_file');
        
    %-- GEOM options
        case 'geom_seed'
        pushints(ffid,opts.geom_seed,'geom_seed',false);
        
        case 'geom_feat'
        pushbool(ffid,opts.geom_feat,'geom_feat');
        
        case 'geom_phi1'
        pushreal(ffid,opts.geom_phi1,'geom_phi1',false);
        case 'geom_phi2'
        pushreal(ffid,opts.geom_phi2,'geom_phi2',false);
        
        case 'geom_eta1'
        pushreal(ffid,opts.geom_eta1,'geom_eta1',false);
        case 'geom_eta2'
        pushreal(ffid,opts.geom_eta2,'geom_eta2',false);
        
    %-- HFUN options
        case 'hfun_kern'
        pushchar(ffid,opts.hfun_kern,'hfun_kern');
        
        case 'hfun_scal'
        pushchar(ffid,opts.hfun_scal,'hfun_scal');
        
        case 'hfun_grad'
        pushreal(ffid,opts.hfun_grad,'hfun_grad',true );
        
        case 'hfun_hmax'
        pushreal(ffid,opts.hfun_hmax,'hfun_hmax',true );
        case 'hfun_hmin'
        pushreal(ffid,opts.hfun_hmin,'hfun_hmin',true );
        
    %-- MESH options
        case 'mesh_kern'
        pushchar(ffid,opts.mesh_kern,'mesh_kern');
        
        case 'mesh_iter'
        pushints(ffid,opts.mesh_iter,'mesh_iter',false);
        
        case 'mesh_dims'
        pushints(ffid,opts.mesh_dims,'mesh_dims',true );
        
        case 'mesh_top1'
        pushbool(ffid,opts.mesh_top1,'mesh_top1');
        case 'mesh_top2'
        pushbool(ffid,opts.mesh_top2,'mesh_top2');
        
        case 'mesh_siz1'
        pushreal(ffid,opts.mesh_siz1,'mesh_siz1',true );
        case 'mesh_siz2'
        pushreal(ffid,opts.mesh_siz2,'mesh_siz2',true );
        case 'mesh_siz3'
        pushreal(ffid,opts.mesh_siz3,'mesh_siz3',true );
        
        case 'mesh_eps1'
        pushreal(ffid,opts.mesh_eps1,'mesh_eps1',true );
        case 'mesh_eps2'
        pushreal(ffid,opts.mesh_eps2,'mesh_eps2',true );
        
        case 'mesh_rad2'
        pushreal(ffid,opts.mesh_rad2,'mesh_rad2',true );
        case 'mesh_rad3'
        pushreal(ffid,opts.mesh_rad3,'mesh_rad3',true );
        
        case 'mesh_off2'
        pushreal(ffid,opts.mesh_off2,'mesh_off2',true );
        case 'mesh_off3'
        pushreal(ffid,opts.mesh_off3,'mesh_off3',true );
        
        case 'mesh_snk2'
        pushreal(ffid,opts.mesh_snk2,'mesh_snk2',true );
        case 'mesh_snk3'
        pushreal(ffid,opts.mesh_snk3,'mesh_snk3',true );
        
        case 'mesh_vol3'
        pushreal(ffid,opts.mesh_vol3,'mesh_vol3',true );

        otherwise
        error(['Invalid data: OPTS.', upper(data{ii})]);
    end
        
    end

    fclose(ffid);

    catch   err
    
    if (ffid>-1)
    fclose(ffid);
    end
    
    rethrow(err);
    
    end
    
end

function pushbool(ffid,data,name)
%PUSHBOOL push data onto JCFG file.

    if (islogical(data))
        if (data)
            pushchar(ffid,'true' ,name);
        else
            pushchar(ffid,'false',name);
        end
    else
        error(['Incorrect type: OPTS.',upper(name)]) ;
    end

end

function pushchar(ffid,data,name)
%PUSHCHAR push data onto JCFG file.

    if (ischar(data))
        fprintf(ffid,[name,'=%s\r\n'],data);
    else
        error(['Incorrect type: OPTS.',upper(name)]) ;
    end

end

function pushreal(ffid,data,name,list)
%PUSHREAL push data onto JCFG file.

    if (isnumeric(data))
    if (list)
    if (numel(data)==+1)
        fprintf(ffid,[name,'=-1;%1.16g\r\n'],data );
    else
        if (ndims(data)==+2 && size(data,2)==+2)
        fprintf(ffid,[name,'=%i;%1.16g\r\n'],data');
        else
        error(['Incorrect dims: OPTS.',upper(name)]) ;
        end
    end
    else
        if (numel(data)==+1)
        fprintf(ffid,[name,'=%1.16g\r\n'],data);
        else
        error(['Incorrect dims: OPTS.',upper(name)]) ;
        end
    end
    else
        error(['Incorrect type: OPTS.',upper(name)]) ;
    end
    
end

function pushints(ffid,data,name,list)
%PUSHINTS push data onto JCFG file.

    if (isnumeric(data))
    if (list)
    if (numel(data)==+1)
        fprintf(ffid,[name,'=-1;%i\r\n'],data );
    else
        if (ndims(data)==+2 && size(data,2)==+2)
        fprintf(ffid,[name,'=%i;%i\r\n'],data');
        else
        error(['Incorrect dims: OPTS.',upper(name)]) ;
        end
    end
    else
        if (numel(data)==+1)
        fprintf(ffid,[name,'=%i\r\n'],data);
        else
        error(['Incorrect dims: OPTS.',upper(name)]) ;
        end
    end
    else
        error(['Incorrect type: OPTS.',upper(name)]) ;
    end

end



