function libpath
%LIBPATH a helper function to set-up MATLAB's path statement
%for JIGSAW. 
%
%   See also JIGSAW, MESHDEMO

%-----------------------------------------------------------
%   JIGSAW-0.9.6.x
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-matlab
%   24-Jul-2018
%   darren.engwirda@columbia.edu
%-----------------------------------------------------------
%

%------------------------------------ push path to utilities
    
    filename = mfilename('fullpath') ;
    filepath = fileparts( filename ) ;
    
    addpath([filepath,'/script/aabb-tree']) ;
    addpath([filepath,'/script/draw-util']) ;
    addpath([filepath,'/script/geom-util']) ;
    addpath([filepath,'/script/hfun-util']) ;
    addpath([filepath,'/script/math-util']) ;
    addpath([filepath,'/script/mesh-ball']) ;
    addpath([filepath,'/script/mesh-cost']) ;
    addpath([filepath,'/script/mesh-file']) ;
    addpath([filepath,'/script/mesh-pred']) ;
    addpath([filepath,'/script/mesh-util']) ;
    addpath([filepath,'/script/poly-test']) ;

end



