% CHECK_INDEX_FILE checks an INDEX file (part of the release process)

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@supelec.fr>

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

function check_index_file (index_file, public_mfile_list)

if nargin < 2,
    
    admin_dir = fileparts (mfilename ('fullpath'));
    
    if nargin < 1,
        index_file = fullfile (admin_dir, 'octave-pkg', 'INDEX');
    end
    
    if nargin < 2,
        root = fullfile (admin_dir, '..');
        public_mfile_list = get_public_mfile_list (root);
    end
    
end

[indexed, ignored] = parse_index_file (index_file);

errmsg = {};

missing = setdiff (public_mfile_list, union (indexed, ignored));
if ~ isempty (missing)
    errmsg = {sprintf('\nThe following public M-file are missing in INDEX:\n')};
    errmsg = [errmsg; cellfun(...
        @(s)(sprintf ('!!! %s\n', s)), missing, 'UniformOutput', false)];
end

ignored = setdiff (ignored, public_mfile_list);
if ~ isempty (ignored)
    errmsg = [errmsg; {sprintf(['\nThe following M-files are ignored in ' ...
        'INDEX but are not in the list of public M-files:\n'])}];
    errmsg = [errmsg; cellfun(...
        @(s)(sprintf ('!!! %s\n', s)), ignored, 'UniformOutput', false)];    
end

indexed = setdiff (indexed, public_mfile_list);
if ~ isempty (indexed)
    errmsg = [errmsg; {sprintf(['\nThe following M-files are indexed in ' ...
        'INDEX but are not in the list of public M-files:\n'])}];
    errmsg = [errmsg; cellfun(...
        @(s)(sprintf ('!!! %s\n', s)), indexed, 'UniformOutput', false)];    
end

if ~ isempty (errmsg)
    error (horzcat (errmsg{:}));
end

end % function check_index_file

 
function [indexed, ignored] = parse_index_file (index_file)

fid = fopen_ (index_file, 'rt');

indexed = {};
ignored =  {};

while 1,
    
    s = fgetl (fid);
    if ~ ischar (s),  break;  end
    
    if length (s) > 1,
        if s(1) == ' '
            indexed = [indexed {strtrim(s)}];
        elseif (s(1) == '#') && (s(2) ~= '#')
            s(1) = '';
            i = regexp (s, '\[', 'once');
            if ~ isempty (i),  s = s(1:(i-1));  end
            ignored = [ignored {strtrim(s)}];
        end
    end
    
end

fclose (fid);

end % function parse_index_file

%#ok<*AGROW>
