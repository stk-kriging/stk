% NAMES_ERRMSG [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function [s, mnemo] = names_errmsg (n1, n2, type)

mnemo = sprintf ('Unknown%sNames', type);

type = lower (type);

s = 'Invalid indexing';

if any (~ cellfun (@ischar, n1)),
    s = sprintf ('%s: %s names must be character arrays (char).', s, type);
else
    i = find (~ ismember (n1, n2), 1, 'first');
    s = sprintf ('%s: there is no %s named %s.', s, type, n1{i});
end

end % function
