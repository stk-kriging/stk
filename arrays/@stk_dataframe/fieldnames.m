% FIELDNAMES [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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

% Non-empty column names
cn = x.colnames;
cn = cn(~ cellfun (@isempty, cn));

% Non-empty row names
rn = x.rownames;
rn = rn(~ cellfun (@isempty, rn))';

fn = [cn rn reserved_field_names()];

end % function


%!test
%! x = stk_dataframe (rand (3, 2), {'u' 'v'});
%! s1 = sort (fieldnames (x));
%! s2 = {'colnames' 'data' 'info' 'rownames' 'u' 'v'};
%! assert (all (strcmp (s1, s2)));

%!test
%! x = stk_dataframe (rand (3, 2));
%! x.rownames(2:3) = {'aa', 'bb'};
%! x.colnames{2} = 'toto';
%! assert (isequal (fieldnames (x), ...
%!    {'toto' 'aa' 'bb' 'data' 'info' 'rownames' 'colnames'}));
