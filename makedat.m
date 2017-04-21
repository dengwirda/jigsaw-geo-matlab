function makedat(name,data)
%MAKEDAT make a *.DAT file for JIGSAW-GEO.
%
%   MAKEDAT(NAME,DATA) writes the following entities to "NAME.DAT":
%
% - ARRAY - [N1 x N2 x ... X Nm] n-dim. array data, written in col-
%   umn-wise ordering.
%
%   See also JIGSAWGEO, READDAT
%

%---------------------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   21-Apr-2017
%   engwirda@mit.edu
%---------------------------------------------------------------------
%

   [path,file,fext] = fileparts(name);
   
    if(~strcmp(lower(fext),'.dat'))
        name = [name,'.dat'];
    end
 
    try
%-- try to write data to file
    
    ffid = fopen(name, 'w') ;
    
    fprintf(ffid, ...
    ['# %s.dat file, created by JIGSAW','\n'],file);

    [nlat,nlon] = size(data);

    fprintf(ffid, ...
       'array=2;%u;%u\n',nlat,nlon) ;
    
    fprintf(ffid,'%1.8g\n',data(:)) ;
    
    fclose(ffid);
    
    catch err
    
%-- ensure that we close the file regardless!
    if (ffid>-1)
    fclose(ffid) ;
    end
    
    rethrow(err) ;
        
    end

end



