% FIELDNAMES [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function fn = fieldnames (x)

fn = fieldnames (x.stk_dataframe);
fn = [{'levels' 'stk_dataframe'} fn];

end % function

%!test
%! x = stk_factorialdesign ({0:1, 3:5}, {'u' 'v'});
%! fn1 = sort (fieldnames (x));
%! fn2 = {'colnames', 'data', 'info', 'levels', ...
%!        'rownames', 'stk_dataframe', 'u', 'v'};
%! assert (isequal (fn1, fn2));
