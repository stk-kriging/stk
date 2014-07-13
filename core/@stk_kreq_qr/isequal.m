% ISEQUAL  [STK internal function, not part of public API... UAYOR!]
%
% CALL: b = isequal (x, y)
%
%    Overload base function 'isequal' for stk_kreq_qr objects.

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function b = isequal (x, y)

b = strcmp (class (x), class (y)) ...
    && isequal (struct (x), struct (y));

end % function isequal

