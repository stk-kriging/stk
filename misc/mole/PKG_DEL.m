% Unloading script for the Matlab/Octave Langage Extension (MOLE).
%
% Note: this script must be renamed to PKG_DEL (without the extension) if the MOLE is to
% be released as an octave package.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:   Julien Bect  <julien.bect@supelec.fr>

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

mole_dir = fileparts (mfilename ('fullpath'));

s = path ();

while ~ isempty (s)
    [d, s] = strtok (s, ':');  %#ok<STTOK>
    if (~ isempty (regexp (d, ['^' mole_dir], 'once'))) && (~ strcmp (d, mole_dir))
        rmpath (d);
    end
end
