function [varargout] = tripod(opts)
%TRIPOD an interface to the JIGSAW's "restricted" Delaunay
%tessellator TRIPOD.
%
%   MESH = TRIPOD(OPTS);
%
%   Call the rDT tessellator TRIPOD using the confg. options 
%   specified in the OPTS structure. See the SAVEMSH/LOADMSH 
%   routines for a description of the MESH output structure.
%
%   OPTS is a user-defined set of meshing options:
%
%   REQUIRED fields:
%   ---------------
%
%   OPTS.INIT_FILE - 'INITNAME.MSH', a string containing the 
%       name of the initial distribution file (is required 
%       at input). See SAVEMSH for additional details regar-
%       ding the creation of *.MSH files.
%
%   OPTS.JCFG_FILE - 'JCFGNAME.JIG', a string containing the 
%       name of the cofig. file (will be created on output).
%
%   OPTS.MESH_FILE - 'MESHNAME.MSH', a string containing the 
%       name of the output file (will be created on output).
%
%   OPTIONAL fields (GEOM):
%   ----------------------
%
%   OPTS.GEOM_FILE - 'GEOMNAME.MSH', a string containing the 
%       name of the geometry file (is required at input).
%       When a non-null geometry is passed, MESH is computed
%       as a "restricted" Delaunay tessellation, including 
%       various 1-, 2- and/or 3-dimensional sub-meshes that
%       approximate the geometry definition.
%
%   OPTIONAL fields (MESH):
%   ----------------------
%
%   OPTS.MESH_DIMS - {default=3} number of "topological" di-
%       mensions to mesh. DIMS=K meshes K-dimensional featu-
%       res, irrespective of the number of spatial dim.'s of 
%       the problem (i.e. if the geometry is 3-dimensional 
%       and DIMS=2 a surface mesh will be produced).
%
%   OPTIONAL fields (MISC):
%   ----------------------
%
%   OPTS.VERBOSITY - {default=0} verbosity of log-file gene-
%       rated by JIGSAW. Set VERBOSITY >= 1 for more output.
%
%   See also LOADMSH, SAVEMSH
%

%-----------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-matlab
%   30-Dec-2018
%   darren.engwirda@columbia.edu
%-----------------------------------------------------------
%

    jexename = '';

    if ( isempty(opts))
        error('TRIPOD: insufficient inputs.');
    end
    
    if (~isempty(opts) && ~isstruct(opts))
        error('TRIPOD: invalid input types.');
    end
        
    savejig(opts.jcfg_file,opts);
    
    filename = mfilename('fullpath');
    filepath = fileparts( filename );

%---------------------------------- default to _debug binary
    if (strcmp(jexename,''))
    if (ispc())
        jexename = [filepath, ...
            '\jigsaw\bin\WIN-64\tripod64d.exe'];
    elseif (ismac ())
        jexename = [filepath, ...
            '/jigsaw/bin/MAC-64/tripod64d'];
    elseif (isunix())
        jexename = [filepath, ...
            '/jigsaw/bin/LNX-64/tripod64d'];
    end
    end
    
    if (exist(jexename,'file')~=2), jexename=''; end
    
%---------------------------------- switch to release binary
    if (strcmp(jexename,''))
    if (ispc())
        jexename = [filepath, ...
            '\jigsaw\bin\WIN-64\tripod64r.exe'];
    elseif (ismac ())
        jexename = [filepath, ...
            '/jigsaw/bin/MAC-64/tripod64r'];
    elseif (isunix())
        jexename = [filepath, ...
            '/jigsaw/bin/LNX-64/tripod64r'];
    end
    end
  
    if (exist(jexename,'file')~=2), jexename=''; end
  
%---------------------------- call JIGSAW and capture stdout
    if (exist(jexename,'file')==2)
 
   [status, result] = system( ...
        [jexename,' ',opts.jcfg_file], '-echo');
        
%---------------------------- OCTAVE doesn't handle '-echo'!
    if (exist('OCTAVE_VERSION', 'builtin') > 0)
        fprintf(1, '%s', result) ;
    end
    
    else
%---------------------------- couldn't find JIGSAW's backend
        error([ ...
        'JIGSAW''s executable not found -- ', ...
        'has JIGSAW been compiled from src?', ...
            ] ) ;
    end

    if (nargout == +1)
%---------------------------- read mesh if output requested!
    varargout{1} = loadmsh (opts.mesh_file) ;
    
    end

end


