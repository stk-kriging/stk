% LINSOLVE [overloaded base function]

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function w = linsolve (kreq, rs)

if nargin < 2,
    rs = kreq.RS;
end

% Solves the linear equation A * ws = rs, where A is the kriging matrix

if stk_is_octave_in_use (),
    % linsolve is missing in Octave
    w = kreq.LS_R \ (kreq.LS_Q' * rs);
else
    w = linsolve (kreq.LS_R, kreq.LS_Q' * rs, struct ('UT', true));
end

end % function linsolve