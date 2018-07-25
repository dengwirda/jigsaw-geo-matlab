function [fb] = ...
    local_tria_3(p1,p2,p3,f1,f2,f3,gmax)
%LOCAL-TRIA-3 single-element eikonal solver for TRIA-3 cells
%embedded in R^d. 
%   FB = LOCAL_TRIA_3(P1,P2,P3,F1,F2,F3,GM) returns the gra-
%   dient-limited value FB at vertex {P3,F3} for each input 
%   tria. GM is the max. allowable gradient value |GRAD(FF)|
%   associated with each cell.

%   Darren Engwirda : 2018 --
%   Email           : de2363@columbia.edu
%   Last updated    : 20/07/2018

%------------------------------ find 'limited' extrap. to f3
    pp21 = p2-p1;   
    pp13 = p1-p3;
    
    AA = sum(pp13.*pp21,2);
    BB = sum(pp21.^2,2);
    CC = sum(pp13.^2,2);
    
    ff21 = f2-f1;
    
    At = BB.^2-(ff21./gmax).^2 .* BB;
    Bt = 2.*AA.*(BB-(ff21./gmax).^2);
    Ct = AA.^2-(ff21./gmax).^2 .* CC;
    
    tp = ones (size(f1));
    tm = zeros(size(f1));
    
    sq = Bt.^2 - 4.*At.*Ct;
    ok = sq >= 0. ;

    tp(ok) = (-Bt(ok)+sqrt(sq(ok))) ...
        ./ (2. * At(ok));
    tm(ok) = (-Bt(ok)-sqrt(sq(ok))) ...
        ./ (2. * At(ok));
    
    tp = max(0.,min(1.,tp));
    tm = max(0.,min(1.,tm));
    
    Tp = tp(:,ones(1,size(p1,2))) ;
    Tm = tm(:,ones(1,size(p1,2))) ;
    
    dp = sqrt(sum( ...
        (pp13+Tp.*pp21).^2,2)) ;
    dm = sqrt(sum( ...
        (pp13+Tm.*pp21).^2,2)) ;
        
    fp = f1 + tp.*ff21 + gmax .* dp ;
    fm = f1 + tm.*ff21 + gmax .* dm ;
   
    fb = min(fp,fm) ;
    
end



