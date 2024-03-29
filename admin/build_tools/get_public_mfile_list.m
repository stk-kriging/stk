% GET_PUBLIC_MFILE_LIST returns the list of all public M-files in STK

% Copyright Notice
%
%    Copyright (C) 2022 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function L = get_public_mfile_list (root)

here = pwd ();
old_path = path ();

try
    % Make sure that we call the *correct* version of stk_init
    cd (root);
    addpath (root);

    dir_list = stk_init ('genpath');
    dir_list = [root dir_list];

    path (old_path);
    cd (here);
catch
    path (old_path);
    cd (here);
    rethrow (lasterror ());
end

L = {};
for i = 1:(length (dir_list))
    L = [L{:} get_public_mfile_list_(dir_list{i}, '')];
end

L = L(:);  % better for direct display :)

end % function

%#ok<*AGROW>


function L = get_public_mfile_list_ (d, prefix)

S = dir (d);
L = {};

for i = 1:(length (S))
    if (~ S(i).isdir) && (~ isempty (regexp (S(i).name, '\.m$', 'once')))
        S(i).name((end - 1):end) = '';
        if isempty (prefix)
            % For ordinary public m-files
            L = [L{:} {S(i).name}];
        else
            % For m-files that belong to @-directories
            L = [L{:} {[prefix filesep S(i).name]}];
        end
    elseif (S(i).isdir) && (S(i).name(1) == '@')
        % Process @-directory
        L = [L{:} get_public_mfile_list_([d filesep S(i).name], S(i).name)];
    end
end

end % function
