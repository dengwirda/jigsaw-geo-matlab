function [fb] = local_tria_4( ...
        p1,p2,p3,p4,f1,f2,f3,f4,gmax)
%LOCAL-TRIA-4 single-element eikonal solver for TRIA-4 cells
%embedded in R^d. 
%   FB = LOCAL_TRIA_4(P1,P2,P3,P4,F1,F2,F3,F4,GM) returns a 
%   gradient-limited value FB at vertex {P4,F4} for each in-
%   put tetrahedron. GM is the max. allowable gradient value 
%   |GRAD(FF)| associated with each cell.

%   Darren Engwirda : 2018 --
%   Email           : de2363@columbia.edu
%   Last updated    : 20/07/2018

%------------------------------ find 'limited' extrap. to f4

%%!! TODO

end



