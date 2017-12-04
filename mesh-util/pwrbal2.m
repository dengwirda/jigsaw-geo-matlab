function [bb] = pwrbal2(pp,pw,tt)
%PWRBAL2 compute the ortho-balls associated with a 2-simplex
%triangulation embedded in R^2.
%   [BB] = PWRBAL2(PP,PW,TT) returns the set of power balls
%   associated with the triangles in [PP,TT], such that BB = 
%   [XC,YC,RC.^2]. PW is a vector of vertex weights.

%   Darren Engwirda : 2017 --
%   Email           : de2363@columbia.edu
%   Last updated    : 13/11/2017

%---------------------------------------------- basic checks    
    if ( ~isnumeric(pp) || ...
         ~isnumeric(pw) || ...
         ~isnumeric(tt) )
        error('pwrbal2:incorrectInputClass' , ...
            'Incorrect input class.');
    end
    
%---------------------------------------------- basic checks
    if (ndims(pp) ~= +2 || ...
        ndims(pw) ~= +2 || ...
        ndims(tt) ~= +2 )
        error('pwrbal2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end
    
    if (size(pp,2)~= +2 || ...
            size(pp,1)~= size(pw,1) || ...
                size(tt,2) < +3 )
        error('pwrbal2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end

%------------------------------------------------ lhs matrix     
    ab = pp(tt(:,2),:)-pp(tt(:,1),:) ;
    ac = pp(tt(:,3),:)-pp(tt(:,1),:) ;
   
%------------------------------------------------ rhs vector    
    rv11 = sum(ab.*ab,2) ...
     - ( pw(tt(:,2)) - pw(tt(:,1)) ) ;
    rv22 = sum(ac.*ac,2) ...
     - ( pw(tt(:,3)) - pw(tt(:,1)) ) ;
    
%------------------------------------------------ solve sys.
    dd      = ab(:,1) .* ac(:,2) - ...
              ab(:,2) .* ac(:,1) ;
              
    bb = zeros(size(tt,1),3) ;
    bb(:,1) = (ac(:,2) .* rv11 - ...
               ab(:,2) .* rv22 ) ...
            ./ dd * +.5 ;
            
    bb(:,2) = (ab(:,1) .* rv22 - ...
               ac(:,1) .* rv11 ) ...
            ./ dd * +.5 ;
      
    bb(:,1:2) = ...
        pp(tt(:,1),:) + bb(:,1:2) ;
        
%------------------------------------------------ mean radii
    r1 = sum( ...
    (bb(:,1:2)-pp(tt(:,1),:)).^2,2);
    r2 = sum( ...
    (bb(:,1:2)-pp(tt(:,2),:)).^2,2);
    r3 = sum( ...
    (bb(:,1:2)-pp(tt(:,3),:)).^2,2);

    r1 = r1 - pw(tt(:,1));
    r2 = r2 - pw(tt(:,2));
    r3 = r3 - pw(tt(:,3));

    bb(:,3) = ( r1+r2+r3 ) / +3.0 ;

end



