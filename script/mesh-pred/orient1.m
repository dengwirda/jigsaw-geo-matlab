function [sign] = orient1(pa,pb,pp)
%ORIENT1 return the orientation of PP wrt the line [PA, PB].
%
%   See also ORIENT2

%   Darren Engwirda : 2018 --
%   Email           : de2363@columbia.edu
%   Last updated    : 10/07/2018

%---------------------------------------------- calc. det(S)
    smat = zeros(+2,+2,size(pp,1));
    smat(1,:,:) = pa-pp;
    smat(2,:,:) = pb-pp;

    sign = ...
    smat(1,1,:).* smat(2,2,:) - ...
	smat(1,2,:).* smat(2,1,:) ;

end



