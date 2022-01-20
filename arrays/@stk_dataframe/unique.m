% UNIQUE [overload base]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function [y, ia, ib] = unique (x, varargin)

if ~ isa (x, 'stk_dataframe')
    stk_error ('x should be an stk_dataframe object here.', 'TypeMismatch');
end

% We want unique to behave always as if the 'rows' option had be given
varargin = unique ([varargin {'rows'}]);

[y_data, ia, ib] = unique (x.data, varargin{:});    

if isempty (x.rownames)
    rn = {};
else
    rn = x.rownames(ia);
end

y = stk_dataframe (y_data, x.colnames, rn);

end % function


%!test  
%! cn = {'u' 'v' 'w'};  x = stk_dataframe (rand (4, 3), cn);
%! y = [x; x];  z = unique (y, 'rows');
%! assert (isequal (z.colnames, cn));
%! assert (isequal (z.data, unique (x.data, 'rows')));
