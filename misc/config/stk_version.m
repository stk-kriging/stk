% STK_VERSION returns STK's version number, as defined in README.

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function v = stk_version ()

persistent version_number

if isempty (version_number)
    
    % open README
    filename = fullfile (stk_get_root (), 'README');
    fid = fopen (filename, 'rt');
    if fid == -1,
        stk_error ('Unable to open the README file.', 'FOpenFailed');
    end
    
    % what we're looking for
    t = 'Version: ';
    
    while 1
        
        % read a new line
        s = fgetl (fid);
        if s == -1,
            fclose (fid);
            stk_error ('Unable to read STK''s version number.', 'Unexpected');
        end
        
        % look for the pattern
        i = strfind (s, t);
        if ~isempty (i)
            version_number = strtrim (s((i + length(t)):end));
            fclose (fid);
            break
        end
        
    end
        
end

v = version_number;

end % stk_version
