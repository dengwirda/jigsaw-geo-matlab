function [data] = readdat(name)
%READDAT read a *.DAT file for JIGSAW-GEO.
%
%   DATA = READDAT(NAME);
%
%   The following entities are optionally read from "NAME.DAT". Ent-
%   ities are loaded if they are present in the file:
%
% - ARRAY - [N1 x N2 x ... X Nm] n-dim. array data, returned in col-
%   umn-wise ordering.
%
%   See also JIGSAWGEO, MAKEDAT
%

%---------------------------------------------------------------------
%   Darren Engwirda
%   github.com/dengwirda/jigsaw-geo-matlab
%   10-Dec-2016
%   engwirda@mit.edu
%---------------------------------------------------------------------
%

    try

    ffid = fopen(name,'r');
    
    while (true)
  
    %-- read next line from file
        lstr = fgetl(ffid);
        
        if (ischar(lstr) )
        
        if (length(lstr) > +0 && lstr(1) ~= '#')

        %-- tokenise line about '=' character
            tstr = regexp(lower(lstr),'=','split');
           
            switch (strtrim(tstr{1}))
            case 'array'

        %-- read "ARRAY" data

                stag = regexp(tstr{2},';','split');

                ndim = str2double(stag{1}) ;
 
                for ii = +1 : ndim
                nsiz(ii) = ...
                    str2double(stag{ii+1}) ;
                end
                
                data = fscanf( ...
                    ffid,'%f',prod(nsiz));

                data = reshape(data,nsiz);
     
            end
                      
        end
           
        else
    %-- if(~ischar(lstr)) //i.e. end-of-file
            break ;
        end
        
    end
    
    fclose(ffid) ;
    
    catch err

%-- ensure that we close the file regardless
    if (ffid>-1)
    fclose(ffid) ;
    end
    
    rethrow(err) ;
    
    end

end


