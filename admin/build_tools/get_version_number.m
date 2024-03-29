% GET_VERSION_NUMBER

% Copyright Notice
%
%    Copyright (C) 2015, 2022 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function version_number = get_version_number ()

old_path = path ();
build_tools_dir = fileparts (mfilename ('fullpath'));
addpath (fileparts (fileparts (build_tools_dir)));

version_number = stk_version ();

% -dev --> .0   (this makes it possible to test building on default)
version_number = regexprep (version_number, '-dev$', '.0');

% Is it of the form X.Y.Z ?
if isempty (regexp (version_number, '^[0-9]+\.[0-9]+\.[0-9]+$'))
    error ('Incorrect version number.');
end

path (old_path);

end % function
