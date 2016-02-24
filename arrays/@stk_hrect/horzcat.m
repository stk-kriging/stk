% HORZCAT [overload base function]

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

function z = horzcat (x, y, varargin)

if nargin < 2,
    z = x;
    return
end

if isa (x, 'stk_hrect'),  x = x.stk_dataframe;  end
if isa (y, 'stk_hrect'),  y = y.stk_dataframe;  end

z = horzcat (x, y);

try
    z = stk_hrect (z);
catch
    err = lasterror ();
    if strcmp (err.identifier, 'STK:stk_hrect:InvalidBounds')
        warning ('STK:stk_hrect:horzcat:IllegalBounds', ...
            'Illegal bounds, the result is not an stk_hrect object.');
    else
        rethrow (err);
    end
end

if nargin > 2,
    z = horzcat (z, varargin{:});
end

end % function

%#ok<*LERR,*CTCH>


%!shared d, x1, x2, x3
%! d = 10;
%! x1 = stk_hrect (d);
%! x2 = double (x1);
%! x3 = [1:d; 0:(d-1)];  % illegal bounds

%!test
%! y1 = horzcat (x1, x1);
%! assert (isequal (size (y1), [2 2*d]));
%! assert (strcmp (class (y1), 'stk_hrect'));

%!test
%! y2 = horzcat (x1, x2);
%! assert (isequal (size (y2), [2 2*d]));
%! assert (strcmp (class (y2), 'stk_hrect'));

%!test
%! y3 = horzcat (x2, x1);
%! assert (isequal (size (y3), [2 2*d]));
%! assert (strcmp (class (y3), 'stk_hrect'));

%!test
%! lastwarn ('')
%! y4 = horzcat (x1, x3);
%! assert (isequal (size (y4), [2 2*d]));
%! assert (strcmp (class (y4), 'stk_dataframe'));
%! [warn_msg, warn_id] = lastwarn ();
%! assert (strcmp (warn_id, 'STK:stk_hrect:horzcat:IllegalBounds'))
