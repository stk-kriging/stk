% STK_NDF constructs a noisy dataframe

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function ndf = stk_ndf (x, noisevariance)

% noisy data frame object
if isscalar (noisevariance)
    noisevariance = repmat (noisevariance, stk_length (x), 1);
else
    assert(stk_length (x) == length (noisevariance), ...
        'stk_ndf constructor: the size of the first and second argument differs');
end

ndf = struct ('noisevariance', noisevariance);
ndf = class (ndf, 'stk_ndf', stk_dataframe (x));

end % function stk_ndf


%!test
%! x = stk_dataframe (rand (5, 3));
%! y = stk_ndf (x, 1);  disp (y);
%! assert ((isa (y, 'stk_ndf')) && (isequal (size (y), [5 3])))
%! assert (isequal (y.noisevariance, ones (5, 1)))

%!test
%! x = stk_factorialdesign ({1:3, 1:2});
%! y = stk_ndf (x, 1);  disp (y);
%! assert ((isa (y, 'stk_ndf')) && (isequal (size (y), [6 2])))
%! assert (isequal (y.noisevariance, ones (6, 1)))
