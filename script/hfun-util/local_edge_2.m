function [fb] = ...
    local_edge_2(p1,p2,f1,f2,gmax)
%LOCAL-EDGE-2 single-element eikonal solver for EDGE-2 cells
%embedded in Rd. 
%   FB = LOCAL_EDGE_2(P1,P2,F1,F2,GM) returns the gradient-
%   limited value FB at vertex {P2,F2} of the input  edges. 
%   GM is the max. allowable gradient value |GRAD(FF)| ass- 
%   ociated with each edge. 

%   Darren Engwirda : 2018 --
%   Email           : de2363@columbia.edu
%   Last updated    : 20/07/2018

%------------------------------ find 'limited' extrap. to f2
    fb = f1 + gmax .* ...
        sqrt( sum( (p2-p1).^2, +2) ) ;

end



