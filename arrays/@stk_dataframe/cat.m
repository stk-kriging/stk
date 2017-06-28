% CAT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@centralesupelec.fr>

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

function z = cat(dim, varargin)

if dim == 1
    
    % concatenate along dimension 1, i.e., vertically
    z = vertcat(varargin{:});
    
else
    
    if dim ~= 2
        errmsg = 'Dataframes can only be concatenated along dimension 1 or 2.';
        stk_error(errmsg, 'InvalidArgument');
    else
        % concatenate along dimension 2, i.e., horizontally
        z = horzcat(varargin{:});
    end
    
end % if

end % function


%!shared u, v, x, y
%! u = rand(3, 2);
%! v = rand(3, 2);
%! x = stk_dataframe(u);
%! y = stk_dataframe(v);

%!test % vertical
%! z = cat(1, x, y);
%! assert(isa(z, 'stk_dataframe'));
%! assert(isequal(double(z), [u; v]));

%!error z = cat(3, x, y);

%!test % horizontal
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = cat(2, x, y);
%! assert(isa(z, 'stk_dataframe'));
%! assert(isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'' '' 'y1' 'y2'})));
