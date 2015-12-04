% COPY_CITATION

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function copy_citation (src_filename, unpacked_dir)

fid = fopen_ (src_filename, 'rt');
s = char (fread (fid));
fclose (fid);

s = strrep (s, '$YEAR', datestr (now, 'yyyy'));
s = strrep (s, '$VERNUM', get_version_number_ ());

fid = fopen_ (fullfile (unpacked_dir, 'CITATION'), 'wt');
fwrite (fid, s);
fclose (fid);

end % function


function version_number = get_version_number_ ()

% Get a valid version number (without an extension such as '-dev')
version_number = get_version_number ();

% Is it already of the form X.Y ?
if isempty (regexp (version_number, '^(?<x>[0-9]*)\.(?<y>[0-9]*)$'))
    % Perhaps X.Y.Z, then ?
    S = regexp (version_number, ...
       '^(?<x>[0-9]*)\.(?<y>[0-9]*).(?<z>[0-9]*)$', 'names');
    if isempty (S.x)
        error ('Failed to parse version number.');
    end
    version_number = [S.x '.' S.y];
end

end % function
